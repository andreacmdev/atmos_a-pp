import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/adolescente.dart';
import '../services/google_sheets_api.dart';
import '../widgets/atmos_ui.dart';

class AdolescenteFormScreen extends StatefulWidget {
  const AdolescenteFormScreen({super.key});

  @override
  State<AdolescenteFormScreen> createState() => _AdolescenteFormScreenState();
}

class _AdolescenteFormScreenState extends State<AdolescenteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _dataCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _dataCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  DateTime? _parseData() {
    final text = _dataCtrl.text.trim();
    if (text.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(text);
    } catch (_) {
      return null;
    }
  }

  Future<void> _selecionarData() async {
    final atual = _parseData();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: atual ?? DateTime(2012),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada != null) {
      _dataCtrl.text = DateFormat('dd/MM/yyyy').format(selecionada);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final nome = _nomeCtrl.text.trim();
      final semelhantes = await _buscarSemelhantes(nome);

      if (!mounted) return;
      if (semelhantes.exatos.isNotEmpty) {
        await _mostrarDuplicadoBloqueado(semelhantes.exatos);
        return;
      }

      if (semelhantes.parecidos.isNotEmpty) {
        final confirmar = await _confirmarCadastroComSemelhantes(
          semelhantes.parecidos,
        );
        if (confirmar != true) return;
      }

      await GoogleSheetsApi.cadastrarAdolescente(
        nome: nome,
        dataNascimento: _parseData(),
        telefone: _telefoneCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adolescente cadastrado com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<_Semelhantes> _buscarSemelhantes(String nome) async {
    final adolescentes = await GoogleSheetsApi.fetchAdolescentes();
    final nomeNormalizado = _normalizarNome(nome);
    final exatos = <Adolescente>[];
    final parecidos = <Adolescente>[];

    for (final adolescente in adolescentes) {
      final candidato = _normalizarNome(adolescente.nome);
      if (candidato == nomeNormalizado) {
        exatos.add(adolescente);
        continue;
      }

      final score = _similaridade(nomeNormalizado, candidato);
      final contemPartes = _temPartesParecidas(nomeNormalizado, candidato);
      if (score >= 0.72 || contemPartes) {
        parecidos.add(adolescente);
      }
    }

    parecidos.sort((a, b) {
      final aScore = _similaridade(nomeNormalizado, _normalizarNome(a.nome));
      final bScore = _similaridade(nomeNormalizado, _normalizarNome(b.nome));
      return bScore.compareTo(aScore);
    });

    return _Semelhantes(
      exatos: exatos.take(5).toList(),
      parecidos: parecidos.take(6).toList(),
    );
  }

  Future<void> _mostrarDuplicadoBloqueado(List<Adolescente> exatos) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cadastro já existe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Encontramos um adolescente com esse mesmo nome. Confira antes de cadastrar novamente:',
            ),
            const SizedBox(height: 12),
            ...exatos.map(
              (a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: Text(a.nome),
                subtitle: a.telefone == null || a.telefone!.trim().isEmpty
                    ? null
                    : Text(a.telefone!),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar e conferir'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmarCadastroComSemelhantes(
    List<Adolescente> parecidos,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Possível cadastro duplicado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Antes de salvar, confira se o adolescente não é um destes nomes já cadastrados:',
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: SingleChildScrollView(
                child: Column(
                  children: parecidos
                      .map(
                        (a) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person_search),
                          title: Text(a.nome),
                          subtitle:
                              a.telefone == null || a.telefone!.trim().isEmpty
                                  ? null
                                  : Text(a.telefone!),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cadastrar mesmo assim'),
          ),
        ],
      ),
    );
  }

  String _normalizarNome(String nome) {
    const from = 'áàâãäÁÀÂÃÄéèêëÉÈÊËíìîïÍÌÎÏóòôõöÓÒÔÕÖúùûüÚÙÛÜçÇñÑ';
    const to = 'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUcCnN';
    var out = nome.toLowerCase().trim();
    for (var i = 0; i < from.length && i < to.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _temPartesParecidas(String nome, String candidato) {
    final partesNome = nome.split(' ').where((p) => p.length >= 4).toSet();
    final partesCandidato =
        candidato.split(' ').where((p) => p.length >= 4).toSet();
    if (partesNome.isEmpty || partesCandidato.isEmpty) return false;

    final comuns = partesNome.intersection(partesCandidato).length;
    final menor = partesNome.length < partesCandidato.length
        ? partesNome.length
        : partesCandidato.length;
    return comuns >= 2 || comuns / menor >= 0.6;
  }

  double _similaridade(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    if (a == b) return 1;

    final distancia = _levenshtein(a, b);
    final maior = a.length > b.length ? a.length : b.length;
    return 1 - (distancia / maior);
  }

  int _levenshtein(String a, String b) {
    final previous = List<int>.generate(b.length + 1, (i) => i);
    final current = List<int>.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final insert = current[j] + 1;
        final delete = previous[j + 1] + 1;
        final replace = previous[j] + (a[i] == b[j] ? 0 : 1);
        current[j + 1] =
            [insert, delete, replace].reduce((x, y) => x < y ? x : y);
      }
      previous.setAll(0, current);
    }

    return previous[b.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Adolescente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AtmosInfoHeader(
                icon: Icons.group_add_outlined,
                title: 'Novo adolescente',
                subtitle:
                    'Antes de salvar, o app confere nomes parecidos para evitar duplicidade.',
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nome *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Informe o nome';
                          if (text.length < 2) return 'Nome muito curto';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dataCtrl,
                        decoration: InputDecoration(
                          labelText: 'Data de nascimento',
                          hintText: 'dd/mm/aaaa',
                          prefixIcon: const Icon(Icons.cake_outlined),
                          suffixIcon: IconButton(
                            tooltip: 'Selecionar data',
                            icon: const Icon(Icons.calendar_month),
                            onPressed: _selecionarData,
                          ),
                        ),
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return null;
                          if (_parseData() == null) {
                            return 'Use o formato dd/mm/aaaa';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _telefoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_salvando ? 'Salvando...' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Semelhantes {
  final List<Adolescente> exatos;
  final List<Adolescente> parecidos;

  _Semelhantes({
    required this.exatos,
    required this.parecidos,
  });
}
