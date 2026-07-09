import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/relatorio_gerencial.dart';
import '../services/google_sheets_api.dart';
import '../theme/brand_colors.dart';
import '../widgets/atmos_ui.dart';

class RelatorioGerencialScreen extends StatefulWidget {
  const RelatorioGerencialScreen({super.key});

  @override
  State<RelatorioGerencialScreen> createState() =>
      _RelatorioGerencialScreenState();
}

class _RelatorioGerencialScreenState extends State<RelatorioGerencialScreen> {
  late DateTime _mesSelecionado;
  bool _carregando = true;
  String? _erro;
  RelatorioGerencial? _relatorio;

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
      final relatorio = await GoogleSheetsApi.fetchRelatorioGerencial(
        mes: _mesSelecionado,
      );
      if (mounted) setState(() => _relatorio = relatorio);
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao gerar relatório: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _selecionarMes() async {
    final escolhido = await showDatePicker(
      context: context,
      initialDate: _mesSelecionado,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Selecione qualquer dia do mês',
      cancelText: 'Cancelar',
      confirmText: 'Selecionar',
    );

    if (escolhido == null) return;
    setState(() => _mesSelecionado = DateTime(escolhido.year, escolhido.month));
    await _carregar();
  }

  Future<void> _abrirWhatsapp(String? telefone) async {
    final numero = _numeroWhatsapp(telefone);
    if (numero == null) {
      _mostrarMensagem('Telefone não informado para este adolescente.');
      return;
    }

    final url = Uri.parse('https://wa.me/$numero');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _mostrarMensagem('Não foi possível abrir o WhatsApp.');
    }
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  String? _numeroWhatsapp(String? telefone) {
    var nums = (telefone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (nums.isEmpty) return null;
    if (nums.length == 10 || nums.length == 11) nums = '55$nums';
    if (!nums.startsWith('55')) nums = '55$nums';
    return nums;
  }

  @override
  Widget build(BuildContext context) {
    final relatorio = _relatorio;
    final tituloMes = DateFormat('MMMM/yyyy', 'pt_BR').format(_mesSelecionado);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório Gerencial'),
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
              icon: Icons.manage_accounts,
              title: 'Acompanhamento mensal',
              subtitle:
                  'Adolescentes com mais de 50% de faltas nos encontros do mês.',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _carregando ? null : _selecionarMes,
              icon: const Icon(Icons.calendar_month),
              label: Text('Mês: ${_capitalizar(tituloMes)}'),
            ),
            const SizedBox(height: 12),
            if (_erro != null) _ErroBox(texto: _erro!),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (relatorio != null) ...[
              _Resumo(relatorio: relatorio),
              const SizedBox(height: 12),
              if (relatorio.totalEventos == 0)
                const AtmosEmptyState(
                  icon: Icons.event_busy,
                  title: 'Nenhum encontro encontrado',
                  message:
                      'Ainda não há eventos registrados para o mês selecionado.',
                )
              else if (relatorio.itens.isEmpty)
                const AtmosEmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'Frequência dentro do esperado',
                  message:
                      'Nenhum adolescente faltou mais de 50% dos encontros desse mês.',
                )
              else
                _TabelaGerencial(
                  itens: relatorio.itens,
                  onWhatsapp: _abrirWhatsapp,
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

class _Resumo extends StatelessWidget {
  final RelatorioGerencial relatorio;

  const _Resumo({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: _ResumoItem(
                titulo: 'Encontros',
                valor: relatorio.totalEventos.toString(),
              ),
            ),
            Container(width: 1, height: 40, color: BrandColors.divider),
            Expanded(
              child: _ResumoItem(
                titulo: 'Acompanhar',
                valor: relatorio.itens.length.toString(),
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

  const _ResumoItem({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: BrandColors.navy,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(titulo, style: const TextStyle(color: BrandColors.textMuted)),
      ],
    );
  }
}

class _TabelaGerencial extends StatelessWidget {
  final List<RelatorioGerencialItem> itens;
  final ValueChanged<String?> onWhatsapp;

  const _TabelaGerencial({
    required this.itens,
    required this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(BrandColors.navy),
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        columns: const [
          DataColumn(label: Text('Adolescente')),
          DataColumn(label: Text('Telefone')),
          DataColumn(label: Text('Faltas')),
          DataColumn(label: Text('%')),
          DataColumn(label: Text('WhatsApp')),
        ],
        rows: itens.map((item) {
          final telefone = item.adolescente.telefone?.trim() ?? '';
          final temTelefone = telefone.isNotEmpty;
          return DataRow(
            cells: [
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    item.adolescente.nome,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(temTelefone ? telefone : '-')),
              DataCell(Text('${item.faltas}/${item.totalEventos}')),
              DataCell(Text(_percent(item.percentualFaltas))),
              DataCell(
                IconButton(
                  tooltip:
                      temTelefone ? 'Abrir WhatsApp' : 'Telefone não informado',
                  icon: Image.asset(
                    'assets/whatsapp.png',
                    width: 22,
                    height: 22,
                  ),
                  onPressed: temTelefone
                      ? () => onWhatsapp(item.adolescente.telefone)
                      : null,
                ),
              ),
            ],
          );
        }).toList(),
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

String _percent(double value) => '${(value * 100).round()}%';
