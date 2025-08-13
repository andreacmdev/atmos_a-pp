import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/adolescente.dart';

class GoogleSheetsApi {
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbxurvCvaUsxFZjhbXgL7DEQExtsdCJjnrGs8ZTp8Pu0rMsxEC7mLI4ygCHMHq2JD-mx/exec';

  static Future<List<Adolescente>> fetchAdolescentes() async {
    final response = await http.get(Uri.parse('$baseUrl?action=getAdolescentes'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => Adolescente.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar adolescentes');
    }
  }

  static Future<void> registrarPresenca({
    required String idAdolescente,
    required String dataCulto,
    String registradoPor = 'André',
    String? tipoEvento, // novo
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: {
        'action': 'registrarPresenca',
        'id': idAdolescente,
        'data': dataCulto,
        'registrado_por': registradoPor,
        if (tipoEvento != null) 'tipo_evento': tipoEvento, // enviado (backend atual ignora)
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao registrar presença');
    }
  }
}
