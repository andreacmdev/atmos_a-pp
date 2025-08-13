import 'package:flutter/material.dart';
import '../models/tipo_evento.dart';
import 'presenca_screen.dart';

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
                Navigator.pop(context); // fecha o bottom sheet
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
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Marcar Presença'),
                onTap: () {
                  Navigator.pop(context); // fecha o drawer
                  _abrirSelecaoEvento(context);
                },
              ),
              const Divider(),
              // Futuras opções aqui
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Image.asset(
          'assets/LOGO.png',
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/ATMOS.png',
                width: 360,
                height: 360,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo à gestão de presença ATMOS!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.church_rounded),
                label: const Text('Registrar Presença'),
                onPressed: () => _abrirSelecaoEvento(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
