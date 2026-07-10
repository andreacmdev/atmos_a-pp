import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/adolescente.dart';
import '../services/google_sheets_api.dart';
import '../theme/brand_colors.dart';
import '../widgets/atmos_ui.dart';

class RelatorioTransicaoScreen extends StatefulWidget {
  const RelatorioTransicaoScreen({super.key});

  @override
  State<RelatorioTransicaoScreen> createState() =>
      _RelatorioTransicaoScreenState();
}

class _RelatorioTransicaoScreenState extends State<RelatorioTransicaoScreen> {
  bool _carregando = true;
  String? _erro;
  List<_TransicaoItem> _itens = const [];
  int _semNascimento = 0;

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
      final adolescentes = await GoogleSheetsApi.fetchAdolescentes();
      final itens = <_TransicaoItem>[];
      var semNascimento = 0;

      for (final adolescente in adolescentes) {
        final idade = _idadeDetalhada(adolescente.dataNascimento);
        if (idade == null) {
          semNascimento++;
          continue;
        }

        if (idade.anos >= 17) {
          itens.add(_TransicaoItem(adolescente: adolescente, idade: idade));
        }
      }

      itens.sort((a, b) {
        final byIdade = b.idade.mesesTotais.compareTo(a.idade.mesesTotais);
        if (byIdade != 0) return byIdade;
        return a.adolescente.nome.compareTo(b.adolescente.nome);
      });

      if (mounted) {
        setState(() {
          _itens = itens;
          _semNascimento = semNascimento;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _erro = 'Erro ao gerar relatorio: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
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

  Future<void> _confirmarTransicao(_TransicaoItem item) async {
    final adolescente = item.adolescente;
    final primeiraConfirmacao = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar transicao?'),
        content: Text(
          '${adolescente.nome} sera retirado das listas ativas do app. O cadastro e o historico dele continuam salvos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (primeiraConfirmacao != true || !mounted) return;

    final segundaConfirmacao = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmacao final'),
        content: Text(
          'Tem certeza que ${adolescente.nome} ja saiu do departamento ATMOS?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nao'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: BrandColors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, confirmar'),
          ),
        ],
      ),
    );

    if (segundaConfirmacao != true) return;

    try {
      await GoogleSheetsApi.confirmarTransicaoAdolescente(
        adolescenteId: adolescente.id,
      );
      _mostrarMensagem('${adolescente.nome} removido das listas ativas.');
      await _carregar();
    } catch (e) {
      _mostrarMensagem('Erro ao confirmar transicao: $e');
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

  _IdadeDetalhada? _idadeDetalhada(DateTime? nascimento) {
    if (nascimento == null) return null;
    final hoje = DateTime.now();
    var mesesTotais =
        (hoje.year - nascimento.year) * 12 + hoje.month - nascimento.month;
    if (hoje.day < nascimento.day) mesesTotais--;

    final anos = mesesTotais ~/ 12;
    final meses = mesesTotais % 12;
    if (anos < 0 || anos > 120) return null;
    return _IdadeDetalhada(anos: anos, meses: meses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatorio de Transicao'),
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
              icon: Icons.move_up,
              title: 'Transicao',
              subtitle:
                  'Adolescentes ativos com 17 anos ou mais para acompanhamento pastoral.',
            ),
            const SizedBox(height: 12),
            if (_erro != null) _ErroBox(texto: _erro!),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              _ResumoTransicao(
                total: _itens.length,
                semNascimento: _semNascimento,
              ),
              const SizedBox(height: 12),
              if (_itens.isEmpty)
                const AtmosEmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'Nenhum adolescente em transicao',
                  message:
                      'Nao encontramos adolescentes ativos com 17 anos ou mais.',
                )
              else
                ..._itens.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TransicaoCard(
                      item: item,
                      onWhatsapp: _abrirWhatsapp,
                      onConfirmarTransicao: _confirmarTransicao,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResumoTransicao extends StatelessWidget {
  final int total;
  final int semNascimento;

  const _ResumoTransicao({
    required this.total,
    required this.semNascimento,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: _ResumoItem(
                titulo: 'Em transicao',
                valor: total.toString(),
                cor: BrandColors.magenta,
              ),
            ),
            Container(width: 1, height: 40, color: BrandColors.divider),
            Expanded(
              child: _ResumoItem(
                titulo: 'Sem nascimento',
                valor: semNascimento.toString(),
                cor: BrandColors.navy,
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
  final Color cor;

  const _ResumoItem({
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: cor,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(color: BrandColors.textMuted),
        ),
      ],
    );
  }
}

class _TransicaoCard extends StatelessWidget {
  final _TransicaoItem item;
  final ValueChanged<String?> onWhatsapp;
  final ValueChanged<_TransicaoItem> onConfirmarTransicao;

  const _TransicaoCard({
    required this.item,
    required this.onWhatsapp,
    required this.onConfirmarTransicao,
  });

  @override
  Widget build(BuildContext context) {
    final adolescente = item.adolescente;
    final telefone = adolescente.telefone?.trim() ?? '';
    final temTelefone = telefone.isNotEmpty;
    final nascimento = adolescente.dataNascimento;
    final nascimentoTexto = nascimento == null
        ? 'Data nao informada'
        : DateFormat('dd/MM/yyyy').format(nascimento);

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
                    adolescente.nome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: BrandColors.navy,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BrandColors.warningSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.idade.texto,
                    style: const TextStyle(
                      color: BrandColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.cake_outlined,
                  label: nascimentoTexto,
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
                onPressed:
                    temTelefone ? () => onWhatsapp(adolescente.telefone) : null,
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
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: BrandColors.red,
                  side: const BorderSide(color: BrandColors.red),
                ),
                onPressed: () => onConfirmarTransicao(item),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar transicao'),
              ),
            ),
          ],
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

class _TransicaoItem {
  final Adolescente adolescente;
  final _IdadeDetalhada idade;

  const _TransicaoItem({
    required this.adolescente,
    required this.idade,
  });
}

class _IdadeDetalhada {
  final int anos;
  final int meses;

  const _IdadeDetalhada({
    required this.anos,
    required this.meses,
  });

  int get mesesTotais => anos * 12 + meses;

  String get texto {
    final anosTexto = anos == 1 ? '1 ano' : '$anos anos';
    if (meses == 0) return anosTexto;
    final mesesTexto = meses == 1 ? '1 mes' : '$meses meses';
    return '$anosTexto e $mesesTexto';
  }
}
