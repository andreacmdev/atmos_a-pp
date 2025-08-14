import 'package:flutter/material.dart';
import '../services/google_sheets_api.dart';

class VisitanteFormScreen extends StatefulWidget {
  const VisitanteFormScreen({super.key});

  @override
  State<VisitanteFormScreen> createState() => _VisitanteFormScreenState();
}

class _VisitanteFormScreenState extends State<VisitanteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _telCtrl.dispose();
    _idadeCtrl.dispose();
    super.dispose();
  }

  String? _validaNome(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Informe o nome';
    if (s.length < 2) return 'Nome muito curto';
    return null;
  }

  String? _validaIdade(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null;
    final n = int.tryParse(s);
    if (n == null || n < 0 || n > 120) return 'Idade inválida';
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);
    try {
      await GoogleSheetsApi.registrarVisitante(
        nome: _nomeCtrl.text.trim(),
        telefone: _telCtrl.text.trim().isEmpty ? null : _telCtrl.text.trim(),
        idade: _idadeCtrl.text.trim().isEmpty ? null : _idadeCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitante cadastrado com sucesso!')),
      );
      Navigator.pop(context); // volta para a Home/Lista
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Visitante')),
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
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                validator: _validaNome,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telCtrl,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idadeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                validator: _validaIdade,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _enviando ? null : _salvar,
                  icon: _enviando
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.person_add_alt),
                  label: Text(_enviando ? 'Enviando...' : 'Salvar Visitante'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
