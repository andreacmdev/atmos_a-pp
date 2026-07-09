import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../models/adolescente.dart';
import '../theme/brand_colors.dart';
import '../utils/share_image.dart';

class CartaoAniversarioScreen extends StatefulWidget {
  final Adolescente adolescente;
  final int ano;

  const CartaoAniversarioScreen({
    super.key,
    required this.adolescente,
    required this.ano,
  });

  @override
  State<CartaoAniversarioScreen> createState() =>
      _CartaoAniversarioScreenState();
}

class _CartaoAniversarioScreenState extends State<CartaoAniversarioScreen> {
  final _cardKey = GlobalKey();
  bool _compartilhando = false;

  int? get _idade {
    final nascimento = widget.adolescente.dataNascimento;
    if (nascimento == null) return null;
    final idade = widget.ano - nascimento.year;
    if (idade < 0 || idade > 120) return null;
    return idade;
  }

  @override
  Widget build(BuildContext context) {
    final nascimento = widget.adolescente.dataNascimento;
    final data = nascimento == null
        ? ''
        : DateFormat('dd/MM')
            .format(DateTime(widget.ano, nascimento.month, nascimento.day));

    return Scaffold(
      appBar: AppBar(title: const Text('Cartão de Aniversário')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          RepaintBoundary(
            key: _cardKey,
            child: BirthdayCard(
              nome: widget.adolescente.nome,
              idade: _idade,
              data: data,
              versiculo: 'O Senhor te abençoe e te guarde.',
              referencia: 'Números 6:24',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _compartilhando ? null : _compartilharImagem,
            icon: Image.asset(
              'assets/whatsapp.png',
              width: 22,
              height: 22,
            ),
            label: Text(
              _compartilhando
                  ? 'Preparando imagem...'
                  : 'Compartilhar imagem no WhatsApp',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'O botão gera a imagem do cartão e abre o compartilhamento do celular. Escolha o WhatsApp na lista.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BrandColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _compartilharImagem() async {
    setState(() => _compartilhando = true);
    try {
      final bytes = await _capturarCartao();
      if (bytes == null) {
        _showSnack('Não foi possível gerar a imagem do cartão.');
        return;
      }

      await sharePngImage(
        bytes: bytes,
        fileName: _nomeArquivo(),
        text: _mensagemWhatsapp(),
      );
    } catch (e) {
      _showSnack('Não foi possível compartilhar a imagem: $e');
    } finally {
      if (mounted) setState(() => _compartilhando = false);
    }
  }

  Future<Uint8List?> _capturarCartao() async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  String _mensagemWhatsapp() {
    final idadeTexto = _idade == null ? '' : ' pelos seus $_idade anos';
    const versiculo = 'O Senhor te abençoe e te guarde.';
    const referencia = 'Números 6:24';
    return '''
Feliz aniversário, ${widget.adolescente.nome}!$idadeTexto

"$versiculo"
$referencia

Que este novo ciclo seja cheio da presença de Deus, alegria e propósito.

Com carinho, ATMOS
'''
        .trim();
  }

  String _nomeArquivo() {
    final nome = widget.adolescente.nome
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return 'cartao_aniversario_${nome.isEmpty ? 'atmos' : nome}.png';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class BirthdayCard extends StatelessWidget {
  final String nome;
  final int? idade;
  final String data;
  final String versiculo;
  final String referencia;

  const BirthdayCard({
    super.key,
    required this.nome,
    required this.idade,
    required this.data,
    required this.versiculo,
    required this.referencia,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1080 / 1350,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              BrandColors.navy,
              Color(0xFF5B124F),
              BrandColors.magenta,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(
              right: -38,
              top: 6,
              child: _DecorativeBlob(
                size: 150,
                color: BrandColors.red,
                opacity: 0.14,
              ),
            ),
            const Positioned(
              left: -54,
              top: 72,
              child: _DecorativeBlob(
                size: 120,
                color: BrandColors.yellow,
                opacity: 0.10,
              ),
            ),
            const Positioned(
              right: 34,
              bottom: 92,
              child: _DecorativeBlob(
                size: 96,
                color: BrandColors.yellow,
                opacity: 0.13,
              ),
            ),
            const Positioned(
              left: -20,
              bottom: -22,
              child: _DecorativeBlob(
                size: 170,
                color: BrandColors.red,
                opacity: 0.10,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/LOGO.png',
                      width: 54,
                      height: 54,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    const Spacer(),
                    if (data.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                        ),
                        child: Text(
                          data,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(flex: 2),
                const Text(
                  'Hoje é dia de celebrar!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 118,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          nome,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            height: 1.04,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (idade != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$idade anos',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: BrandColors.yellow,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '"$versiculo"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            referencia,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xBFFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Que este novo ciclo seja cheio da presença de Deus, alegria e propósito.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
                const Spacer(flex: 2),
                const Text(
                  'Com carinho, ATMOS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: BrandColors.yellow,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeBlob extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const _DecorativeBlob({
    required this.size,
    required this.opacity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}
