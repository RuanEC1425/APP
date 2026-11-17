import 'dart:io';

String resolveDefaultStorageFilePath() =>
    '${Directory.systemTemp.path}/rec_consultoria_local_store_v2.json';

String? readStorageFileSync(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  return file.readAsStringSync();
}

void writeStorageFileSync(String path, String contents) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}

Future<void> deleteStorageFile(String path) async {
  final file = File(path);
  if (file.existsSync()) {
    await file.delete();
  }
}
