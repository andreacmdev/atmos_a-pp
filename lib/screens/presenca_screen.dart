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

  /// IDs já confirmados (check verde e bloqueados)
  final Set<String> registrados = {};

  /// IDs em envio (loading no item)
  final Set<String> carregandoIds = {};

  bool carregandoLista = true;

  /// Pesquisa
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searching = false;

  /// Data padrão (hoje) no formato yyyy-MM-dd
  final String dataCulto = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Carrega lista e pré‑marca quem já está presente (mesmo dia + evento)
  Future<void> _carregarDadosIniciais() async {
    try {
      final dados = await GoogleSheetsApi.fetchAdolescentes();
      final idsPresentes = await GoogleSheetsApi.fetchPresencas(
        dataCulto: dataCulto,
        tipoEvento: widget.tipoEvento.apiValue,
      );

      setState(() {
        lista = dados;
        registrados.addAll(idsPresentes);
        carregandoLista = false;
      });
    } catch (_) {
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
        registrados.add(id);
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

  /// --------- PESQUISA ---------
  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (_searching) {
        // abre pesquisa e foca
        Future.microtask(() => _searchFocus.requestFocus());
      } else {
        // fecha pesquisa e limpa
        _searchCtrl.clear();
      }
    });
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {});
    _searchFocus.requestFocus();
  }

  bool _matchesQuery(String nome) {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return true;
    return _normalize(nome).contains(_normalize(q));
  }

  /// Remove acentos e coloca em minúsculas (busca + amigável)
  String _normalize(String s) {
    const from = 'áàâãäÁÀÂÃÄéèêëÉÈÊËíìîïÍÌÎÏóòôõöÓÒÔÕÖúùûüÚÙÛÜçÇñÑ';
    const to   = 'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUcCnN';
    var out = s.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }
  /// --------- FIM PESQUISA ---------

  @override
  Widget build(BuildContext context) {
    if (carregandoLista) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // aplica filtro por nome
    final visiveis = lista.where((a) => _matchesQuery(a.nome)).toList();

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar adolescente...',
                  border: InputBorder.none,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : Text('Marcar Presença — ${widget.tipoEvento.label}'),
        actions: [
          if (_searching && _searchCtrl.text.isNotEmpty)
            IconButton(
              tooltip: 'Limpar',
              icon: const Icon(Icons.close),
              onPressed: _clearSearch,
            ),
          IconButton(
            tooltip: _searching ? 'Fechar busca' : 'Buscar',
            icon: Icon(_searching ? Icons.search_off : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info: quantidade exibida / total e quantos já registrados
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  'Exibindo ${visiveis.length} de ${lista.length} • Registrados hoje: ${registrados.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 12),
              itemBuilder: (context, i) {
                final a = visiveis[i];
                final isLoading = carregandoIds.contains(a.id);
                final isDone = registrados.contains(a.id);

                return ListTile(
                  title: Text(a.nome),
                  leading: isDone
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : (isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
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
              itemCount: visiveis.length,
            ),
          ),
        ],
      ),
    );
  }
}
