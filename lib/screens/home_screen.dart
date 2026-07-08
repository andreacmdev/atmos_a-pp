import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tipo_evento.dart';
import '../theme/brand_colors.dart';
import 'adolescente_form_screen.dart';
import 'aniversariantes_screen.dart';
import 'presenca_screen.dart';
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
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemBuilder: (ctx, i) {
            final te = itens[i];
            return ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(te.label),
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
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
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
          child: Column(
            children: [
              const SizedBox(height: 12),
              Image.asset(
                'assets/10.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Marcar Presença'),
                onTap: () {
                  Navigator.pop(context);
                  _abrirSelecaoEvento(context);
                },
              ),
              const Divider(),
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
              ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('Aniversariantes do mês'),
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
              const Spacer(),
              const Divider(),
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
                  width: 560,
                  height: 360,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 48),
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
