import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/adolescente.dart';

class GoogleSheetsApi {
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<List<Adolescente>> fetchAdolescentes() async {
    final data = await _client
        .from('adolescentes')
        .select('id, nome, data_nascimento, telefone, ativo')
        .eq('ativo', true)
        .order('nome');

    return data.map((json) => Adolescente.fromJson(json)).toList();
  }

  static Future<Adolescente> cadastrarAdolescente({
    required String nome,
    DateTime? dataNascimento,
    String? telefone,
  }) async {
    final inserted = await _client
        .from('adolescentes')
        .insert({
          'nome': nome.trim(),
          'data_nascimento': dataNascimento?.toIso8601String().split('T').first,
          'telefone': _emptyToNull(telefone),
          'telefone_original': _emptyToNull(telefone),
          'created_by': _client.auth.currentUser?.id,
          'ativo': true,
        })
        .select('id, nome, data_nascimento, telefone, ativo')
        .single();

    return Adolescente.fromJson(inserted);
  }

  static Future<void> registrarPresenca({
    required String idAdolescente,
    required String dataCulto,
    String registradoPor = 'App',
    String? tipoEvento,
  }) async {
    final eventoId = await _ensureEvento(
      dataCulto: dataCulto,
      tipoEvento: tipoEvento,
    );

    await _client.from('presencas').upsert(
      {
        'evento_id': eventoId,
        'adolescente_id': int.parse(idAdolescente),
        'presente': true,
        'registrado_por': registradoPor,
        'registrado_por_user': _client.auth.currentUser?.id,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'evento_id,adolescente_id',
    );
  }

  static Future<void> removerPresenca({
    required String idAdolescente,
    required String dataCulto,
    required String tipoEvento,
  }) async {
    final eventoId = await _findEventoId(
      dataCulto: dataCulto,
      tipoEvento: tipoEvento,
    );

    if (eventoId == null) return;

    await _client
        .from('presencas')
        .update({
          'presente': false,
          'registrado_por': 'Undo-App',
          'registrado_por_user': _client.auth.currentUser?.id,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('evento_id', eventoId)
        .eq('adolescente_id', int.parse(idAdolescente));
  }

  static Future<void> registrarVisitante({
    required String nome,
    String? telefone,
    String? idade,
  }) async {
    await _client.from('visitantes').insert({
      'nome': nome.trim(),
      'telefone': _emptyToNull(telefone),
      'idade': int.tryParse((idade ?? '').trim()),
      'data_registro': DateTime.now().toIso8601String().split('T').first,
      'created_by': _client.auth.currentUser?.id,
    });
  }

  static Future<List<Map<String, String>>> getVisitantesHoje() async {
    final hoje = DateTime.now().toIso8601String().split('T').first;
    return _getVisitantesPorPeriodo(inicio: hoje, fim: hoje);
  }

  static Future<Set<String>> fetchPresencas({
    required String dataCulto,
    required String tipoEvento,
  }) async {
    final eventoId = await _findEventoId(
      dataCulto: dataCulto,
      tipoEvento: tipoEvento,
    );

    if (eventoId == null) return <String>{};

    final data = await _client
        .from('presencas')
        .select('adolescente_id')
        .eq('evento_id', eventoId)
        .eq('presente', true);

    return data.map((row) => row['adolescente_id'].toString()).toSet();
  }

  static Future<List<Map<String, String>>> getVisitantesSemana() async {
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday % 7));
    final fim = inicio.add(const Duration(days: 6));

    return _getVisitantesPorPeriodo(
      inicio: inicio.toIso8601String().split('T').first,
      fim: fim.toIso8601String().split('T').first,
    );
  }

  static Future<List<Map<String, String>>> _getVisitantesPorPeriodo({
    required String inicio,
    required String fim,
  }) async {
    final data = await _client
        .from('visitantes')
        .select('nome, telefone, idade, data_registro')
        .gte('data_registro', inicio)
        .lte('data_registro', fim)
        .order('created_at');

    return data.map<Map<String, String>>((row) {
      return {
        'nome': (row['nome'] ?? '').toString(),
        'telefone': (row['telefone'] ?? '').toString(),
        'idade': (row['idade'] ?? '').toString(),
        'data_registro': (row['data_registro'] ?? '').toString(),
      };
    }).toList();
  }

  static Future<String> _ensureEvento({
    required String dataCulto,
    String? tipoEvento,
  }) async {
    final tipo = _normalizeTipoEvento(tipoEvento);
    final existingId = await _findEventoId(
      dataCulto: dataCulto,
      tipoEvento: tipo,
    );
    if (existingId != null) return existingId;

    try {
      final inserted = await _client
          .from('eventos')
          .insert({
            'data_evento': dataCulto,
            'tipo': tipo,
            'nome': _nomeEvento(tipo),
          })
          .select('id')
          .single();

      return inserted['id'].toString();
    } on PostgrestException {
      final createdByAnotherUser = await _findEventoId(
        dataCulto: dataCulto,
        tipoEvento: tipo,
      );
      if (createdByAnotherUser != null) return createdByAnotherUser;
      rethrow;
    }
  }

  static Future<String?> _findEventoId({
    required String dataCulto,
    required String tipoEvento,
  }) async {
    final data = await _client
        .from('eventos')
        .select('id')
        .eq('data_evento', dataCulto)
        .eq('tipo', _normalizeTipoEvento(tipoEvento))
        .maybeSingle();

    return data?['id']?.toString();
  }

  static String _normalizeTipoEvento(String? tipoEvento) {
    if (tipoEvento == null || tipoEvento.trim().isEmpty || tipoEvento == 'culto') {
      return 'culto_domingo_noite';
    }
    return tipoEvento.trim();
  }

  static String _nomeEvento(String tipoEvento) {
    switch (tipoEvento) {
      case 'culto_domingo_manha':
        return 'Culto Domingo Manhã';
      case 'culto_domingo_noite':
        return 'Culto Domingo Noite';
      case 'conectadao':
        return 'Conectadão';
      case 'atmosfera':
        return 'Atmosfera';
      case 'reuniao':
        return 'Reunião';
      default:
        return tipoEvento;
    }
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
