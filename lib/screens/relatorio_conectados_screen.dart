import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/conectado.dart';
import '../models/relatorio_conectados.dart';
import '../services/google_sheets_api.dart';
import '../theme/brand_colors.dart';
import '../widgets/atmos_ui.dart';

class RelatorioConectadosScreen extends StatefulWidget {
  const RelatorioConectadosScreen({super.key});

  @override
  State<RelatorioConectadosScreen> createState() =>
      _RelatorioConectadosScreenState();
}

class _RelatorioConectadosScreenState
    extends State<RelatorioConectadosScreen> {
  late DateTime _mesSelecionado;
  bool _carregando = true;
  String? _erro;
  RelatorioConectados? _relatorio;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _mesSelecionado = DateTime(hoje.year, hoje.month);
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final relatorio = await GoogleSheetsApi.fetchRelatorioConectados(
        mes: _mesSelecionado,
      );
      if (mounted) setState(() => _relatorio = relatorio);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao gerar relatorio: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _selecionarMes() async {
    final escolhido = await showDialog<DateTime>(
      context: context,
      builder: (_) => _MonthPickerDialog(mesInicial: _mesSelecionado),
    );

    if (escolhido == null) return;
    setState(() => _mesSelecionado = escolhido);
    await _carregar();
  }

  Future<void> _exportarPdf() async {
    final relatorio = _relatorio;
    if (relatorio == null) return;

    try {
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
      final mesTexto = _capitalizar(
        DateFormat('MMMM/yyyy', 'pt_BR').format(_mesSelecionado),
      );
      final geradoEm = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

      final titleStyle = pw.TextStyle(font: fontBold, fontSize: 18);
      final subtitleStyle = pw.TextStyle(font: fontRegular, fontSize: 10);
      final sectionStyle = pw.TextStyle(font: fontBold, fontSize: 13);
      final headerStyle = pw.TextStyle(font: fontBold, fontSize: 9);
      final rowStyle = pw.TextStyle(font: fontRegular, fontSize: 8);

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.all(22),
            theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          ),
          header: (_) => pw.Row(
            children: [
              if (logoBytes != null)
                pw.Container(
                  width: 34,
                  height: 34,
                  margin: const pw.EdgeInsets.only(right: 10),
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Relatorio Conectados', style: titleStyle),
                    pw.Text('Mes: $mesTexto', style: subtitleStyle),
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
            pw.SizedBox(height: 12),
            _pdfResumo(relatorio, sectionStyle, subtitleStyle),
            pw.SizedBox(height: 16),
            ...relatorio.grupos.expand((grupo) {
              return [
                _pdfGrupoResumo(grupo, sectionStyle, subtitleStyle),
                pw.SizedBox(height: 8),
                _pdfTabelaGrupo(grupo, headerStyle, rowStyle),
                pw.SizedBox(height: 18),
              ];
            }),
          ],
        ),
      );

      final bytes = await pdf.save();
      final fileName =
          'relatorio_conectados_${DateFormat('yyyy-MM').format(_mesSelecionado)}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      _mostrarMensagem('PDF gerado: $fileName');
    } catch (e) {
      _mostrarMensagem('Falha ao gerar PDF: $e');
    }
  }

  pw.Widget _pdfResumo(
    RelatorioConectados relatorio,
    pw.TextStyle sectionStyle,
    pw.TextStyle textStyle,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Panorama geral', style: sectionStyle),
          pw.SizedBox(height: 6),
          pw.Text(
            'Grupos: ${relatorio.totalGrupos} • Encontros: ${relatorio.totalEncontros} • Frequencia geral: ${_percent(relatorio.percentualGeral)}',
            style: textStyle,
          ),
          pw.Text(
            'Presencas: ${relatorio.totalPresencas}/${relatorio.totalPossiveis}',
            style: textStyle,
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfGrupoResumo(
    RelatorioConectadoGrupo grupo,
    pw.TextStyle sectionStyle,
    pw.TextStyle textStyle,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(_grupoColor(grupo.grupo).value),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            grupo.grupo.nome,
            style: sectionStyle.copyWith(color: PdfColors.white),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            'Responsavel: ${_emptyDash(grupo.grupo.responsavel)} • Encontros: ${grupo.encontros.length} • Membros: ${grupo.membros.length} • Frequencia: ${_percent(grupo.percentual)}',
            style: textStyle.copyWith(color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTabelaGrupo(
    RelatorioConectadoGrupo grupo,
    pw.TextStyle headerStyle,
    pw.TextStyle rowStyle,
  ) {
    if (grupo.encontros.isEmpty) {
      return pw.Text('Nenhum encontro registrado neste mes.', style: rowStyle);
    }

    if (grupo.membros.isEmpty) {
      return pw.Text('Nenhum membro ativo neste conectado.', style: rowStyle);
    }

    final dateColumns = {
      for (final encontro in grupo.encontros)
        encontro.id: DateFormat('dd/MM').format(encontro.dataEncontro),
    };

    return pw.Table(
      border: pw.TableBorder.all(width: 0.4, color: PdfColors.grey600),
      columnWidths: {
        0: const pw.FixedColumnWidth(26),
        1: const pw.FlexColumnWidth(2.2),
        for (var i = 0; i < grupo.encontros.length; i++)
          i + 2: const pw.FixedColumnWidth(34),
        grupo.encontros.length + 2: const pw.FixedColumnWidth(34),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pdfCell('#', headerStyle),
            _pdfCell('Nome', headerStyle),
            ...dateColumns.values.map((date) => _pdfCell(date, headerStyle)),
            _pdfCell('%', headerStyle),
          ],
        ),
        ...List.generate(grupo.membros.length, (index) {
          final membro = grupo.membros[index];
          final percentual = grupo.encontros.isEmpty
              ? 0.0
              : membro.presencas / grupo.encontros.length;
          return pw.TableRow(
            children: [
              _pdfCell('${index + 1}', rowStyle),
              _pdfCell(membro.adolescente.nome, rowStyle),
              ...grupo.encontros.map((encontro) {
                final presente = membro.presencasPorEncontro[encontro.id] == true;
                return _pdfCell(presente ? 'P' : 'F', rowStyle);
              }),
              _pdfCell(_percent(percentual), rowStyle),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: style),
    );
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

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final relatorio = _relatorio;
    final tituloMes = DateFormat('MMMM/yyyy', 'pt_BR').format(_mesSelecionado);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatorio Conectados'),
        actions: [
          IconButton(
            tooltip: 'Exportar PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _carregando || relatorio == null ? null : _exportarPdf,
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
            const AtmosInfoHeader(
              icon: Icons.insert_chart_outlined,
              title: 'Panorama dos Conectados',
              subtitle:
                  'Resumo mensal por grupo e PDF com presencas por encontro.',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _carregando ? null : _selecionarMes,
              icon: const Icon(Icons.calendar_month),
              label: Text('Mes: ${_capitalizar(tituloMes)}'),
            ),
            const SizedBox(height: 12),
            if (_erro != null) _ErroBox(texto: _erro!),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (relatorio != null) ...[
              _ResumoGeral(relatorio: relatorio),
              const SizedBox(height: 12),
              if (relatorio.grupos.isEmpty)
                const AtmosEmptyState(
                  icon: Icons.groups_outlined,
                  title: 'Nenhum conectado encontrado',
                  message: 'Cadastre os grupos para visualizar o relatorio.',
                )
              else
                ...relatorio.grupos.map(
                  (grupo) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _GrupoRelatorioCard(
                      grupo: grupo,
                      mes: _mesSelecionado,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _capitalizar(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _ResumoGeral extends StatelessWidget {
  final RelatorioConectados relatorio;

  const _ResumoGeral({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: _ResumoItem(
                titulo: 'Grupos',
                valor: relatorio.totalGrupos.toString(),
              ),
            ),
            Container(width: 1, height: 42, color: BrandColors.divider),
            Expanded(
              child: _ResumoItem(
                titulo: 'Encontros',
                valor: relatorio.totalEncontros.toString(),
              ),
            ),
            Container(width: 1, height: 42, color: BrandColors.divider),
            Expanded(
              child: _ResumoItem(
                titulo: 'Geral',
                valor: _percent(relatorio.percentualGeral),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  final String titulo;
  final String valor;

  const _ResumoItem({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: BrandColors.navy,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(color: BrandColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _GrupoRelatorioCard extends StatelessWidget {
  final RelatorioConectadoGrupo grupo;
  final DateTime mes;

  const _GrupoRelatorioCard({
    required this.grupo,
    required this.mes,
  });

  @override
  Widget build(BuildContext context) {
    final color = _grupoColor(grupo.grupo);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _RelatorioConectadoDetalheScreen(
                grupo: grupo,
                mes: mes,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.diversity_3_outlined, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grupo.grupo.nome,
                          style: const TextStyle(
                            color: BrandColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _emptyDash(grupo.grupo.responsavel),
                          style: const TextStyle(color: BrandColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  _PercentBadge(value: grupo.percentual),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: BrandColors.textMuted),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.event_available,
                    label: '${grupo.encontros.length} encontros',
                  ),
                  _InfoChip(
                    icon: Icons.people_outline,
                    label: '${grupo.membros.length} membros',
                  ),
                  _InfoChip(
                    icon: Icons.check_circle_outline,
                    label:
                        '${grupo.presencas}/${grupo.totalPossivel} presencas',
                  ),
                  const _InfoChip(
                    icon: Icons.touch_app_outlined,
                    label: 'ver detalhes',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelatorioConectadoDetalheScreen extends StatelessWidget {
  final RelatorioConectadoGrupo grupo;
  final DateTime mes;

  const _RelatorioConectadoDetalheScreen({
    required this.grupo,
    required this.mes,
  });

  @override
  Widget build(BuildContext context) {
    final color = _grupoColor(grupo.grupo);
    final mesTexto = _capitalizar(DateFormat('MMMM/yyyy', 'pt_BR').format(mes));
    final membrosOrdenados = [...grupo.membros]
      ..sort((a, b) {
        final byFrequencia =
            _membroPercentual(a, grupo.encontros).compareTo(
          _membroPercentual(b, grupo.encontros),
        );
        if (byFrequencia != 0) return byFrequencia;
        return a.adolescente.nome.compareTo(b.adolescente.nome);
      });

    return Scaffold(
      appBar: AppBar(title: Text(grupo.grupo.nome)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grupo.grupo.nome,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lider: ${_emptyDash(grupo.grupo.responsavel)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Mes: $mesTexto',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ResumoDetalhado(grupo: grupo),
          const SizedBox(height: 16),
          Text(
            'Encontros do mes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (grupo.encontros.isEmpty)
            const AtmosEmptyState(
              icon: Icons.event_busy,
              title: 'Sem encontros no mes',
              message: 'Quando houver encontros registrados, eles aparecem aqui.',
            )
          else
            ...grupo.encontros.map((encontro) {
              final presentes = grupo.membros
                  .where((m) => m.presencasPorEncontro[encontro.id] == true)
                  .length;
              return _EncontroDetalheTile(
                encontro: encontro,
                presentes: presentes,
                total: grupo.membros.length,
              );
            }),
          const SizedBox(height: 16),
          Text(
            'Adolescentes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (membrosOrdenados.isEmpty)
            const AtmosEmptyState(
              icon: Icons.people_outline,
              title: 'Sem membros ativos',
              message: 'Nenhum adolescente ativo neste conectado.',
            )
          else
            ...membrosOrdenados.map(
              (membro) => _MembroDetalheCard(
                membro: membro,
                encontros: grupo.encontros,
              ),
            ),
        ],
      ),
    );
  }
}

class _ResumoDetalhado extends StatelessWidget {
  final RelatorioConectadoGrupo grupo;

  const _ResumoDetalhado({required this.grupo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ResumoMiniCard(label: 'Membros', value: '${grupo.membros.length}'),
            _ResumoMiniCard(
              label: 'Encontros',
              value: '${grupo.encontros.length}',
            ),
            _ResumoMiniCard(
              label: 'Presencas',
              value: '${grupo.presencas}',
            ),
            _ResumoMiniCard(label: 'Faltas', value: '${grupo.faltas}'),
            _ResumoMiniCard(label: 'Frequencia', value: _percent(grupo.percentual)),
          ],
        ),
      ),
    );
  }
}

class _ResumoMiniCard extends StatelessWidget {
  final String label;
  final String value;

  const _ResumoMiniCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: BrandColors.navy,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: BrandColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EncontroDetalheTile extends StatelessWidget {
  final ConectadoEncontro encontro;
  final int presentes;
  final int total;

  const _EncontroDetalheTile({
    required this.encontro,
    required this.presentes,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentual = total == 0 ? 0.0 : presentes / total;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event_available, color: BrandColors.magenta),
        title: Text(DateFormat('dd/MM/yyyy').format(encontro.dataEncontro)),
        subtitle: Text('$presentes de $total presentes'),
        trailing: _PercentBadge(value: percentual),
      ),
    );
  }
}

class _MembroDetalheCard extends StatelessWidget {
  final RelatorioConectadoMembro membro;
  final List<ConectadoEncontro> encontros;

  const _MembroDetalheCard({
    required this.membro,
    required this.encontros,
  });

  @override
  Widget build(BuildContext context) {
    final percentual = _membroPercentual(membro, encontros);
    final faltas = encontros.length - membro.presencas;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    membro.adolescente.nome,
                    style: const TextStyle(
                      color: BrandColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _PercentBadge(value: percentual),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.check_circle_outline,
                  label: '${membro.presencas} presencas',
                ),
                _InfoChip(
                  icon: Icons.cancel_outlined,
                  label: '$faltas faltas',
                ),
              ],
            ),
            if (encontros.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: encontros.map((encontro) {
                  final presente =
                      membro.presencasPorEncontro[encontro.id] == true;
                  final color = presente ? BrandColors.success : BrandColors.red;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: presente
                          ? BrandColors.successSoft
                          : BrandColors.dangerSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${DateFormat('dd/MM').format(encontro.dataEncontro)} ${presente ? 'P' : 'F'}',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  final double value;

  const _PercentBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BrandColors.magenta.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _percent(value),
        style: const TextStyle(
          color: BrandColors.magenta,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: BrandColors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: BrandColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime mesInicial;

  const _MonthPickerDialog({required this.mesInicial});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _ano;
  late int _mes;

  @override
  void initState() {
    super.initState();
    _ano = widget.mesInicial.year;
    _mes = widget.mesInicial.month;
  }

  bool _mesNoFuturo(int mes) {
    final agora = DateTime.now();
    return _ano > agora.year || (_ano == agora.year && mes > agora.month);
  }

  @override
  Widget build(BuildContext context) {
    final meses = List.generate(
      12,
      (index) => DateFormat.MMM('pt_BR').format(DateTime(2024, index + 1)),
    );

    return AlertDialog(
      title: const Text('Selecionar mes'),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Ano anterior',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _ano -= 1),
                ),
                SizedBox(
                  width: 96,
                  child: Center(
                    child: Text(
                      _ano.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: BrandColors.navy,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Proximo ano',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _ano >= DateTime.now().year
                      ? null
                      : () => setState(() => _ano += 1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.35,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final mes = index + 1;
                final selecionado = mes == _mes;
                final desabilitado = _mesNoFuturo(mes);
                return OutlinedButton(
                  onPressed: desabilitado
                      ? null
                      : () {
                          setState(() => _mes = mes);
                          Navigator.of(context).pop(DateTime(_ano, _mes));
                        },
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        selecionado ? BrandColors.magenta : Colors.transparent,
                    foregroundColor:
                        selecionado ? Colors.white : BrandColors.navy,
                    side: BorderSide(
                      color: selecionado
                          ? BrandColors.magenta
                          : BrandColors.divider,
                    ),
                  ),
                  child: Text(
                    _capitalizar(meses[index].replaceAll('.', '')),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  String _capitalizar(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
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

String _percent(double value) => '${(value * 100).round()}%';

double _membroPercentual(
  RelatorioConectadoMembro membro,
  List<ConectadoEncontro> encontros,
) {
  if (encontros.isEmpty) return 0;
  return membro.presencas / encontros.length;
}

String _capitalizar(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
