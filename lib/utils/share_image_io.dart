import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> sharePngImage({
  required Uint8List bytes,
  required String fileName,
  required String text,
}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);

  await Share.shareFiles(
    [file.path],
    text: text,
    mimeTypes: ['image/png'],
  );
}
