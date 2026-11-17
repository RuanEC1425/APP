String resolveDefaultStorageFilePath() =>
    'rec_consultoria_local_store_v2.json';

String? readStorageFileSync(String path) => null;

void writeStorageFileSync(String path, String contents) {}

Future<void> deleteStorageFile(String path) async {}
