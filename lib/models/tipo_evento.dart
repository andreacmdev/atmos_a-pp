enum TipoEvento { culto, conectadao, atmosfera }

extension TipoEventoX on TipoEvento {
  String get label {
    switch (this) {
      case TipoEvento.culto:
        return 'Culto Domingo';
      case TipoEvento.conectadao:
        return 'Conectadão';
      case TipoEvento.atmosfera:
        return 'Atmosfera';
    }
  }

  String get apiValue {
    // Valor “técnico” pra enviar pra API (se/quando gravarmos no Sheets)
    switch (this) {
      case TipoEvento.culto:
        return 'culto';
      case TipoEvento.conectadao:
        return 'conectadao';
      case TipoEvento.atmosfera:
        return 'atmosfera';
    }
  }
}
