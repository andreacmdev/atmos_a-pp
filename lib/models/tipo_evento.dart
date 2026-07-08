enum TipoEvento {
  cultoDomingoManha,
  cultoDomingoNoite,
  conectadao,
  atmosfera,
  reuniao,
}

extension TipoEventoX on TipoEvento {
  String get label {
    switch (this) {
      case TipoEvento.cultoDomingoManha:
        return 'Culto Domingo Manhã';
      case TipoEvento.cultoDomingoNoite:
        return 'Culto Domingo Noite';
      case TipoEvento.conectadao:
        return 'Conectadão';
      case TipoEvento.atmosfera:
        return 'Atmosfera';
      case TipoEvento.reuniao:
        return 'Reunião';
    }
  }

  String get apiValue {
    switch (this) {
      case TipoEvento.cultoDomingoManha:
        return 'culto_domingo_manha';
      case TipoEvento.cultoDomingoNoite:
        return 'culto_domingo_noite';
      case TipoEvento.conectadao:
        return 'conectadao';
      case TipoEvento.atmosfera:
        return 'atmosfera';
      case TipoEvento.reuniao:
        return 'reuniao';
    }
  }
}
