import 'adolescente.dart';

class ConectadoGrupo {
  final String id;
  final String nome;
  final String genero;
  final String responsavel;
  final String corNome;
  final String corHex;
  final bool ativo;
  final int totalMembros;

  ConectadoGrupo({
    required this.id,
    required this.nome,
    required this.genero,
    required this.responsavel,
    required this.corNome,
    required this.corHex,
    required this.ativo,
    this.totalMembros = 0,
  });

  factory ConectadoGrupo.fromJson(
    Map<String, dynamic> json, {
    int totalMembros = 0,
  }) {
    return ConectadoGrupo(
      id: (json['id'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      genero: (json['genero'] ?? '').toString(),
      responsavel: (json['responsavel'] ?? '').toString(),
      corNome: (json['cor_nome'] ?? '').toString(),
      corHex: (json['cor_hex'] ?? '').toString(),
      ativo: json['ativo'] != false,
      totalMembros: totalMembros,
    );
  }
}

class ConectadoMembro {
  final String id;
  final String grupoId;
  final Adolescente adolescente;
  final DateTime? dataEntrada;

  ConectadoMembro({
    required this.id,
    required this.grupoId,
    required this.adolescente,
    this.dataEntrada,
  });
}

class ConectadoEncontro {
  final String id;
  final String grupoId;
  final DateTime dataEncontro;
  final String? observacao;

  ConectadoEncontro({
    required this.id,
    required this.grupoId,
    required this.dataEncontro,
    this.observacao,
  });

  factory ConectadoEncontro.fromJson(Map<String, dynamic> json) {
    return ConectadoEncontro(
      id: (json['id'] ?? '').toString(),
      grupoId: (json['grupo_id'] ?? '').toString(),
      dataEncontro: DateTime.parse(json['data_encontro'].toString()),
      observacao: json['observacao']?.toString(),
    );
  }
}
