import 'dart:io';

Future<void> deleteLocalDownloadFiles(Iterable<dynamic> items) async {
  for (final item in items) {
    try {
      final dynamic download = item;
      final path = download.localPath as String?;
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {}
  }
}
