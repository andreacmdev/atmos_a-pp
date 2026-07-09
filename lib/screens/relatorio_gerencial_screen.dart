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

  Future<void> _abrirWhatsapp(String? telefone) async {
    final numero = _numeroWhatsapp(telefone);
    if (numero == null) {
      _mostrarMensagem('Telefone nao informado para este adolescente.');
      return;
    }

    final url = Uri.parse('https://wa.me/$numero');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _mostrarMensagem('Nao foi possivel abrir o WhatsApp.');
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
        title: const Text('Relatorio Gerencial'),
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
                  'Adolescentes com mais de 50% de faltas nos encontros do mes.',
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
              _Resumo(relatorio: relatorio),
              const SizedBox(height: 12),
              if (relatorio.totalEventos == 0)
                const AtmosEmptyState(
                  icon: Icons.event_busy,
                  title: 'Nenhum encontro encontrado',
                  message:
                      'Ainda nao ha eventos registrados para o mes selecionado.',
                )
              else if (relatorio.itens.isEmpty)
                const AtmosEmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'Frequencia dentro do esperado',
                  message:
                      'Nenhum adolescente faltou mais de 50% dos encontros desse mes.',
                )
              else
                _ListaGerencial(
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

class _ListaGerencial extends StatelessWidget {
  final List<RelatorioGerencialItem> itens;
  final ValueChanged<String?> onWhatsapp;

  const _ListaGerencial({
    required this.itens,
    required this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: itens
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GerencialCard(item: item, onWhatsapp: onWhatsapp),
            ),
          )
          .toList(),
    );
  }
}

class _GerencialCard extends StatelessWidget {
  final RelatorioGerencialItem item;
  final ValueChanged<String?> onWhatsapp;

  const _GerencialCard({
    required this.item,
    required this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    final telefone = item.adolescente.telefone?.trim() ?? '';
    final temTelefone = telefone.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.adolescente.nome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: BrandColors.navy,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                _PercentBadge(value: item.percentualFaltas),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.event_busy,
                  label: '${item.faltas}/${item.totalEventos} faltas',
                ),
                _InfoChip(
                  icon: Icons.phone,
                  label: temTelefone ? telefone : 'Sem telefone',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: temTelefone
                    ? () => onWhatsapp(item.adolescente.telefone)
                    : null,
                icon: Image.asset(
                  'assets/whatsapp.png',
                  width: 20,
                  height: 20,
                ),
                label: Text(
                  temTelefone ? 'Chamar no WhatsApp' : 'Telefone nao informado',
                ),
              ),
            ),
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
        color: BrandColors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _percent(value),
        style: const TextStyle(
          color: BrandColors.red,
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
