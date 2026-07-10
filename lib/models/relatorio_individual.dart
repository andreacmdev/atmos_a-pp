import 'adolescente.dart';
import 'conectado.dart';

class EventoParticipacao {
  final String id;
  final DateTime data;
  final String tipo;
  final String nome;
  final bool presente;

  EventoParticipacao({
    required this.id,
    required this.data,
    required this.tipo,
    required this.nome,
    required this.presente,
  });
}

class ParticipacaoPorTipo {
  final String tipo;
  final String nome;
  final int presencas;
  final int totalEventos;

  ParticipacaoPorTipo({
    required this.tipo,
    required this.nome,
    required this.presencas,
    required this.totalEventos,
  });

  int get faltas => totalEventos - presencas;

  double get percentual {
    if (totalEventos == 0) return 0;
    return presencas / totalEventos;
  }
}

class ConectadoParticipacaoIndividual {
  final String id;
  final DateTime data;
  final String grupoNome;
  final String responsavel;
  final bool presente;

  ConectadoParticipacaoIndividual({
    required this.id,
    required this.data,
    required this.grupoNome,
    required this.responsavel,
    required this.presente,
  });
}

class ConectadoResumoIndividual {
  final ConectadoGrupo? grupoAtual;
  final List<ConectadoParticipacaoIndividual> encontros;

  ConectadoResumoIndividual({
    required this.grupoAtual,
    required this.encontros,
  });

  int get totalEncontros => encontros.length;

  int get totalPresencas =>
      encontros.where((encontro) => encontro.presente).length;

  int get totalFaltas => totalEncontros - totalPresencas;

  double get percentualPresenca {
    if (totalEncontros == 0) return 0;
    return totalPresencas / totalEncontros;
  }

  ConectadoParticipacaoIndividual? get ultimaPresenca {
    for (final encontro in encontros) {
      if (encontro.presente) return encontro;
    }
    return null;
  }

  int get diasSemIr {
    final ultima = ultimaPresenca;
    if (ultima == null) return -1;
    final hoje = DateTime.now();
    final dataHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final dataUltima = DateTime(
      ultima.data.year,
      ultima.data.month,
      ultima.data.day,
    );
    return dataHoje.difference(dataUltima).inDays;
  }
}

class RelatorioIndividual {
  final Adolescente adolescente;
  final List<EventoParticipacao> eventos;
  final List<ParticipacaoPorTipo> porTipo;
  final ConectadoResumoIndividual conectado;

  RelatorioIndividual({
    required this.adolescente,
    required this.eventos,
    required this.porTipo,
    required this.conectado,
  });

  int get totalEventos => eventos.length;

  int get totalPresencas => eventos.where((evento) => evento.presente).length;

  int get totalFaltas => totalEventos - totalPresencas;

  double get percentualPresenca {
    if (totalEventos == 0) return 0;
    return totalPresencas / totalEventos;
  }

  EventoParticipacao? get ultimaPresenca {
    for (final evento in eventos) {
      if (evento.presente) return evento;
    }
    return null;
  }

  int get diasSemIr {
    final ultima = ultimaPresenca;
    if (ultima == null) return -1;
    final hoje = DateTime.now();
    final dataHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final dataUltima = DateTime(
      ultima.data.year,
      ultima.data.month,
      ultima.data.day,
    );
    return dataHoje.difference(dataUltima).inDays;
  }

  int get faltasSeguidas {
    var total = 0;
    for (final evento in eventos) {
      if (evento.presente) break;
      total++;
    }
    return total;
  }

  ParticipacaoPorTipo? get tipoMaisParticipa {
    final itens = porTipo.where((item) => item.presencas > 0).toList();
    if (itens.isEmpty) return null;
    itens.sort((a, b) {
      final byPresencas = b.presencas.compareTo(a.presencas);
      if (byPresencas != 0) return byPresencas;
      return b.percentual.compareTo(a.percentual);
    });
    return itens.first;
  }
}
