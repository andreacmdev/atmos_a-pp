import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/adolescente.dart';
import '../models/tipo_evento.dart';
import '../services/google_sheets_api.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PresencaScreen extends StatefulWidget {
  final TipoEvento tipoEvento;
  const PresencaScreen({super.key, required this.tipoEvento});

  @override
  State<PresencaScreen> createState() => _PresencaScreenState();
}

class _PresencaScreenState extends State<PresencaScreen> {
  List<Adolescente> lista = [];

  /// IDs já confirmados (check verde e bloqueados)
  final Set<String> registrados = {};

  /// IDs em envio (loading no item)
  final Set<String> carregandoIds = {};

  bool carregandoLista = true;

  /// Pesquisa
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searching = false;

  /// Data padrão (hoje) no formato yyyy-MM-dd
  final String dataCulto = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Carrega lista e pré-marca quem já está presente (mesmo dia + evento)
  Future<void> _carregarDadosIniciais() async {
    try {
      final dados = await GoogleSheetsApi.fetchAdolescentes();
      final idsPresentes = await GoogleSheetsApi.fetchPresencas(
        dataCulto: dataCulto,
        tipoEvento: widget.tipoEvento.apiValue,
      );

      setState(() {
        lista = dados;
        registrados.addAll(idsPresentes);
        carregandoLista = false;
      });
    } catch (_) {
      setState(() => carregandoLista = false);
      _showSnack('Erro ao carregar. Tente novamente.');
    }
  }

  Future<void> _registrarUm(String id, String nome) async {
    if (registrados.contains(id) || carregandoIds.contains(id)) return;

    setState(() => carregandoIds.add(id));

    try {
      await GoogleSheetsApi.registrarPresenca(
        idAdolescente: id,
        dataCulto: dataCulto,
        tipoEvento: widget.tipoEvento.apiValue,
      );

      setState(() {
        carregandoIds.remove(id);
        registrados.add(id);
      });

      // Snackbar com DESFAZER
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrado: $nome (${widget.tipoEvento.label})'),
          action: SnackBarAction(
            label: 'DESFAZER',
            onPressed: () => _desfazer(id, nome),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() => carregandoIds.remove(id));
      _showSnack(
        'Falha ao registrar $nome. Tentar novamente?',
        action: SnackBarAction(
          label: 'TENTAR',
          onPressed: () => _registrarUm(id, nome),
        ),
      );
    }
  }

  Future<void> _desfazer(String id, String nome) async {
    try {
      await GoogleSheetsApi.removerPresenca(
        idAdolescente: id,
        dataCulto: dataCulto,
        tipoEvento: widget.tipoEvento.apiValue,
      );
      setState(() {
        registrados.remove(id);
      });
      _showSnack('Desfeito: $nome');
    } catch (e) {
      _showSnack('Falha ao desfazer. Tente novamente.');
    }
  }

  void _showSnack(String msg, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), action: action),
    );
  }

  /// --------- PDF ---------
  Future<void> _exportarPdf() async {
  try {
    // --- PRESENTES DO DIA (evento atual) ---
    final presentes = lista
        .where((a) => registrados.contains(a.id))
        .toList()
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    final total = lista.length;
    final totalPresentes = presentes.length;
    final totalFaltantes = total - totalPresentes;

    // --- VISITANTES DO DIA (independente do tipo de evento) ---
    // Pressupondo que você já tem este método no service.
    // Ele deve retornar: List<Map<String,String>> com chaves: 'nome','telefone','idade'
    final visitantesHoje = await GoogleSheetsApi.getVisitantesHoje();
    final qtdVisitantes = visitantesHoje.length;

    // --- FONTES (via assets, com fallback seguro) ---
      pw.Font fontRegular;
      pw.Font fontBold;
      try {
        final r = await rootBundle.load('assets/Roboto-Regular.ttf');
        final b = await rootBundle.load('assets/Roboto-Bold.ttf');
        // prints ajudam a diagnosticar se vier 0 bytes
        // ignore: avoid_print
        print('FONTES OK: regular=${r.lengthInBytes}, bold=${b.lengthInBytes}');
        fontRegular = pw.Font.ttf(r);
        fontBold    = pw.Font.ttf(b);
      } catch (e) {
        // ignore: avoid_print
        print('FALHA FONTES, usando Helvetica: $e');
        fontRegular = pw.Font.helvetica();
        fontBold    = pw.Font.helveticaBold();
      }
    // --- LOGO (opcional) ---
    Uint8List? logoBytes;
    try {
      final data = await rootBundle.load('assets/LOGO.png'); // ajuste caso sua logo esteja em outro caminho
      logoBytes = data.buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }

    final pdf = pw.Document();

    final estiloTitulo     = pw.TextStyle(font: fontBold,    fontSize: 18);
    final estiloSub        = pw.TextStyle(font: fontRegular, fontSize: 12);
    final estiloCabecalho  = pw.TextStyle(font: fontBold,    fontSize: 12);
    final estiloLinha      = pw.TextStyle(font: fontRegular, fontSize: 11);

    final agora    = DateTime.now();
    final geradoEm = DateFormat('dd/MM/yyyy HH:mm').format(agora);
    final dataBR   = DateFormat('dd/MM/yyyy').format(agora);
    final evento   = widget.tipoEvento.label;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        ),
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              children: [
                if (logoBytes != null)
                  pw.Container(
                    width: 36, height: 36, margin: const pw.EdgeInsets.only(right: 12),
                    child: pw.Image(pw.MemoryImage(logoBytes)),
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Relatório de Presenças', style: estiloTitulo),
                    pw.Text('Evento: $evento • Data: $dataBR', style: estiloSub),
                  ],
                ),
              ],
            ),
            pw.Text('Gerado: $geradoEm', style: estiloSub),
          ],
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Página ${ctx.pageNumber}/${ctx.pagesCount}', style: estiloSub),
        ),
        build: (_) => [
          // --- RESUMO ---
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total cadastrados: $total', style: estiloSub),
              pw.Text('Presentes: $totalPresentes', style: estiloSub),
              pw.Text('Faltantes: $totalFaltantes', style: estiloSub),
              pw.Text('Visitantes (hoje): $qtdVisitantes', style: estiloSub),
            ],
          ),
          pw.SizedBox(height: 16),

          // --- TABELA DE PRESENTES ---
          if (presentes.isEmpty)
            pw.Text('Nenhum presente registrado para este evento hoje.', style: estiloSub)
          else
            pw.Table(
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
              columnWidths: { 0: const pw.FixedColumnWidth(36), 1: const pw.FlexColumnWidth(3), },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('#',    style: estiloCabecalho)),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Nome', style: estiloCabecalho)),
                  ],
                ),
                ...List.generate(presentes.length, (i) {
                  final a = presentes[i];
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${i + 1}', style: estiloLinha)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(a.nome,     style: estiloLinha)),
                    ],
                  );
                }),
              ],
            ),

          // --- SEÇÃO DE VISITANTES ---
          pw.SizedBox(height: 24),
          pw.Text('Visitantes de Hoje', style: estiloTitulo),
          pw.SizedBox(height: 8),

          if (visitantesHoje.isEmpty)
            pw.Text('Nenhum visitante registrado hoje.', style: estiloSub)
          else
            pw.Table(
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
              columnWidths: {
                0: const pw.FixedColumnWidth(36),  // #
                1: const pw.FlexColumnWidth(3),    // Nome
                2: const pw.FlexColumnWidth(2),    // Telefone
                3: const pw.FixedColumnWidth(50),  // Idade
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('#',        style: estiloCabecalho)),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Nome',     style: estiloCabecalho)),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Telefone', style: estiloCabecalho)),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Idade',    style: estiloCabecalho)),
                  ],
                ),
                ...List.generate(visitantesHoje.length, (i) {
                  final v   = visitantesHoje[i];
                  final nm  = (v['nome']     ?? '').trim();
                  final tel = (v['telefone'] ?? '').trim().isEmpty ? '-' : (v['telefone'] ?? '').trim();
                  final idd = (v['idade']    ?? '').trim().isEmpty ? '-' : (v['idade']    ?? '').trim();
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${i + 1}', style: estiloLinha)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(nm,         style: estiloLinha)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(tel,        style: estiloLinha)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(idd,        style: estiloLinha)),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'relatorio_${widget.tipoEvento.apiValue}_${dataCulto}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: fileName);
    _showSnack('PDF gerado: $fileName');
  } catch (e) {
    // ignore: avoid_print
    print('ERRO PDF: $e');
    _showSnack('Falha ao gerar PDF: $e');
  }
}
  /// --------- FIM PDF ---------

  /// --------- PESQUISA ---------
  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (_searching) {
        Future.microtask(() => _searchFocus.requestFocus());
      } else {
        _searchCtrl.clear();
      }
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {});
    _searchFocus.requestFocus();
  }

  bool _matchesQuery(String nome) {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return true;
    return _normalize(nome).contains(_normalize(q));
  }

  /// Remove acentos e coloca em minúsculas (busca + amigável)
  String _normalize(String s) {
    const from = 'áàâãäÁÀÂÃÄéèêëÉÈÊËíìîïÍÌÎÏóòôõÖÓÒÔÕÖúùûüÚÙÛÜçÇñÑ';
    const to   = 'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOUUUUuuuuUUUUcCnN';
    var out = s.toLowerCase();
    for (var i = 0; i < from.length && i < to.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }
  /// --------- FIM PESQUISA ---------

  @override
  Widget build(BuildContext context) {
    if (carregandoLista) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final visiveis = lista.where((a) => _matchesQuery(a.nome)).toList();

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar adolescente...',
                  border: InputBorder.none,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : Text('Marcar Presença — ${widget.tipoEvento.label}'),
        actions: [
          if (_searching && _searchCtrl.text.isNotEmpty)
            IconButton(
              tooltip: 'Limpar',
              icon: const Icon(Icons.close),
              onPressed: _clearSearch,
            ),
          IconButton(
            tooltip: _searching ? 'Fechar busca' : 'Buscar',
            icon: Icon(_searching ? Icons.search_off : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            tooltip: 'Exportar PDF (hoje)',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportarPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  'Exibindo ${visiveis.length} de ${lista.length} • Registrados hoje: ${registrados.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 12),
              itemBuilder: (context, i) {
                final a = visiveis[i];
                final isLoading = carregandoIds.contains(a.id);
                final isDone = registrados.contains(a.id);

                return ListTile(
                  title: Text(a.nome),
                  leading: isDone
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : (isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_outline)),
                  trailing: Checkbox(
                    value: isDone,
                    onChanged: (val) {
                      if (!isDone && !isLoading) {
                        _registrarUm(a.id, a.nome);
                      }
                    },
                  ),
                  onTap: () {
                    if (!isDone && !isLoading) {
                      _registrarUm(a.id, a.nome);
                    }
                  },
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: visiveis.length,
            ),
          ),
        ],
      ),
    );
  }
}
