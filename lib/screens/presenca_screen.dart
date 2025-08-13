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

  /// IDs já confirmados (mostra check verde e bloqueia interação)
  final Set<String> registrados = {};

  /// IDs atualmente sendo enviados (mostra loading no item)
  final Set<String> carregandoIds = {};

  /// controla indicador de carregamento geral
  bool carregandoLista = true;

  /// Data padrão do culto (hoje) no formato yyyy-MM-dd
  final String dataCulto = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  /// Carrega lista de adolescentes e também as presenças já registradas
  /// para a combinação (dataCulto + tipoEvento) — assim a UI já vem marcada.
  Future<void> _carregarDadosIniciais() async {
    try {
      // 1) Carrega os adolescentes
      final dados = await GoogleSheetsApi.fetchAdolescentes();

      // 2) Busca IDs já presentes hoje nesse tipo de evento
      final idsPresentes = await GoogleSheetsApi.fetchPresencas(
        dataCulto: dataCulto,
        tipoEvento: widget.tipoEvento.apiValue,
      );

      // (debug opcional)
      // ignore: avoid_print
      print('IDs já presentes em ${widget.tipoEvento.apiValue} $dataCulto => $idsPresentes');

      setState(() {
        lista = dados;
        registrados.addAll(idsPresentes); // pré-marca na UI
        carregandoLista = false;
      });
    } catch (e) {
      setState(() => carregandoLista = false);
      _showSnack('Erro ao carregar. Tente novamente.');
    }
  }

  Future<void> _registrarUm(String id, String nome) async {
    if (registrados.contains(id) || carregandoIds.contains(id)) return;

    setState(() => carregandoIds.add(id));

    try {
      await GoogleSheetsApi.registrarPresenca(
        idAdolescente: id,
        dataCulto: dataCulto,
        tipoEvento: widget.tipoEvento.apiValue,
      );

      setState(() {
        carregandoIds.remove(id);
        registrados.add(id); // marca como concluído
      });

      _showSnack('Registrado: $nome (${widget.tipoEvento.label})');
    } catch (e) {
      setState(() => carregandoIds.remove(id));
      _showSnack(
        'Falha ao registrar $nome. Tentar novamente?',
        action: SnackBarAction(
          label: 'TENTAR',
          onPressed: () => _registrarUm(id, nome),
        ),
      );
    }
  }

  void _showSnack(String msg, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), action: action),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (carregandoLista) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Marcar Presença — ${widget.tipoEvento.label}')),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 12),
        itemBuilder: (context, i) {
          final a = lista[i];
          final isLoading = carregandoIds.contains(a.id);
          final isDone = registrados.contains(a.id);

          return ListTile(
            title: Text(a.nome),
            leading: isDone
                ? const Icon(Icons.check_circle, color: Colors.green)
                : (isLoading
                    ? const SizedBox(
                        width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.person_outline)),
            trailing: Checkbox(
              value: isDone,
              onChanged: (val) {
                if (!isDone && !isLoading) {
                  _registrarUm(a.id, a.nome);
                }
              },
            ),
            onTap: () {
              if (!isDone && !isLoading) {
                _registrarUm(a.id, a.nome);
              }
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: lista.length,
      ),
    );
  }
}
