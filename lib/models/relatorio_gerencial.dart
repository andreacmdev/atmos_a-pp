import 'adolescente.dart';

class RelatorioGerencialItem {
  final Adolescente adolescente;
  final int totalEventos;
  final int presencas;

  RelatorioGerencialItem({
    required this.adolescente,
    required this.totalEventos,
    required this.presencas,
  });

  int get faltas => totalEventos - presencas;

  double get percentualFaltas {
    if (totalEventos == 0) return 0;
    return faltas / totalEventos;
  }
}

class RelatorioGerencial {
  final DateTime mes;
  final int totalEventos;
  final List<RelatorioGerencialItem> itens;

  RelatorioGerencial({
    required this.mes,
    required this.totalEventos,
    required this.itens,
  });
}
