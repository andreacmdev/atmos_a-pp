class Adolescente {
  final String id;
  final String nome;
  final DateTime? dataNascimento;
  final String? telefone;

  Adolescente({
    required this.id,
    required this.nome,
    this.dataNascimento,
    this.telefone,
  });

  // Método para criar um Adolescente a partir de um JSON (ex: vindo da API)
  factory Adolescente.fromJson(Map<String, dynamic> json) {
    return Adolescente(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.tryParse(json['data_nascimento'])
          : null,
      telefone: json['telefone'],
    );
  }

  // Método para converter um Adolescente em um Map (ex: para enviar pro backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'data_nascimento': dataNascimento?.toIso8601String(),
      'telefone': telefone,
    };
  }
}
