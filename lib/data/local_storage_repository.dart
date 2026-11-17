import 'dart:convert';

import '../models/profile_evolution_models.dart';
import 'local_storage_platform_stub.dart'
    if (dart.library.io) 'local_storage_platform_io.dart'
    as platform_storage;
import 'mock_repository.dart';

/// Interface de Repositório de Dados da Consultoria.
/// Permite persistir localmente no dispositivo agora e trocar de forma transparente
/// pelo banco de dados remoto criado na conversa "Project Folder Markdown Structure".
abstract class ConsultoriaStorageRepository {
  Future<PersistedAppSnapshot?> loadSnapshot();
  Future<void> saveSnapshot(PersistedAppSnapshot snapshot);
  void saveSnapshotSync(PersistedAppSnapshot snapshot);
  PersistedAppSnapshot? loadSnapshotSync();
  Future<void> clearStorage();
}

class PersistedAppSnapshot {
  final List<StudentMobileProfile> students;
  final List<CommunityPost> communityPosts;
  final int selectedStudentId;
  final DateTime savedAt;

  const PersistedAppSnapshot({
    required this.students,
    required this.communityPosts,
    required this.selectedStudentId,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'schemaVersion': '2.0.0',
    'savedAt': savedAt.toIso8601String(),
    'selectedStudentId': selectedStudentId,
    'students': students.map((s) => s.toSyncJson()).toList(),
    'communityPosts': communityPosts.map((p) => p.toJson()).toList(),
  };

  factory PersistedAppSnapshot.fromJson(Map<String, dynamic> json) {
    return PersistedAppSnapshot(
      selectedStudentId: (json['selectedStudentId'] as num?)?.round() ?? 1,
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'] as String)
          : DateTime.now(),
      students: (json['students'] as List<dynamic>)
          .map((s) => StudentMobileProfile.fromSyncJson(s as Map<String, dynamic>))
          .toList(),
      communityPosts: (json['communityPosts'] as List<dynamic>)
          .map((p) => CommunityPost.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Implementação de persistência local em arquivo JSON no dispositivo,
/// com fallback automático em memória para Web e ambientes restritos.
class LocalFileStorageRepository implements ConsultoriaStorageRepository {
  final String filePath;
  PersistedAppSnapshot? _memoryFallback;

  LocalFileStorageRepository({String? customFilePath})
    : filePath =
          customFilePath ?? platform_storage.resolveDefaultStorageFilePath();

  @override
  PersistedAppSnapshot? loadSnapshotSync() {
    try {
      final raw = platform_storage.readStorageFileSync(filePath);
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _memoryFallback = PersistedAppSnapshot.fromJson(decoded);
        return _memoryFallback;
      }
    } catch (_) {
      // Fallback para memória caso arquivo esteja indisponível
    }
    return _memoryFallback;
  }

  @override
  Future<PersistedAppSnapshot?> loadSnapshot() async {
    return loadSnapshotSync();
  }

  @override
  void saveSnapshotSync(PersistedAppSnapshot snapshot) {
    _memoryFallback = snapshot;
    try {
      platform_storage.writeStorageFileSync(
        filePath,
        const JsonEncoder.withIndent('  ').convert(snapshot.toJson()),
      );
    } catch (_) {
      // Ignora erro de I/O em ambientes restritos mantendo em _memoryFallback
    }
  }

  @override
  Future<void> saveSnapshot(PersistedAppSnapshot snapshot) async {
    saveSnapshotSync(snapshot);
  }

  @override
  Future<void> clearStorage() async {
    _memoryFallback = null;
    try {
      await platform_storage.deleteStorageFile(filePath);
    } catch (_) {}
  }

  /// Constrói o snapshot inicial com os 3 alunos sincronizados e ~4 meses de histórico.
  static PersistedAppSnapshot buildSeedSnapshot() {
    return PersistedAppSnapshot(
      students: MockRepository.buildInitialStudents(),
      communityPosts: MockRepository.buildInitialCommunityPosts(),
      selectedStudentId: 1,
      savedAt: DateTime(2026, 10, 28, 20, 0),
    );
  }
}
