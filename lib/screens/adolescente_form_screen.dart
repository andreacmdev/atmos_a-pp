import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/google_sheets_api.dart';

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
      await GoogleSheetsApi.cadastrarAdolescente(
        nome: _nomeCtrl.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Adolescente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                  if (_parseData() == null) return 'Use o formato dd/mm/aaaa';
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
