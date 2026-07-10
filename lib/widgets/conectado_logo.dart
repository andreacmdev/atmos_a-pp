import 'package:flutter/material.dart';

import '../models/conectado.dart';

class ConectadoLogo extends StatelessWidget {
  final ConectadoGrupo grupo;
  final double size;
  final Color fallbackColor;
  final IconData fallbackIcon;

  const ConectadoLogo({
    super.key,
    required this.grupo,
    required this.size,
    required this.fallbackColor,
    this.fallbackIcon = Icons.diversity_3_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final asset = conectadoLogoAsset(grupo);
    if (asset == null) {
      return _FallbackLogo(
        size: size,
        color: fallbackColor,
        icon: fallbackIcon,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size <= 48 ? 8 : 12),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackLogo(
          size: size,
          color: fallbackColor,
          icon: fallbackIcon,
        ),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;

  const _FallbackLogo({
    required this.size,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(size <= 48 ? 8 : 12),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

String? conectadoLogoAsset(ConectadoGrupo grupo) {
  final nome = _normalizar(grupo.nome);
  if (nome.contains('pinkies')) {
    return 'assets/conectados/pinkies.jpeg';
  }
  if (nome.contains('laramora')) {
    return 'assets/conectados/laramora.jpeg';
  }
  if (nome.contains('azule')) {
    return 'assets/conectados/azuletes.jpeg';
  }
  if (nome.contains('conecthano')) {
    return 'assets/conectados/conecthanos.jpeg';
  }
  if (nome.contains('plugado')) {
    return 'assets/conectados/plugados.jpeg';
  }
  return null;
}

String _normalizar(String value) {
  const from =
      'áàâãäÁÀÂÃÄéèêëÉÈÊËíìîïÍÌÎÏóòôõöÓÒÔÕÖúùûüÚÙÛÜçÇñÑ';
  const to = 'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUcCnN';
  var out = value.toLowerCase().trim();
  for (var i = 0; i < from.length && i < to.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  return out;
}
