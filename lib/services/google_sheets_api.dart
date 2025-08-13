import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/adolescente.dart';

class GoogleSheetsApi {
  static const String baseUrl = 'https://script.google.com/macros/s/SEU_DEPLOY_URL/exec';

  /// Busca a lista de adolescentes cadastrados na planilha
  static Future<List<Adolescente>> fetchAdolescentes() async {
    final response = await http.get(Uri.parse('$baseUrl?action=getAdolescentes'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Adolescente.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar adolescentes');
    }
  }

  /// Registra presença de um adolescente para uma data de culto
  static Future<void> registrarPresenca({
    required String idAdolescente,
    required String dataCulto,
    String registradoPor = 'André',
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: {
        'action': 'registrarPresenca',
        'id': idAdolescente,
        'data': dataCulto,
        'registrado_por': registradoPor,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao registrar presença');
    }
  }
}
