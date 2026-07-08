class Adolescente {
  final String id;
  final String nome;
  final DateTime? dataNascimento;
  final String? telefone;
  final bool ativo;

  Adolescente({
    required this.id,
    required this.nome,
    this.dataNascimento,
    this.telefone,
    this.ativo = true,
  });

  factory Adolescente.fromJson(Map<String, dynamic> json) {
    return Adolescente(
      id: (json['id'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.tryParse(json['data_nascimento'].toString())
          : null,
      telefone: json['telefone']?.toString(),
      ativo: json['ativo'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'data_nascimento': dataNascimento?.toIso8601String().split('T').first,
      'telefone': telefone,
      'ativo': ativo,
    };
  }
}
