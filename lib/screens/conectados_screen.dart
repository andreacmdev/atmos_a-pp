import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/adolescente.dart';
import '../models/conectado.dart';
import '../services/google_sheets_api.dart';
import '../theme/brand_colors.dart';
import '../widgets/atmos_ui.dart';

class ConectadosScreen extends StatefulWidget {
  const ConectadosScreen({super.key});

  @override
  State<ConectadosScreen> createState() => _ConectadosScreenState();
}

class _ConectadosScreenState extends State<ConectadosScreen> {
  bool _carregando = true;
  String? _erro;
  List<ConectadoGrupo> _grupos = const [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final grupos = await GoogleSheetsApi.fetchConectadosGrupos();
      if (mounted) setState(() => _grupos = grupos);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao carregar conectados: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectados'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _carregando ? null : _carregar,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const AtmosInfoHeader(
              icon: Icons.groups_2_outlined,
              title: 'Grupos de discipulado',
              subtitle:
                  'Registre encontros semanais, acompanhe presencas e organize transferencias.',
            ),
            const SizedBox(height: 12),
            if (_erro != null) _ErroBox(texto: _erro!),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_grupos.isEmpty)
              const AtmosEmptyState(
                icon: Icons.groups_outlined,
                title: 'Nenhum conectado cadastrado',
                message:
                    'Depois de criar os grupos no banco, eles aparecem aqui.',
              )
            else
              ..._grupos.map(
                (grupo) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _grupoColor(grupo).withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.diversity_3_outlined,
                          color: _grupoColor(grupo),
                        ),
                      ),
                      title: Text(
                        _grupoTitulo(grupo),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${_generoLabel(grupo.genero)} • ${grupo.totalMembros} adolescentes',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConectadoDetalheScreen(
                              grupo: grupo,
                            ),
                          ),
                        );
                        if (mounted) _carregar();
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ConectadoDetalheScreen extends StatefulWidget {
  final ConectadoGrupo grupo;

  const ConectadoDetalheScreen({
    super.key,
    required this.grupo,
  });

  @override
  State<ConectadoDetalheScreen> createState() => _ConectadoDetalheScreenState();
}

class _ConectadoDetalheScreenState extends State<ConectadoDetalheScreen> {
  late DateTime _dataEncontro;
  bool _carregando = true;
  bool _salvando = false;
  String? _erro;
  ConectadoEncontro? _encontro;
  List<ConectadoMembro> _membros = const [];
  Set<String> _presentes = {};

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _dataEncontro = DateTime(hoje.year, hoje.month, hoje.day);
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final encontro = await GoogleSheetsApi.ensureConectadoEncontro(
        grupoId: widget.grupo.id,
        dataEncontro: _dataEncontro,
      );
      final membros = await GoogleSheetsApi.fetchConectadosMembros(
        grupoId: widget.grupo.id,
      );
      final presentes = await GoogleSheetsApi.fetchConectadoPresencas(
        encontroId: encontro.id,
      );

      if (mounted) {
        setState(() {
          _encontro = encontro;
          _membros = membros;
          _presentes = presentes;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao carregar encontro: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _selecionarData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _dataEncontro,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada == null) return;
    setState(() {
      _dataEncontro = DateTime(
        selecionada.year,
        selecionada.month,
        selecionada.day,
      );
    });
    await _carregar();
  }

  Future<void> _alternarPresenca(ConectadoMembro membro) async {
    final encontro = _encontro;
    if (encontro == null || _salvando) return;

    final adolescenteId = membro.adolescente.id;
    final jaPresente = _presentes.contains(adolescenteId);
    setState(() => _salvando = true);

    try {
      if (jaPresente) {
        await GoogleSheetsApi.removerConectadoPresenca(
          encontroId: encontro.id,
          adolescenteId: adolescenteId,
        );
        setState(() => _presentes.remove(adolescenteId));
      } else {
        await GoogleSheetsApi.registrarConectadoPresenca(
          encontroId: encontro.id,
          adolescenteId: adolescenteId,
        );
        setState(() => _presentes.add(adolescenteId));
      }
    } catch (e) {
      _mostrarMensagem('Erro ao atualizar presenca: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _adicionarExistente() async {
    final adolescentes = await GoogleSheetsApi.fetchAdolescentes();
    if (!mounted) return;

    final membroIds = _membros.map((m) => m.adolescente.id).toSet();
    final escolhido = await _selecionarAdolescente(
      adolescentes.where((a) => !membroIds.contains(a.id)).toList(),
      titulo: 'Adicionar adolescente',
      vazio: 'Todos os adolescentes ativos ja estao neste conectado.',
    );

    if (escolhido == null) return;
    await _adicionarAoGrupo(escolhido);
  }

  Future<void> _adicionarAoGrupo(Adolescente adolescente) async {
    try {
      await GoogleSheetsApi.adicionarAdolescenteAoConectado(
        grupoId: widget.grupo.id,
        adolescenteId: adolescente.id,
      );
      _mostrarMensagem('${adolescente.nome} adicionado ao conectado.');
      await _carregar();
    } catch (e) {
      _mostrarMensagem('Erro ao adicionar: $e');
    }
  }

  Future<void> _transferir(ConectadoMembro membro) async {
    final grupos = await GoogleSheetsApi.fetchConectadosGrupos();
    if (!mounted) return;

    final destino = await showModalBottomSheet<ConectadoGrupo>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        shrinkWrap: true,
        children: [
          const AtmosSectionTitle(
            title: 'Transferir para',
            subtitle: 'O historico de presenca anterior sera preservado.',
          ),
          const SizedBox(height: 12),
          ...grupos.where((grupo) => grupo.id != widget.grupo.id).map(
                (grupo) => Card(
                  child: ListTile(
                    title: Text(grupo.nome),
                    subtitle: Text(_grupoSubtitulo(grupo)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(context, grupo),
                  ),
                ),
              ),
        ],
      ),
    );

    if (destino == null) return;

    try {
      await GoogleSheetsApi.transferirAdolescenteConectado(
        adolescenteId: membro.adolescente.id,
        grupoDestinoId: destino.id,
      );
      _mostrarMensagem('${membro.adolescente.nome} transferido.');
      await _carregar();
    } catch (e) {
      _mostrarMensagem('Erro ao transferir: $e');
    }
  }

  Future<Adolescente?> _selecionarAdolescente(
    List<Adolescente> adolescentes, {
    required String titulo,
    required String vazio,
  }) {
    return showModalBottomSheet<Adolescente>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AdolescentePicker(
        titulo: titulo,
        vazio: vazio,
        adolescentes: adolescentes,
      ),
    );
  }

  Future<void> _exportarPdf() async {
    try {
      final presentes = _membros
          .where((membro) => _presentes.contains(membro.adolescente.id))
          .toList()
        ..sort(
          (a, b) => a.adolescente.nome.compareTo(b.adolescente.nome),
        );
      final faltantes = _membros
          .where((membro) => !_presentes.contains(membro.adolescente.id))
          .toList()
        ..sort(
          (a, b) => a.adolescente.nome.compareTo(b.adolescente.nome),
        );

      final pdf = pw.Document();
      final fontRegular = await _loadPdfFont(
        'assets/Roboto-Regular.ttf',
        fallback: pw.Font.helvetica(),
      );
      final fontBold = await _loadPdfFont(
        'assets/Roboto-Bold.ttf',
        fallback: pw.Font.helveticaBold(),
      );
      final logoBytes = await _loadAssetBytes('assets/LOGO.png');
      final dataTexto = DateFormat('dd/MM/yyyy').format(_dataEncontro);
      final geradoEm = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      final grupoColor = PdfColor.fromInt(_grupoColor(widget.grupo).value);

      final titleStyle = pw.TextStyle(font: fontBold, fontSize: 18);
      final subtitleStyle = pw.TextStyle(font: fontRegular, fontSize: 11);
      final sectionStyle = pw.TextStyle(font: fontBold, fontSize: 14);
      final headerStyle = pw.TextStyle(font: fontBold, fontSize: 11);
      final rowStyle = pw.TextStyle(font: fontRegular, fontSize: 10);

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.all(24),
            theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          ),
          header: (_) => pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoBytes != null)
                pw.Container(
                  width: 36,
                  height: 36,
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Relatorio de Conectados', style: titleStyle),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${widget.grupo.nome} • $dataTexto',
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
              pw.Text('Gerado: $geradoEm', style: subtitleStyle),
            ],
          ),
          footer: (ctx) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Pagina ${ctx.pageNumber}/${ctx.pagesCount}',
              style: subtitleStyle,
            ),
          ),
          build: (_) => [
            pw.SizedBox(height: 14),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: grupoColor, width: 1.2),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(widget.grupo.nome, style: sectionStyle),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Responsavel: ${_emptyDash(widget.grupo.responsavel)}',
                    style: subtitleStyle,
                  ),
                  pw.Text(
                    'Cor: ${_emptyDash(widget.grupo.corNome)} • ${_generoLabel(widget.grupo.genero)}',
                    style: subtitleStyle,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total: ${_membros.length}', style: headerStyle),
                      pw.Text('Presentes: ${presentes.length}',
                          style: headerStyle),
                      pw.Text('Faltantes: ${faltantes.length}',
                          style: headerStyle),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Text('Presentes', style: sectionStyle),
            pw.SizedBox(height: 8),
            _pdfTabelaMembros(presentes, headerStyle, rowStyle),
            pw.SizedBox(height: 18),
            pw.Text('Faltantes', style: sectionStyle),
            pw.SizedBox(height: 8),
            _pdfTabelaMembros(faltantes, headerStyle, rowStyle),
          ],
        ),
      );

      final bytes = await pdf.save();
      final fileName =
          'conectados_${_slug(widget.grupo.nome)}_${DateFormat('yyyy-MM-dd').format(_dataEncontro)}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      _mostrarMensagem('PDF gerado: $fileName');
    } catch (e) {
      _mostrarMensagem('Falha ao gerar PDF: $e');
    }
  }

  Future<pw.Font> _loadPdfFont(String asset, {required pw.Font fallback}) async {
    try {
      final data = await rootBundle.load(asset);
      return pw.Font.ttf(data);
    } catch (_) {
      return fallback;
    }
  }

  Future<Uint8List?> _loadAssetBytes(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  pw.Widget _pdfTabelaMembros(
    List<ConectadoMembro> membros,
    pw.TextStyle headerStyle,
    pw.TextStyle rowStyle,
  ) {
    if (membros.isEmpty) {
      return pw.Text('Nenhum adolescente nesta lista.', style: rowStyle);
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
      columnWidths: {
        0: const pw.FixedColumnWidth(32),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.6),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pdfCell('#', headerStyle),
            _pdfCell('Nome', headerStyle),
            _pdfCell('Telefone', headerStyle),
          ],
        ),
        ...List.generate(membros.length, (index) {
          final adolescente = membros[index].adolescente;
          return pw.TableRow(
            children: [
              _pdfCell('${index + 1}', rowStyle),
              _pdfCell(adolescente.nome, rowStyle),
              _pdfCell(_emptyDash(adolescente.telefone), rowStyle),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: style),
    );
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  bool get _ultimaSemanaDoMes {
    final ultimoDia = DateTime(_dataEncontro.year, _dataEncontro.month + 1, 0);
    return _dataEncontro.day > ultimoDia.day - 7;
  }

  @override
  Widget build(BuildContext context) {
    final dataTexto = DateFormat('dd/MM/yyyy').format(_dataEncontro);
    final totalPresentes =
        _membros.where((m) => _presentes.contains(m.adolescente.id)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grupo.nome),
        actions: [
          IconButton(
            tooltip: 'Data do encontro',
            icon: const Icon(Icons.calendar_month),
            onPressed: _carregando ? null : _selecionarData,
          ),
          IconButton(
            tooltip: 'Exportar PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _carregando || _membros.isEmpty ? null : _exportarPdf,
          ),
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _carregando ? null : _carregar,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            AtmosInfoHeader(
              icon: Icons.diversity_3_outlined,
              title: widget.grupo.nome,
              subtitle: 'Encontro em $dataTexto • $totalPresentes presentes',
            ),
            if (_ultimaSemanaDoMes) ...[
              const SizedBox(height: 12),
              const _AvisoUltimaSemana(),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _carregando ? null : _adicionarExistente,
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Adicionar adolescente existente'),
              ),
            ),
            const SizedBox(height: 12),
            if (_erro != null) _ErroBox(texto: _erro!),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_membros.isEmpty)
              const AtmosEmptyState(
                icon: Icons.person_off_outlined,
                title: 'Sem adolescentes neste conectado',
                message:
                    'Cadastre o adolescente pelo menu principal e depois adicione aqui no conectado.',
              )
            else
              ..._membros.map(
                (membro) {
                  final presente = _presentes.contains(membro.adolescente.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      color: presente ? BrandColors.successSoft : Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: presente
                              ? BrandColors.success
                              : BrandColors.background,
                          child: Icon(
                            presente ? Icons.check : Icons.person_outline,
                            color: presente ? Colors.white : BrandColors.navy,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          membro.adolescente.nome,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          membro.adolescente.telefone?.trim().isEmpty ?? true
                              ? 'Sem telefone'
                              : membro.adolescente.telefone!,
                        ),
                        trailing: Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              tooltip: 'Transferir',
                              icon: const Icon(Icons.swap_horiz),
                              onPressed: () => _transferir(membro),
                            ),
                            Checkbox(
                              value: presente,
                              activeColor: BrandColors.success,
                              onChanged: _salvando
                                  ? null
                                  : (_) => _alternarPresenca(membro),
                            ),
                          ],
                        ),
                        onTap:
                            _salvando ? null : () => _alternarPresenca(membro),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AdolescentePicker extends StatefulWidget {
  final String titulo;
  final String vazio;
  final List<Adolescente> adolescentes;

  const _AdolescentePicker({
    required this.titulo,
    required this.vazio,
    required this.adolescentes,
  });

  @override
  State<_AdolescentePicker> createState() => _AdolescentePickerState();
}

class _AdolescentePickerState extends State<_AdolescentePicker> {
  final _buscaCtrl = TextEditingController();

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busca = _normalizar(_buscaCtrl.text);
    final visiveis = widget.adolescentes
        .where((a) => _normalizar(a.nome).contains(busca))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AtmosSectionTitle(title: widget.titulo),
            const SizedBox(height: 12),
            TextField(
              controller: _buscaCtrl,
              decoration: const InputDecoration(
                labelText: 'Buscar por nome',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: visiveis.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.vazio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: BrandColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: visiveis.length,
                      itemBuilder: (context, index) {
                        final adolescente = visiveis[index];
                        return Card(
                          child: ListTile(
                            title: Text(adolescente.nome),
                            subtitle:
                                adolescente.telefone?.trim().isEmpty ?? true
                                    ? null
                                    : Text(adolescente.telefone!),
                            trailing: const Icon(Icons.add),
                            onTap: () => Navigator.pop(context, adolescente),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoUltimaSemana extends StatelessWidget {
  const _AvisoUltimaSemana();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrandColors.warningSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrandColors.yellow.withOpacity(0.45)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: BrandColors.navy),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta data cai na ultima semana do mes, quando normalmente acontece o encontro geral. O registro continua liberado.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ErroBox extends StatelessWidget {
  final String texto;

  const _ErroBox({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrandColors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texto, style: const TextStyle(color: BrandColors.red)),
    );
  }
}

String _grupoTitulo(ConectadoGrupo grupo) {
  final responsavel = grupo.responsavel.trim();
  if (responsavel.isEmpty) return grupo.nome;
  return '${grupo.nome} • $responsavel';
}

String _grupoSubtitulo(ConectadoGrupo grupo) {
  final partes = <String>[
    _generoLabel(grupo.genero),
    if (grupo.corNome.trim().isNotEmpty) grupo.corNome.trim(),
    '${grupo.totalMembros} adolescentes',
  ];
  return partes.join(' • ');
}

Color _grupoColor(ConectadoGrupo grupo) {
  final hex = grupo.corHex.trim().replaceAll('#', '');
  if (hex.length == 6) {
    final value = int.tryParse('FF$hex', radix: 16);
    if (value != null) return Color(value);
  }

  switch (grupo.corNome.toLowerCase().trim()) {
    case 'vermelho':
      return BrandColors.red;
    case 'azul':
      return const Color(0xFF2F80ED);
    case 'roxo':
      return const Color(0xFF7B2CBF);
    case 'amarelo':
      return BrandColors.yellow;
    case 'rosa':
      return BrandColors.magenta;
    case 'preto':
      return BrandColors.navy;
    default:
      return BrandColors.magenta;
  }
}

String _emptyDash(String? value) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? '-' : text;
}

String _slug(String value) {
  return _normalizar(value)
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

String _generoLabel(String genero) {
  switch (genero.toLowerCase()) {
    case 'meninos':
    case 'masculino':
      return 'Meninos';
    case 'meninas':
    case 'feminino':
      return 'Meninas';
    default:
      return genero.isEmpty ? 'Grupo' : genero;
  }
}

String _normalizar(String value) {
  const from = 'áàâãäÁÀÂÃÄéèêëÉÈÊËíìîïÍÌÎÏóòôõöÓÒÔÕÖúùûüÚÙÛÜçÇñÑ';
  const to = 'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUcCnN';
  var out = value.toLowerCase().trim();
  for (var i = 0; i < from.length && i < to.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out;
}
