import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tipo_evento.dart';
import '../theme/brand_colors.dart';
import '../widgets/atmos_ui.dart';
import 'adolescente_form_screen.dart';
import 'aniversariantes_screen.dart';
import 'conectados_screen.dart';
import 'presenca_screen.dart';
import 'relatorio_conectados_screen.dart';
import 'relatorio_gerencial_screen.dart';
import 'relatorio_individual_screen.dart';
import 'relatorio_transicao_screen.dart';
import 'visitante_form_screen.dart';
import 'visitantes_relatorio_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _abrirSelecaoEvento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        const itens = TipoEvento.values;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          shrinkWrap: true,
          itemBuilder: (ctx, i) {
            final te = itens[i];
            return Padding(
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
                      color: BrandColors.magenta.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: BrandColors.magenta,
                    ),
                  ),
                  title: Text(
                    te.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Marcar presenca do evento'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PresencaScreen(tipoEvento: te),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          itemCount: itens.length,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/10.png',
                      width: 54,
                      height: 54,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ATMOS Gestao',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: BrandColors.navy,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Presenca e cuidado',
                            style: TextStyle(color: BrandColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const _MenuGroupTitle('Eventos'),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Marcar Presenca'),
                onTap: () {
                  Navigator.pop(context);
                  _abrirSelecaoEvento(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.groups_2_outlined),
                title: const Text('Conectados'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConectadosScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              const _MenuGroupTitle('Cadastros'),
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: const Text('Adicionar Visitante'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VisitanteFormScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.group_add_outlined),
                title: const Text('Cadastrar Adolescente'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdolescenteFormScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              const _MenuGroupTitle('Relatorios'),
              ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('Aniversariantes do mes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AniversariantesScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Visitantes da Semana'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VisitantesSemanaScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.manage_search),
                title: const Text('Relatorio Individual'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RelatorioIndividualScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Relatorio Gerencial'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RelatorioGerencialScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.insert_chart_outlined),
                title: const Text('Relatorio Conectados'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RelatorioConectadosScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.move_up),
                title: const Text('Relatorio de Transicao'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RelatorioTransicaoScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              const _MenuGroupTitle('Conta'),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  Navigator.pop(context);
                  await Supabase.instance.client.auth.signOut();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Image.asset(
              'assets/LOGO.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BrandColors.magenta, BrandColors.navy],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/atmosw.png',
                  width: 460,
                  height: 260,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => _abrirSelecaoEvento(context),
                  child: Image.asset(
                    'assets/1.png',
                    width: 200,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuGroupTitle extends StatelessWidget {
  final String text;

  const _MenuGroupTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: AtmosSectionTitle(title: text),
    );
  }
}
