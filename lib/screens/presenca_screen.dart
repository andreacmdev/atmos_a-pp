import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/adolescente.dart';
import '../models/tipo_evento.dart';
import '../services/google_sheets_api.dart';

class PresencaScreen extends StatefulWidget {
  final TipoEvento tipoEvento;
  const PresencaScreen({super.key, required this.tipoEvento});

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
      debugPrint('Erro ao carregar: $e');
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
    if (presencas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos 1 presença.')),
      );
      return;
    }

    for (var id in presencas) {
      await GoogleSheetsApi.registrarPresenca(
        idAdolescente: id,
        dataCulto: dataCulto,
        tipoEvento: widget.tipoEvento.apiValue, // já enviando para futuro
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Presenças salvas para ${widget.tipoEvento.label}!')),
    );

    setState(() {
      presencas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Marcar Presença — ${widget.tipoEvento.label}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 8),
                Text('Data: $dataCulto', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
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
            child: FilledButton.icon(
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
