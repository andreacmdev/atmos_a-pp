import 'adolescente.dart';
import 'conectado.dart';

class RelatorioConectados {
  final DateTime mes;
  final List<RelatorioConectadoGrupo> grupos;

  RelatorioConectados({
    required this.mes,
    required this.grupos,
  });

  int get totalGrupos => grupos.length;

  int get totalEncontros {
    return grupos.fold(0, (total, grupo) => total + grupo.encontros.length);
  }

  int get totalPresencas {
    return grupos.fold(0, (total, grupo) => total + grupo.presencas);
  }

  int get totalPossiveis {
    return grupos.fold(0, (total, grupo) => total + grupo.totalPossivel);
  }

  double get percentualGeral {
    if (totalPossiveis == 0) return 0;
    return totalPresencas / totalPossiveis;
  }
}

class RelatorioConectadoGrupo {
  final ConectadoGrupo grupo;
  final List<ConectadoEncontro> encontros;
  final List<RelatorioConectadoMembro> membros;

  RelatorioConectadoGrupo({
    required this.grupo,
    required this.encontros,
    required this.membros,
  });

  int get presencas {
    return membros.fold(0, (total, membro) => total + membro.presencas);
  }

  int get totalPossivel => encontros.length * membros.length;

  int get faltas => totalPossivel - presencas;

  double get percentual {
    if (totalPossivel == 0) return 0;
    return presencas / totalPossivel;
  }
}

class RelatorioConectadoMembro {
  final Adolescente adolescente;
  final Map<String, bool> presencasPorEncontro;

  RelatorioConectadoMembro({
    required this.adolescente,
    required this.presencasPorEncontro,
  });

  int get presencas {
    return presencasPorEncontro.values.where((presente) => presente).length;
  }
}
