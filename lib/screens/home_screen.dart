import 'package:flutter/material.dart';
import '../models/tipo_evento.dart';
import 'presenca_screen.dart';
import '../theme/brand_colors.dart';
import 'visitante_form_screen.dart';
import 'aniversariantes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _abrirSelecaoEvento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        final itens = TipoEvento.values;
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
      extendBodyBehindAppBar: true, // Faz o fundo ir atrás do AppBar
drawer: Drawer(
  child: SafeArea(
    child: Column(
      children: [
        const SizedBox(height: 12),
        Image.asset(
          'assets/10.png', // caminho da sua imagem
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
                    MaterialPageRoute(builder: (_) => const VisitanteFormScreen()),
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
                      MaterialPageRoute(builder: (_) => const AniversariantesScreen()),
                    );
                  },
                ),
              const Divider(),
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
  height: double.infinity, // Garante que cobre toda a tela
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        BrandColors.magenta,
        BrandColors.navy,
      ],
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
                const SizedBox(height: 24),
                const SizedBox(height: 24),
               GestureDetector(
                  onTap: () => _abrirSelecaoEvento(context),
                  child: Image.asset(
                    'assets/1.png', // coloque o caminho da sua imagem de botão
                    width: 200, // ajuste conforme necessário
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
