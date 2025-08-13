import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/adolescente.dart';
import '../services/google_sheets_api.dart';

class PresencaScreen extends StatefulWidget {
  const PresencaScreen({super.key});

  @override
  State<PresencaScreen> createState() => _PresencaScreenState();
}

class _PresencaScreenState extends State<PresencaScreen> {
  List<Adolescente> lista = [];
  Set<String> presencas = {};
  bool carregando = true;
  final dataCulto = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    carregarAdolescentes();
  }

  Future<void> carregarAdolescentes() async {
    try {
      final dados = await GoogleSheetsApi.fetchAdolescentes();
      setState(() {
        lista = dados;
        carregando = false;
      });
    } catch (e) {
      print('Erro ao carregar: $e');
      setState(() {
        carregando = false;
      });
    }
  }

  void togglePresenca(String id) {
    setState(() {
      if (presencas.contains(id)) {
        presencas.remove(id);
      } else {
        presencas.add(id);
      }
    });
  }

  Future<void> salvarPresencas() async {
    for (var id in presencas) {
      await GoogleSheetsApi.registrarPresenca(
        idAdolescente: id,
        dataCulto: dataCulto,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Presenças salvas com sucesso!')),
    );

    setState(() {
      presencas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Marcar Presença')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: lista.map((adolescente) {
                return CheckboxListTile(
                  title: Text(adolescente.nome),
                  value: presencas.contains(adolescente.id),
                  onChanged: (_) => togglePresenca(adolescente.id),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Salvar Presenças'),
              onPressed: salvarPresencas,
            ),
          )
        ],
      ),
    );
  }
}
