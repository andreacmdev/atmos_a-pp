// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

Future<void> sharePngImage({
  required Uint8List bytes,
  required String fileName,
  required String text,
}) async {
  final file = html.File(
    [bytes],
    fileName,
    {'type': 'image/png'},
  );
  final shareData = {
    'files': [file],
    'title': 'Cartão de Aniversário ATMOS',
    'text': text,
  };

  try {
    final navigator = html.window.navigator;
    final canShare = js_util.hasProperty(navigator, 'canShare') &&
        js_util.callMethod(navigator, 'canShare', [shareData]) == true;
    final hasShare = js_util.hasProperty(navigator, 'share');

    if (canShare && hasShare) {
      await js_util.promiseToFuture(
        js_util.callMethod(navigator, 'share', [shareData]),
      );
      return;
    }
  } catch (_) {
    // Falls back to download when Web Share is unavailable or denied.
  }

  final url = html.Url.createObjectUrlFromBlob(file);
  html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}
