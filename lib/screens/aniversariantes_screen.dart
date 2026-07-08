import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/adolescente.dart';
import '../services/google_sheets_api.dart';
import '../theme/brand_colors.dart';
import '../widgets/atmos_ui.dart';
import 'cartao_aniversario_screen.dart';

class AniversariantesScreen extends StatefulWidget {
  const AniversariantesScreen({super.key});

  @override
  State<AniversariantesScreen> createState() => _AniversariantesScreenState();
}

class _AniversariantesScreenState extends State<AniversariantesScreen> {
  bool carregando = true;
  List<Adolescente> todos = [];

  // mês/ano selecionados (inicia no mês atual)
  late int mes;
  late int ano;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    mes = hoje.month;
    ano = hoje.year;
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => carregando = true);
    try {
      final dados = await GoogleSheetsApi.fetchAdolescentes();
      setState(() {
        todos = dados;
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar: $e')),
      );
    }
  }

  void _mesAnterior() {
    setState(() {
      if (mes == 1) {
        mes = 12;
        ano -= 1;
      } else {
        mes -= 1;
      }
    });
  }

  void _proximoMes() {
    setState(() {
      if (mes == 12) {
        mes = 1;
        ano += 1;
      } else {
        mes += 1;
      }
    });
  }

  int _idadeNoAno(DateTime nascimento, int anoRef, int mesRef, int diaRef) {
    int idade = anoRef - nascimento.year;
    final fezAniversario = (mesRef > nascimento.month) ||
        (mesRef == nascimento.month && diaRef >= nascimento.day);
    if (!fezAniversario) idade -= 1;
    return idade;
  }

  @override
  Widget build(BuildContext context) {
    final tituloMes = DateFormat.yMMMM().format(DateTime(ano, mes, 1));

    final corSubtle =
        Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75);

    // Filtra quem faz aniversário no mês selecionado
    final aniversariantes = todos.where((a) {
      final dn = a.dataNascimento;
      if (dn == null) return false;
      return dn.month == mes;
    }).toList()
      ..sort((a, b) {
        final ad = a.dataNascimento?.day ?? 0;
        final bd = b.dataNascimento?.day ?? 0;
        if (ad != bd) return ad.compareTo(bd);
        return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
      });

    // Agrupa por dia
    final Map<int, List<Adolescente>> porDia = {};
    for (final a in aniversariantes) {
      final dn = a.dataNascimento;
      if (dn == null) continue;
      porDia.putIfAbsent(dn.day, () => []).add(a);
    }
    final diasOrdenados = porDia.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Aniversariantes — $tituloMes'),
        actions: [
          IconButton(
            tooltip: 'Mês anterior',
            icon: const Icon(Icons.chevron_left),
            onPressed: _mesAnterior,
          ),
          IconButton(
            tooltip: 'Próximo mês',
            icon: const Icon(Icons.chevron_right),
            onPressed: _proximoMes,
          ),
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _carregar,
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : aniversariantes.isEmpty
              ? AtmosEmptyState(
                  icon: Icons.cake_outlined,
                  title: 'Nenhum aniversariante',
                  message: 'Não há aniversariantes em $tituloMes.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    AtmosInfoHeader(
                      icon: Icons.cake,
                      title: '${aniversariantes.length} aniversariante(s)',
                      subtitle: 'em $tituloMes',
                    ),
                    const SizedBox(height: 16),
                    ...diasOrdenados.map((dia) {
                      final listaDoDia = porDia[dia]!;
                      final nomeMes = DateFormat.MMMM().format(
                        DateTime(ano, mes, 1),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: const BoxDecoration(
                                color: BrandColors.warningSoft,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                '$dia de $nomeMes',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: BrandColors.navy,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            ...listaDoDia.map((a) {
                              final dn = a.dataNascimento;
                              final idade = dn == null
                                  ? null
                                  : _idadeNoAno(dn, ano, mes, dia);
                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: BrandColors.yellow,
                                  child: Icon(
                                    Icons.cake_outlined,
                                    color: BrandColors.navy,
                                  ),
                                ),
                                title: Text(
                                  a.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: dn == null
                                    ? Text(
                                        'Data de nascimento não informada',
                                        style: TextStyle(color: corSubtle),
                                      )
                                    : Text(
                                        'Faz ${idade ?? '-'} em ${DateFormat('dd/MM').format(DateTime(ano, mes, dia))}',
                                        style: TextStyle(color: corSubtle),
                                      ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CartaoAniversarioScreen(
                                        adolescente: a,
                                        ano: ano,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}
