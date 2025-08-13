import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/adolescente.dart';

class GoogleSheetsApi {
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbyq3Szvr9U6iHL5piSvD2D7A9qZgE1NVLWNlchnfPQWJ3TfL0HToZ-rcwwuMNULHE4F/exec';

 static Future<List<Adolescente>> fetchAdolescentes() async {
    final response = await http
        .get(Uri.parse('$baseUrl?action=getAdolescentes'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => Adolescente.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar adolescentes (HTTP ${response.statusCode})');
    }
  }

static Future<void> registrarPresenca({
  required String idAdolescente,
  required String dataCulto,
  String registradoPor = 'André',
  String? tipoEvento,
}) async {
  final uri = Uri.parse(baseUrl);

  final response = await http
      .post(
        uri,
        headers: {
          // ajuda o GAS a entender o formato
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'action': 'registrarPresenca',
          'id': idAdolescente,
          'data': dataCulto,
          'registrado_por': registradoPor,
          if (tipoEvento != null) 'tipo_evento': tipoEvento,
        },
      )
      .timeout(const Duration(seconds: 20));

  // Log de diagnóstico (aparece no console do Flutter)
  // ignore: avoid_print
  print('registrarPresenca -> code=${response.statusCode} body=${response.body}');

  // ✅ Trate 2xx e 3xx como sucesso (GAS pode responder 302 após executar)
  final ok = response.statusCode >= 200 && response.statusCode < 400;
  if (!ok) {
    throw Exception('Erro ao registrar presença (HTTP ${response.statusCode})');
    }
  }

  static Future<Set<String>> fetchPresencas({
  required String dataCulto,        // yyyy-MM-dd
  required String tipoEvento,       // 'culto' | 'conectadao' | 'atmosfera'
}) async {
  final uri = Uri.parse('$baseUrl?action=getPresencas&data=$dataCulto&tipo_evento=$tipoEvento');
  final response = await http.get(uri).timeout(const Duration(seconds: 20));

  if (response.statusCode >= 200 && response.statusCode < 400) {
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (map['ids'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    return Set<String>.from(list);
  } else {
    throw Exception('Erro ao buscar presenças (HTTP ${response.statusCode})');
  }
}

}