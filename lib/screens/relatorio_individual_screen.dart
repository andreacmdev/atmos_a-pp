import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/adolescente.dart';
import '../models/relatorio_individual.dart';
import '../services/google_sheets_api.dart';
import '../theme/brand_colors.dart';

class RelatorioIndividualScreen extends StatefulWidget {
  const RelatorioIndividualScreen({super.key});

  @override
  State<RelatorioIndividualScreen> createState() =>
      _RelatorioIndividualScreenState();
}

class _RelatorioIndividualScreenState extends State<RelatorioIndividualScreen> {
  final _buscaCtrl = TextEditingController();
  bool _carregandoLista = true;
  bool _carregandoRelatorio = false;
  String? _erro;
  List<Adolescente> _adolescentes = [];
  Adolescente? _selecionado;
  RelatorioIndividual? _relatorio;

  @override
  void initState() {
    super.initState();
    _carregarAdolescentes();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarAdolescentes() async {
    setState(() {
      _carregandoLista = true;
      _erro = null;
    });

    try {
      final dados = await GoogleSheetsApi.fetchAdolescentes();
      setState(() => _adolescentes = dados);
    } catch (e) {
      setState(() => _erro = 'Erro ao carregar adolescentes: $e');
    } finally {
      if (mounted) setState(() => _carregandoLista = false);
    }
  }

  Future<void> _selecionar(Adolescente adolescente) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _selecionado = adolescente;
      _relatorio = null;
      _erro = null;
      _carregandoRelatorio = true;
      _buscaCtrl.text = adolescente.nome;
    });

    try {
      final relatorio = await GoogleSheetsApi.fetchRelatorioIndividual(
        adolescente: adolescente,
      );
      setState(() => _relatorio = relatorio);
    } catch (e) {
      setState(() => _erro = 'Erro ao gerar relatório: $e');
    } finally {
      if (mounted) setState(() => _carregandoRelatorio = false);
    }
  }

  List<Adolescente> get _filtrados {
    final q = _normalize(_buscaCtrl.text.trim());
    if (q.isEmpty) return _adolescentes.take(12).toList();
    return _adolescentes
        .where((a) => _normalize(a.nome).contains(q))
        .take(20)
        .toList();
  }

  String _normalize(String value) {
    const from = 'áàâãäÁÀÂÃÄéèêëÉÈÊËíìîïÍÌÎÏóòôõöÓÒÔÕÖúùûüÚÙÛÜçÇñÑ';
    const to = 'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUcCnN';
    var out = value.toLowerCase();
    for (var i = 0; i < from.length && i < to.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;

    return Scaffold(
      appBar: AppBar(title: const Text('Relatório Individual')),
      body: RefreshIndicator(
        onRefresh: _carregarAdolescentes,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            TextField(
              controller: _buscaCtrl,
              onChanged: (_) => setState(() {
                _selecionado = null;
                _relatorio = null;
              }),
              decoration: const InputDecoration(
                labelText: 'Pesquisar adolescente',
                hintText: 'Digite parte do nome',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            if (_erro != null) _ErroBox(texto: _erro!),
            if (_carregandoLista)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_selecionado == null)
              _ListaResultados(
                adolescentes: filtrados,
                onTap: _selecionar,
                buscaVazia: _buscaCtrl.text.trim().isEmpty,
              )
            else if (_carregandoRelatorio)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_relatorio != null)
              _RelatorioConteudo(relatorio: _relatorio!),
          ],
        ),
      ),
    );
  }
}

class _ListaResultados extends StatelessWidget {
  final List<Adolescente> adolescentes;
  final ValueChanged<Adolescente> onTap;
  final bool buscaVazia;

  const _ListaResultados({
    required this.adolescentes,
    required this.onTap,
    required this.buscaVazia,
  });

  @override
  Widget build(BuildContext context) {
    if (adolescentes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('Nenhum adolescente encontrado.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          buscaVazia ? 'Toque em um nome recente' : 'Resultados',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...adolescentes.map(
          (adolescente) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              leading: CircleAvatar(
                backgroundColor: BrandColors.navy,
                child: Text(
                  adolescente.nome.isEmpty
                      ? '?'
                      : adolescente.nome[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(adolescente.nome),
              subtitle: adolescente.telefone == null ||
                      adolescente.telefone!.trim().isEmpty
                  ? null
                  : Text(adolescente.telefone!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onTap(adolescente),
            ),
          ),
        ),
      ],
    );
  }
}

class _RelatorioConteudo extends StatelessWidget {
  final RelatorioIndividual relatorio;

  const _RelatorioConteudo({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    final adolescente = relatorio.adolescente;
    final ultima = relatorio.ultimaPresenca;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PessoaHeader(adolescente: adolescente),
        const SizedBox(height: 12),
        _ResumoGrid(relatorio: relatorio),
        const SizedBox(height: 16),
        _AlertaFrequencia(relatorio: relatorio),
        const SizedBox(height: 16),
        _ConectadoResumoCard(conectado: relatorio.conectado),
        const SizedBox(height: 16),
        Text(
          'Participação por evento',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (relatorio.porTipo.isEmpty)
          const Text('Ainda não há eventos cadastrados.')
        else
          ...relatorio.porTipo.map((item) => _TipoBar(item: item)),
        const SizedBox(height: 16),
        Text(
          ultima == null
              ? 'Nunca marcou presença'
              : 'Última presença: ${DateFormat('dd/MM/yyyy').format(ultima.data)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Histórico por evento',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (relatorio.eventos.isEmpty)
          const Text('Nenhum evento encontrado.')
        else
          ...relatorio.eventos.map((evento) => _EventoTile(evento: evento)),
      ],
    );
  }
}

class _PessoaHeader extends StatelessWidget {
  final Adolescente adolescente;

  const _PessoaHeader({required this.adolescente});

  @override
  Widget build(BuildContext context) {
    final idade = _idade(adolescente.dataNascimento);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            adolescente.nome,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (idade != null)
            Text(
              '$idade anos',
              style: const TextStyle(color: Colors.white70),
            ),
          if (adolescente.telefone != null &&
              adolescente.telefone!.trim().isNotEmpty)
            Text(
              adolescente.telefone!,
              style: const TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  int? _idade(DateTime? nascimento) {
    if (nascimento == null) return null;
    final hoje = DateTime.now();
    var idade = hoje.year - nascimento.year;
    final fezAniversario = hoje.month > nascimento.month ||
        (hoje.month == nascimento.month && hoje.day >= nascimento.day);
    if (!fezAniversario) idade--;
    if (idade < 0 || idade > 120) return null;
    return idade;
  }
}

class _ConectadoResumoCard extends StatelessWidget {
  final ConectadoResumoIndividual conectado;

  const _ConectadoResumoCard({required this.conectado});

  @override
  Widget build(BuildContext context) {
    final grupo = conectado.grupoAtual;
    final corGrupo = _colorFromHex(grupo?.corHex) ?? BrandColors.magenta;
    final diasSemIr = conectado.diasSemIr;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: corGrupo.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.groups_2, color: corGrupo),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conectado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        grupo == null ? 'Sem grupo ativo' : grupo.nome,
                        style: TextStyle(
                          color: grupo == null ? Colors.black54 : corGrupo,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (grupo != null && grupo.responsavel.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Lider: ${grupo.responsavel}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            if (conectado.totalEncontros == 0)
              Text(
                grupo == null
                    ? 'Este adolescente ainda nao possui historico nos Conectados.'
                    : 'Ainda nao ha encontros registrados para este adolescente neste historico.',
                style: const TextStyle(color: Colors.black54),
              )
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ConectadoChip(
                    label: 'Presencas',
                    value: conectado.totalPresencas.toString(),
                    color: BrandColors.success,
                  ),
                  _ConectadoChip(
                    label: 'Faltas',
                    value: conectado.totalFaltas.toString(),
                    color: BrandColors.red,
                  ),
                  _ConectadoChip(
                    label: 'Frequencia',
                    value: _percent(conectado.percentualPresenca),
                    color: BrandColors.navy,
                  ),
                  _ConectadoChip(
                    label: 'Sem ir',
                    value: diasSemIr < 0 ? '-' : '${diasSemIr}d',
                    color: BrandColors.yellow,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Historico nos Conectados',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...conectado.encontros.map(
                (encontro) => _ConectadoEncontroTile(encontro: encontro),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConectadoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ConectadoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color == BrandColors.yellow ? BrandColors.navy : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConectadoEncontroTile extends StatelessWidget {
  final ConectadoParticipacaoIndividual encontro;

  const _ConectadoEncontroTile({required this.encontro});

  @override
  Widget build(BuildContext context) {
    final cor = encontro.presente ? BrandColors.success : BrandColors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
            encontro.presente ? BrandColors.successSoft : BrandColors.dangerSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Icon(
            encontro.presente ? Icons.check_circle : Icons.cancel,
            color: cor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(encontro.data),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  encontro.responsavel.trim().isEmpty
                      ? encontro.grupoNome
                      : '${encontro.grupoNome} - ${encontro.responsavel}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            encontro.presente ? 'Presente' : 'Faltou',
            style: TextStyle(color: cor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ResumoGrid extends StatelessWidget {
  final RelatorioIndividual relatorio;

  const _ResumoGrid({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    final diasSemIr = relatorio.diasSemIr;
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ResumoCard(
          titulo: 'Presenças',
          valor: relatorio.totalPresencas.toString(),
          detalhe: '${_percent(relatorio.percentualPresenca)} de frequência',
        ),
        _ResumoCard(
          titulo: 'Faltas',
          valor: relatorio.totalFaltas.toString(),
          detalhe: '${relatorio.faltasSeguidas} seguidas',
        ),
        _ResumoCard(
          titulo: 'Eventos',
          valor: relatorio.totalEventos.toString(),
          detalhe: 'já realizados',
        ),
        _ResumoCard(
          titulo: 'Sem ir',
          valor: diasSemIr < 0 ? '-' : '$diasSemIr d',
          detalhe: diasSemIr < 0 ? 'sem presença ainda' : 'desde a última',
        ),
      ],
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String detalhe;

  const _ResumoCard({
    required this.titulo,
    required this.valor,
    required this.detalhe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              valor,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BrandColors.navy,
                  ),
            ),
            Text(detalhe, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _AlertaFrequencia extends StatelessWidget {
  final RelatorioIndividual relatorio;

  const _AlertaFrequencia({required this.relatorio});

  @override
  Widget build(BuildContext context) {
    final melhorTipo = relatorio.tipoMaisParticipa;
    final texto = melhorTipo == null
        ? 'Ainda não há presença registrada para este adolescente.'
        : 'Mais participa de ${melhorTipo.nome}: ${melhorTipo.presencas} presença(s).';
    final diasSemIr = relatorio.diasSemIr;
    final detalhe = diasSemIr < 0
        ? 'Acompanhe os próximos eventos para formar o histórico.'
        : diasSemIr >= 21
            ? 'Atenção pastoral: já faz $diasSemIr dias desde a última presença.'
            : 'Frequência recente dentro do esperado.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrandColors.yellow.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(detalhe),
        ],
      ),
    );
  }
}

class _TipoBar extends StatelessWidget {
  final ParticipacaoPorTipo item;

  const _TipoBar({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.nome,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text('${item.presencas}/${item.totalEventos}'),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: item.percentual,
              backgroundColor: Colors.black12,
              valueColor: const AlwaysStoppedAnimation(BrandColors.magenta),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventoTile extends StatelessWidget {
  final EventoParticipacao evento;

  const _EventoTile({required this.evento});

  @override
  Widget build(BuildContext context) {
    final cor = evento.presente ? BrandColors.success : BrandColors.red;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: evento.presente ? BrandColors.successSoft : BrandColors.dangerSoft,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(
          evento.presente ? Icons.check_circle : Icons.cancel,
          color: cor,
        ),
        title: Text(evento.nome),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(evento.data)),
        trailing: Text(
          evento.presente ? 'Presente' : 'Faltou',
          style: TextStyle(color: cor, fontWeight: FontWeight.w600),
        ),
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

Color? _colorFromHex(String? hex) {
  if (hex == null || hex.trim().isEmpty) return null;
  final clean = hex.replaceAll('#', '').trim();
  if (clean.length != 6) return null;
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}
