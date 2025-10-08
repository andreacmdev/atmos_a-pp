import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/google_sheets_api.dart';
import 'package:intl/intl.dart';

class VisitantesSemanaScreen extends StatefulWidget {
  const VisitantesSemanaScreen({super.key});

  @override
  State<VisitantesSemanaScreen> createState() => _VisitantesSemanaScreenState();
}

class _VisitantesSemanaScreenState extends State<VisitantesSemanaScreen> {
  bool _carregando = true;
  List<Map<String, String>> _visitantes = [];
  String? _erro;

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
      final dados = await GoogleSheetsApi.getVisitantesSemana();
      setState(() => _visitantes = dados);
    } catch (e) {
      setState(() => _erro = e.toString());
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _copiarTelefone(String telefone) {
    if (telefone.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: telefone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Telefone copiado: $telefone')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataFormatada = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitantes da Semana'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _carregar,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Erro ao carregar: $_erro',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : _visitantes.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum visitante registrado nesta semana.\n($dataFormatada)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemCount: _visitantes.length,
                      itemBuilder: (context, i) {
                        final v = _visitantes[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                v['nome']!.isNotEmpty
                                    ? v['nome']![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              v['nome'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (v['telefone']?.isNotEmpty ?? false)
                                  Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(v['telefone'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.black87)),
                                    ],
                                  ),
                                if (v['idade']?.isNotEmpty ?? false)
                                  Text('Idade: ${v['idade']} anos',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            trailing: IconButton(
                              tooltip: 'Copiar telefone',
                              icon: const Icon(Icons.copy),
                              onPressed: () =>
                                  _copiarTelefone(v['telefone'] ?? ''),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
