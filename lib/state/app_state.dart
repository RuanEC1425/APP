import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../data/local_storage_repository.dart';
import '../data/mock_repository.dart';
import '../models/nutrition_models.dart';
import '../models/profile_evolution_models.dart';
import '../models/workout_models.dart';
import 'recovery_calculator.dart';

/// Sub-visões alternadas pelo Avatar interativo no canto superior esquerdo da Home.
enum AvatarQuickSpace {
  home('Home'),
  community('Community'),
  you('You');

  final String label;
  const AvatarQuickSpace(this.label);
}

/// Estado reativo central do aplicativo mobile da REC Consultoria Online.
/// Todas as ações executadas pelo aluno recalculam os gráficos em tempo real,
/// persistem localmente via `ConsultoriaStorageRepository` e podem ser exportadas
/// em JSON para sincronização com a versão Web do professor.
class RecAppState extends ChangeNotifier {
  final List<StudentMobileProfile> _students;
  final List<CommunityPost> _communityPosts;
  final ConsultoriaStorageRepository? _storageRepository;

  int _selectedStudentIndex = 0;
  int _bottomTabIndex = 0; // 0: Home, 1: Treino, 2: Dieta, 3: You
  AvatarQuickSpace _avatarSpace = AvatarQuickSpace.home;
  int _selectedWorkoutDayIndex = 0;
  int _youSubTabIndex =
      0; // 0: Visão Geral, 1: Exercícios, 2: Medidas, 3: Fotos & Anamnese

  int _calendarYear = 2026;
  int _calendarMonth = 10; // Outubro 2026 inicial

  RecAppState({
    List<StudentMobileProfile>? initialStudents,
    List<CommunityPost>? initialPosts,
    ConsultoriaStorageRepository? storageRepository,
    bool loadFromStorageIfAvailable = false,
  }) : _storageRepository = storageRepository,
       _students = _resolveInitialStudents(
         initialStudents,
         storageRepository,
         loadFromStorageIfAvailable,
       ),
       _communityPosts = _resolveInitialPosts(
         initialPosts,
         storageRepository,
         loadFromStorageIfAvailable,
       ) {
    if (loadFromStorageIfAvailable && storageRepository != null) {
      final snap = storageRepository.loadSnapshotSync();
      if (snap != null) {
        final idx = _students.indexWhere((s) => s.id == snap.selectedStudentId);
        if (idx != -1) _selectedStudentIndex = idx;
      }
    }
    for (final s in _students) {
      _recomputeDerivedMetricsForStudent(s);
    }
  }

  static List<StudentMobileProfile> _resolveInitialStudents(
    List<StudentMobileProfile>? provided,
    ConsultoriaStorageRepository? repo,
    bool loadFromStorage,
  ) {
    if (provided != null) return provided;
    if (loadFromStorage && repo != null) {
      final snap = repo.loadSnapshotSync();
      if (snap != null && snap.students.isNotEmpty) {
        return snap.students;
      }
    }
    return MockRepository.buildInitialStudents();
  }

  static List<CommunityPost> _resolveInitialPosts(
    List<CommunityPost>? provided,
    ConsultoriaStorageRepository? repo,
    bool loadFromStorage,
  ) {
    if (provided != null) return provided;
    if (loadFromStorage && repo != null) {
      final snap = repo.loadSnapshotSync();
      if (snap != null && snap.communityPosts.isNotEmpty) {
        return snap.communityPosts;
      }
    }
    return MockRepository.buildInitialCommunityPosts();
  }

  List<StudentMobileProfile> get students => List.unmodifiable(_students);
  StudentMobileProfile get activeStudent => _students[_selectedStudentIndex];
  List<CommunityPost> get communityPosts => List.unmodifiable(_communityPosts);

  int get bottomTabIndex => _bottomTabIndex;
  AvatarQuickSpace get avatarSpace => _avatarSpace;
  int get selectedWorkoutDayIndex => _selectedWorkoutDayIndex;
  int get youSubTabIndex => _youSubTabIndex;
  int get calendarYear => _calendarYear;
  int get calendarMonth => _calendarMonth;

  String get calendarMonthYearLabel {
    const monthNames = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${monthNames[(_calendarMonth - 1).clamp(0, 11)]} $_calendarYear';
  }

  WorkoutPlanDay get activeWorkoutDay {
    final days = activeStudent.workoutDays;
    if (_selectedWorkoutDayIndex >= days.length) {
      _selectedWorkoutDayIndex = 0;
    }
    return days[_selectedWorkoutDayIndex];
  }

  int get unreadNotificationsCount =>
      activeStudent.notifications.where((n) => !n.isRead).length;

  /// Persiste o estado atual no repositório local (se configurado) e notifica a UI.
  void _persistAndNotify() {
    _recomputeDerivedMetricsForStudent(activeStudent);
    final repo = _storageRepository;
    if (repo != null) {
      repo.saveSnapshotSync(
        PersistedAppSnapshot(
          students: _students,
          communityPosts: _communityPosts,
          selectedStudentId: activeStudent.id,
          savedAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  /// Recalcula todas as métricas dinâmicas (Visão Geral da Semana, Recuperação Muscular SRA,
  /// PRs, Evolução de Exercícios e Agenda/Calendário) a partir das sessões do aluno.
  void _recomputeDerivedMetricsForStudent(StudentMobileProfile student) {
    final sessions = student.completedSessions;
    final latestDate = sessions.isNotEmpty
        ? sessions
              .map((s) => s.completedAt)
              .reduce((a, b) => a.isAfter(b) ? a : b)
        : MockRepository.defaultReferenceNow;

    final plusFourHours = latestDate.add(const Duration(hours: 4));
    final recoveryRefTime =
        (latestDate.weekday == DateTime.sunday &&
            plusFourHours.weekday == DateTime.monday)
        ? DateTime(latestDate.year, latestDate.month, latestDate.day, 23, 55)
        : plusFourHours;

    student.weeklyMetrics = RecoveryCalculator.computeWeeklyMetrics(
      sessions,
      referenceDate: latestDate,
    );
    student.muscleRecovery = RecoveryCalculator.computeMuscleRecovery(
      sessions,
      referenceTime: recoveryRefTime,
    );
    student.personalRecords = RecoveryCalculator.computePersonalRecords(
      sessions,
      seedRecords: student.personalRecords,
    );
    student.exerciseEvolutions = RecoveryCalculator.computeExerciseEvolutions(
      sessions,
      prescribedDays: student.workoutDays,
      referenceDate: latestDate,
    );
    student.agendaDays = buildCalendarDaysForMonth(
      year: _calendarYear,
      month: _calendarMonth,
      student: student,
    );
  }

  /// Constrói a lista de dias do mês selecionado no Calendário Multi-mês,
  /// marcando como treinados os dias com sessão registrada naquele mês/ano.
  List<AgendaDayComparison> buildCalendarDaysForMonth({
    int? year,
    int? month,
    StudentMobileProfile? student,
  }) {
    final y = year ?? _calendarYear;
    final m = month ?? _calendarMonth;
    final target = student ?? activeStudent;
    final daysInMonth = DateTime(y, m + 1, 0).day;
    final result = <AgendaDayComparison>[];

    for (int d = 1; d <= daysInMonth; d++) {
      final daySessions = sessionsForDate(y, m, d, student: target);
      final trained = daySessions.isNotEmpty;
      final calMet = d % 5 != 0;
      final waterMet = d % 4 != 0;
      result.add(
        AgendaDayComparison(
          dayOfMonth: d,
          dateLabel:
              '${d.toString().padLeft(2, '0')}/${m.toString().padLeft(2, '0')}/$y',
          trained: trained,
          caloriesGoalMet: calMet,
          waterGoalMet: waterMet,
          workoutTitle: trained
              ? daySessions.map((s) => s.workoutName).join(' + ')
              : null,
        ),
      );
    }
    return result;
  }

  /// Retorna todas as sessões concluídas pelo aluno em uma data específica.
  List<CompletedWorkoutSession> sessionsForDate(
    int year,
    int month,
    int day, {
    StudentMobileProfile? student,
  }) {
    final target = student ?? activeStudent;
    return target.completedSessions
        .where(
          (s) =>
              s.completedAt.year == year &&
              s.completedAt.month == month &&
              s.completedAt.day == day,
        )
        .toList();
  }

  /// Navega entre os meses do Calendário (ex: -1 para mês anterior, +1 para próximo mês).
  void navigateCalendarMonth(int deltaMonths) {
    final nextDate = DateTime(_calendarYear, _calendarMonth + deltaMonths, 1);
    _calendarYear = nextDate.year;
    _calendarMonth = nextDate.month;
    activeStudent.agendaDays = buildCalendarDaysForMonth(
      year: _calendarYear,
      month: _calendarMonth,
    );
    notifyListeners();
  }

  void setCalendarMonthYear(int year, int month) {
    _calendarYear = year;
    _calendarMonth = month.clamp(1, 12);
    activeStudent.agendaDays = buildCalendarDaysForMonth(
      year: _calendarYear,
      month: _calendarMonth,
    );
    notifyListeners();
  }

  /// Seleciona outro aluno (ex: Elizangela, Maycon, Carlos Souza) para testar perfis sincronizados com a Web.
  void selectStudentById(int id) {
    final idx = _students.indexWhere((s) => s.id == id);
    if (idx != -1 && idx != _selectedStudentIndex) {
      _selectedStudentIndex = idx;
      _selectedWorkoutDayIndex = 0;
      _persistAndNotify();
    }
  }


  /// Altera a aba principal (0: Home, 1: Treino, 2: Dieta, 3: You).
  void setBottomTab(int index, {int? targetYouSubTab}) {
    _bottomTabIndex = index.clamp(0, 3);
    if (_bottomTabIndex == 0 && _avatarSpace == AvatarQuickSpace.you) {
      _avatarSpace = AvatarQuickSpace.home;
    } else if (_bottomTabIndex == 3) {
      _avatarSpace = AvatarQuickSpace.you;
      if (targetYouSubTab != null) {
        _youSubTabIndex = targetYouSubTab.clamp(0, 3);
      }
    }
    notifyListeners();
  }

  /// Alterna entre 'Home', 'Community' e 'You' a partir do Avatar interativo no canto superior esquerdo.
  void setAvatarSpace(AvatarQuickSpace space) {
    _avatarSpace = space;
    if (space == AvatarQuickSpace.you) {
      _bottomTabIndex = 3;
    } else {
      _bottomTabIndex = 0;
    }
    notifyListeners();
  }

  void setYouSubTab(int index) {
    _youSubTabIndex = index.clamp(0, 3);
    notifyListeners();
  }

  void selectWorkoutDay(int index) {
    if (index >= 0 && index < activeStudent.workoutDays.length) {
      _selectedWorkoutDayIndex = index;
      notifyListeners();
    }
  }

  // ===========================================================================
  // AÇÕES DA ABA HOME E TREINO (Sessão Livre, Editar, Compartilhar, Excluir, PRs)
  // ===========================================================================

  /// Cria uma nova sessão de treino (seja avulsa pelo botão "Iniciar sessão de treino"
  /// ou ao concluir uma ficha do treinador na aba Treino) e atualiza imediatamente:
  /// - Visão Geral da Semana (volume em kg inteiros, minutos e sessões)
  /// - Recuperação Muscular por Grupamento e Mapa Anatômico de Fibras
  /// - Calendário Multi-mês
  /// - Recordes Pessoais (PRs)
  /// - Exercícios Feitos
  CompletedWorkoutSession recordWorkoutSession({
    required String workoutName,
    required double totalWeightLiftedKg,
    required int totalSets,
    required int durationMinutes,
    required List<MuscleGroup> workedMuscles,
    List<CompletedExerciseLog>? exerciseLogs,
    DateTime? completedAt,
    bool isFreeSession = false,
    String notes = '',
  }) {
    final effectiveDate = completedAt ?? _defaultNewSessionDate();
    final effectiveMuscles = workedMuscles.isNotEmpty
        ? workedMuscles
        : [MuscleGroup.peitoralMaior];

    final resolvedLogs =
        exerciseLogs ??
        _synthesizeExerciseLogsForSession(
          workoutName: workoutName,
          totalWeightLiftedKg: totalWeightLiftedKg,
          totalSets: totalSets,
          workedMuscles: effectiveMuscles,
        );

    final session = CompletedWorkoutSession(
      id: 'sess-${DateTime.now().microsecondsSinceEpoch}',
      workoutName: workoutName,
      totalWeightLiftedKg: totalWeightLiftedKg.roundToDouble(),
      totalSets: totalSets,
      durationMinutes: durationMinutes,
      completedAt: effectiveDate,
      isFreeSession: isFreeSession,
      workedMuscles: effectiveMuscles,
      exerciseLogs: resolvedLogs,
      notes: notes,
    );
    activeStudent.completedSessions.insert(0, session);
    _calendarYear = effectiveDate.year;
    _calendarMonth = effectiveDate.month;
    _persistAndNotify();
    return session;
  }

  /// Registra diretamente um exercício ou novo Recorde Pessoal (PR), criando ou anexando
  /// à sessão ativa e recalculando todos os gráficos.
  PersonalRecord recordExerciseExecutionOrPr({
    required String exerciseName,
    required MuscleGroup primaryMuscle,
    List<MuscleGroup> secondaryMuscles = const [],
    required double weightKg,
    required int reps,
    int setsCount = 3,
    SetType setType = SetType.top,
    DateTime? completedAt,
  }) {
    final dt = completedAt ?? _defaultNewSessionDate();
    final log = CompletedExerciseLog(
      exerciseName: exerciseName,
      primaryMuscle: primaryMuscle,
      secondaryMuscles: secondaryMuscles,
      sets: List.generate(
        setsCount,
        (i) => ExerciseSet(
          id: 'set-pr-${DateTime.now().microsecondsSinceEpoch}-$i',
          index: i + 1,
          type: i == setsCount - 1 ? setType : SetType.working,
          targetReps: '$reps',
          weightKg: i == setsCount - 1
              ? weightKg
              : (weightKg * 0.9).roundToDouble(),
          completedReps: reps,
          completed: true,
        ),
      ),
    );

    recordWorkoutSession(
      workoutName: 'Sessão · $exerciseName',
      totalWeightLiftedKg: log.totalVolumeKg.roundToDouble(),
      totalSets: setsCount,
      durationMinutes: 45,
      workedMuscles: [primaryMuscle, ...secondaryMuscles],
      exerciseLogs: [log],
      completedAt: dt,
      isFreeSession: true,
    );

    return activeStudent.personalRecords.firstWhere(
      (pr) => pr.exerciseName == exerciseName,
      orElse: () => PersonalRecord(
        id: 'pr-${exerciseName.hashCode.abs()}',
        exerciseName: exerciseName,
        weightKg: weightKg,
        reps: reps,
        dateLabel:
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}',
        previousBestKg: (weightKg * 0.9).roundToDouble(),
        primaryMuscle: primaryMuscle,
        secondaryMuscles: secondaryMuscles,
      ),
    );
  }

  DateTime _defaultNewSessionDate() {
    // Mantém novas sessões dentro da semana ativa dos dados (ex: Domingo 25/10/2026)
    // caso nenhuma data explícita seja informada, para que o aluno veja a barra
    // atualizar imediatamente na semana corrente.
    final sessions = activeStudent.completedSessions;
    if (sessions.isNotEmpty) {
      final latest = sessions
          .map((s) => s.completedAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      if (latest.year == 2026 && latest.month == 10 && latest.day < 25) {
        return DateTime(2026, 10, 25, 10, 30);
      }
      return latest.add(const Duration(hours: 2));
    }
    return MockRepository.defaultReferenceNow;
  }

  List<CompletedExerciseLog> _synthesizeExerciseLogsForSession({
    required String workoutName,
    required double totalWeightLiftedKg,
    required int totalSets,
    required List<MuscleGroup> workedMuscles,
  }) {
    final primary = workedMuscles.first;
    final secondary = workedMuscles.length > 1
        ? workedMuscles.sublist(1)
        : <MuscleGroup>[];

    // Procura exercício correspondente no catálogo para este grupamento
    final match = MockRepository.exerciseCatalog.firstWhere(
      (item) => item['muscle'] == primary,
      orElse: () => {
        'name': workoutName,
        'muscle': primary,
        'secondary': secondary,
      },
    );
    final exName = match['name'] as String;
    final safeSets = totalSets.clamp(1, 20);
    final avgReps = 10;
    final estimatedWeight = (totalWeightLiftedKg / (safeSets * avgReps))
        .clamp(10.0, 250.0)
        .roundToDouble();

    return [
      CompletedExerciseLog(
        exerciseName: exName,
        primaryMuscle: primary,
        secondaryMuscles: secondary,
        sets: List.generate(
          safeSets,
          (i) => ExerciseSet(
            id: 'synth-${DateTime.now().microsecondsSinceEpoch}-$i',
            index: i + 1,
            type: i == safeSets - 1 ? SetType.top : SetType.working,
            targetReps: '$avgReps',
            weightKg: estimatedWeight,
            completedReps: avgReps,
            completed: true,
          ),
        ),
      ),
    ];
  }

  /// Edita as informações de um treino feito na Home (nome, peso levantado, séries, duração, notas)
  /// e sincroniza `exerciseLogs` para que o desgaste muscular e a recuperação no gráfico 3D
  /// reflitam imediatamente a nova quantidade de séries e carga.
  void editCompletedSession({
    required String sessionId,
    required String newWorkoutName,
    required double newTotalWeightKg,
    required int newTotalSets,
    required int newDurationMinutes,
    String? newNotes,
  }) {
    final idx = activeStudent.completedSessions.indexWhere(
      (s) => s.id == sessionId,
    );
    if (idx != -1) {
      final session = activeStudent.completedSessions[idx];
      final oldSets = session.totalSets;
      final oldWeight = session.totalWeightLiftedKg;
      final clampedSets = newTotalSets.clamp(1, 100);
      final roundedWeight = newTotalWeightKg.roundToDouble();

      session.workoutName = newWorkoutName;
      session.totalWeightLiftedKg = roundedWeight;
      session.totalSets = clampedSets;
      session.durationMinutes = newDurationMinutes;
      if (newNotes != null) {
        session.notes = newNotes;
      }

      if (session.exerciseLogs.isNotEmpty &&
          (clampedSets != oldSets || roundedWeight != oldWeight)) {
        if (session.exerciseLogs.length == 1) {
          final singleLog = session.exerciseLogs.first;
          final templateSet = singleLog.sets.isNotEmpty
              ? singleLog.sets.first
              : null;
          final avgReps = templateSet?.completedReps ?? 10;
          final perSetWeight = (roundedWeight / (clampedSets * avgReps))
              .clamp(2.0, 400.0)
              .roundToDouble();
          singleLog.sets
            ..clear()
            ..addAll(
              List.generate(
                clampedSets,
                (i) => ExerciseSet(
                  id: 'edit-${session.id}-$i',
                  index: i + 1,
                  type: i == clampedSets - 1
                      ? (templateSet?.type == SetType.warmUp
                            ? SetType.top
                            : (templateSet?.type ?? SetType.top))
                      : SetType.working,
                  targetReps: templateSet?.targetReps ?? '$avgReps',
                  weightKg: perSetWeight,
                  completedReps: avgReps,
                  completed: true,
                ),
              ),
            );
        } else {
          final currentLogSets = session.exerciseLogs.fold<int>(
            0,
            (sum, l) => sum + l.sets.length,
          );
          final ratio = currentLogSets > 0
              ? clampedSets / currentLogSets
              : 1.0;
          int assigned = 0;
          for (int logIdx = 0; logIdx < session.exerciseLogs.length; logIdx++) {
            final log = session.exerciseLogs[logIdx];
            final isLast = logIdx == session.exerciseLogs.length - 1;
            final targetCount = isLast
                ? (clampedSets - assigned).clamp(1, 50)
                : (log.sets.length * ratio).round().clamp(1, 50);
            assigned += targetCount;
            final template = log.sets.isNotEmpty ? log.sets.last : null;
            final reps = template?.completedReps ?? 10;
            final weight = template?.weightKg ?? 30.0;
            log.sets
              ..clear()
              ..addAll(
                List.generate(
                  targetCount,
                  (i) => ExerciseSet(
                    id: 'edit-${session.id}-$logIdx-$i',
                    index: i + 1,
                    type: i == targetCount - 1
                        ? (template?.type ?? SetType.top)
                        : SetType.working,
                    targetReps: template?.targetReps ?? '$reps',
                    weightKg: weight,
                    completedReps: reps,
                    completed: true,
                  ),
                ),
              );
          }
        }
      }
      _persistAndNotify();
    }
  }


  /// Alterna o estado de "Salvar" (favoritar/guardar treino) no card do treino na Home.
  void toggleSaveCompletedSession(String sessionId) {
    final idx = activeStudent.completedSessions.indexWhere(
      (s) => s.id == sessionId,
    );
    if (idx != -1) {
      final session = activeStudent.completedSessions[idx];
      session.isSaved = !session.isSaved;
      _persistAndNotify();
    }
  }


  /// Compartilha um treino feito na Home para o feed da Comunidade ('Community').
  void shareCompletedSessionToCommunity(String sessionId, {String? caption}) {
    final idx = activeStudent.completedSessions.indexWhere(
      (s) => s.id == sessionId,
    );
    if (idx != -1) {
      final session = activeStudent.completedSessions[idx];
      session.isShared = true;
      _communityPosts.insert(
        0,
        CommunityPost(
          id: 'post-${DateTime.now().microsecondsSinceEpoch}',
          authorName: activeStudent.name,
          authorAvatarUrl: activeStudent.avatarUrl,
          workoutTitle: session.workoutName,
          totalVolumeKg: session.totalWeightLiftedKg,
          setsCount: session.totalSets,
          durationLabel: session.formattedDuration,
          caption: (caption != null && caption.trim().isNotEmpty)
              ? caption.trim()
              : (session.notes.isNotEmpty
                    ? session.notes
                    : 'Sessão finalizada com foco total! 💪'),
          timeAgo: 'agora mesmo',
          likesCount: 1,
          isLikedByMe: true,
        ),
      );
      _persistAndNotify();
    }
  }


  /// Publica um resumo personalizado (ex.: Recorde Pessoal) no feed da Comunidade ('Community').
  void publishCustomCommunitySummary({
    required String workoutTitle,
    required String caption,
    required num totalVolumeKg,
    required int setsCount,
    String durationLabel = 'Recorde Pessoal',
  }) {
    _communityPosts.insert(
      0,
      CommunityPost(
        id: 'post-${DateTime.now().microsecondsSinceEpoch}',
        authorName: activeStudent.name,
        authorAvatarUrl: activeStudent.avatarUrl,
        workoutTitle: workoutTitle,
        totalVolumeKg: totalVolumeKg.toDouble(),
        setsCount: setsCount,
        durationLabel: durationLabel,
        caption: caption,
        timeAgo: 'agora mesmo',
        likesCount: 1,
        isLikedByMe: true,
      ),
    );
    _persistAndNotify();
  }

  /// Exclui um treino feito da lista da Home e recalcula gráficos/calendário/recuperação.
  void deleteCompletedSession(String sessionId) {
    activeStudent.completedSessions.removeWhere((s) => s.id == sessionId);
    _persistAndNotify();
  }

  /// Curte/descurte um post da aba Community.
  void toggleLikeCommunityPost(String postId) {
    final idx = _communityPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final post = _communityPosts[idx];
      if (post.isLikedByMe) {
        post.isLikedByMe = false;
        post.likesCount = (post.likesCount - 1).clamp(0, 999999);
      } else {
        post.isLikedByMe = true;
        post.likesCount += 1;
      }
      _persistAndNotify();
    }
  }


  /// Adiciona um comentário em um post da Comunidade.
  void addCommentToCommunityPost(String postId, String text) {
    if (text.trim().isEmpty) return;
    final idx = _communityPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      _communityPosts[idx].comments.add(
        CommunityComment(
          authorName: activeStudent.name,
          text: text.trim(),
          timeAgo: 'agora',
        ),
      );
      _persistAndNotify();
    }
  }


  /// Marca notificações como lidas.
  void markAllNotificationsRead() {
    for (final n in activeStudent.notifications) {
      n.isRead = true;
    }
    _persistAndNotify();
  }

  // ===========================================================================
  // AÇÕES DA ABA TREINO (Séries, Tipos de Série, Cargas, Reps)
  // ===========================================================================

  /// Atualiza carga, repetições ou conclusão de uma série específica.
  void updateExerciseSet({
    required String exerciseId,
    required String setId,
    double? weightKg,
    int? completedReps,
    bool? completed,
  }) {
    for (final day in activeStudent.workoutDays) {
      for (final ex in day.exercises) {
        if (ex.id == exerciseId) {
          for (final s in ex.sets) {
            if (s.id == setId) {
              if (weightKg != null) s.weightKg = weightKg;
              if (completedReps != null) s.completedReps = completedReps;
              if (completed != null) s.completed = completed;
              _persistAndNotify();
              return;
            }
          }
        }
      }
    }
  }

  /// Adiciona uma nova série (com tipo de série selecionado) em um exercício.
  void addSetToExercise({
    required String exerciseId,
    required SetType type,
    String? customTypeLabel,
    required String targetReps,
    required double weightKg,
  }) {
    for (final day in activeStudent.workoutDays) {
      for (final ex in day.exercises) {
        if (ex.id == exerciseId) {
          final nextIndex = ex.sets.length + 1;
          ex.sets.add(
            ExerciseSet(
              id: 'set-${DateTime.now().microsecondsSinceEpoch}',
              index: nextIndex,
              type: type,
              customTypeLabel: customTypeLabel,
              targetReps: targetReps,
              weightKg: weightKg,
              completedReps: int.tryParse(targetReps.split(' ').first) ?? 10,
              completed: false,
            ),
          );
          _persistAndNotify();
          return;
        }
      }
    }
  }

  /// Finaliza a ficha prescrita atual, registra todos os exercícios e séries feitos
  /// e atualiza a Home + todos os gráficos da aba You.
  CompletedWorkoutSession finishActivePrescribedWorkout({
    int durationMinutes = 55,
    String notes = '',
    DateTime? completedAt,
  }) {
    final day = activeWorkoutDay;
    double volume = 0;
    int setsDone = 0;
    final muscles = <MuscleGroup>{};
    final logs = <CompletedExerciseLog>[];

    for (final ex in day.exercises) {
      muscles.add(ex.primaryMuscle);
      muscles.addAll(ex.secondaryMuscles);
      for (final s in ex.sets) {
        if (s.completed) {
          volume += s.setVolumeKg;
          setsDone += 1;
        }
      }
    }

    if (setsDone == 0) {
      // Caso o aluno finalize diretamente, contabiliza todas as séries prescritas
      for (final ex in day.exercises) {
        for (final s in ex.sets) {
          s.completed = true;
          volume += s.setVolumeKg;
          setsDone += 1;
        }
      }
    }

    for (final ex in day.exercises) {
      final completedSets = ex.sets
          .where((s) => s.completed)
          .map((s) => s.copyWith())
          .toList();
      if (completedSets.isNotEmpty) {
        logs.add(
          CompletedExerciseLog(
            exerciseName: ex.name,
            primaryMuscle: ex.primaryMuscle,
            secondaryMuscles: List.from(ex.secondaryMuscles),
            sets: completedSets,
            animationKey: ex.animationKey,
          ),
        );
      }
    }

    return recordWorkoutSession(
      workoutName: day.title,
      totalWeightLiftedKg: volume.roundToDouble(),
      totalSets: setsDone,
      durationMinutes: durationMinutes,
      workedMuscles: muscles.toList(),
      exerciseLogs: logs,
      completedAt: completedAt,
      isFreeSession: false,
      notes: notes,
    );
  }

  // ===========================================================================
  // AÇÕES DA ABA DIETA (Água, Dieta Sugerida, Fora da Dieta, Alimentos Livres)
  // ===========================================================================

  /// Adiciona ou remove água consumida (ml) na meta diária.
  void addWaterIntake(int deltaMl) {
    final tracker = activeStudent.waterTracker;
    tracker.consumedMl = (tracker.consumedMl + deltaMl).clamp(0, 10000);
    _persistAndNotify();
  }

  void updateWaterTarget(int newTargetMl) {
    if (newTargetMl >= 500) {
      activeStudent.waterTracker.targetMl = newTargetMl;
      _persistAndNotify();
    }
  }


  /// Confirma (ou desconfirma) um alimento da Dieta Sugerida pelo treinador.
  void confirmSuggestedDietFood({
    required String mealId,
    required String foodItemId,
    required bool isConfirmed,
    double? confirmedAmountGrams,
  }) {
    for (final meal in activeStudent.suggestedMeals) {
      if (meal.id == mealId) {
        for (final item in meal.items) {
          if (item.id == foodItemId) {
            item.isConfirmed = isConfirmed;
            item.isReplacedOffDiet = false;
            if (confirmedAmountGrams != null && confirmedAmountGrams > 0) {
              item.confirmedAmountGrams = confirmedAmountGrams;
            }
            _persistAndNotify();
            return;
          }
        }
      }
    }
  }

  /// Registra substituição por alimento fora da dieta.
  void replaceSuggestedFoodWithOffDiet({
    required String mealId,
    required String foodItemId,
    required String offDietFoodName,
    required double offDietAmountGrams,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) {
    for (final meal in activeStudent.suggestedMeals) {
      if (meal.id == mealId) {
        for (final item in meal.items) {
          if (item.id == foodItemId) {
            item.isConfirmed = true;
            item.isReplacedOffDiet = true;
            item.offDietFoodName = offDietFoodName;
            item.offDietAmountGrams = offDietAmountGrams;
            item.offDietNutrients = NutrientProfile(
              calories: calories,
              proteinG: proteinG,
              carbsG: carbsG,
              fatG: fatG,
              fiberG: (carbsG * 0.08),
              sodiumMg: (calories * 0.65),
              potassiumMg: (calories * 1.1),
              calciumMg: (proteinG * 3.2),
              ironMg: (proteinG * 0.07),
              magnesiumMg: (carbsG * 0.9),
              vitaminCMg: 4.0,
              vitaminDMcg: 0.5,
              vitaminB12Mcg: 0.4,
            );
            _persistAndNotify();
            return;
          }
        }
      }
    }
  }

  /// Cadastra um alimento consumido avulso.
  void addCustomConsumedFood({
    required String name,
    required double amountGrams,
    required String mealOccasion,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    double fiberG = 2.0,
    double sodiumMg = 120.0,
    double potassiumMg = 180.0,
  }) {
    activeStudent.customConsumedFoods.insert(
      0,
      CustomConsumedFood(
        id: 'cust-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        amountGrams: amountGrams,
        mealOccasion: mealOccasion,
        loggedAt: DateTime.now(),
        nutrients: NutrientProfile(
          calories: calories,
          proteinG: proteinG,
          carbsG: carbsG,
          fatG: fatG,
          fiberG: fiberG,
          sodiumMg: sodiumMg,
          potassiumMg: potassiumMg,
          calciumMg: (proteinG * 2.5),
          ironMg: (proteinG * 0.06),
          magnesiumMg: (carbsG * 0.7),
          vitaminCMg: 6.0,
          vitaminDMcg: 0.4,
          vitaminB12Mcg: 0.3,
        ),
      ),
    );
    _persistAndNotify();
  }

  void removeCustomConsumedFood(String foodId) {
    activeStudent.customConsumedFoods.removeWhere((f) => f.id == foodId);
    _persistAndNotify();
  }

  // ===========================================================================
  // AÇÕES DA ABA YOU (Medidas, Fotos de Evolução, Anamnese)
  // ===========================================================================

  /// Registra novas medidas corporais e de grupamentos musculares.
  void addBodyMeasurement({
    required double weightKg,
    required double bodyFatPercent,
    required Map<String, double> circumferencesCm,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    activeStudent.bodyMeasurements.insert(
      0,
      BodyMeasurementEntry(
        id: 'meas-${now.microsecondsSinceEpoch}',
        dateLabel: dateStr,
        weightKg: weightKg,
        bodyFatPercent: bodyFatPercent,
        circumferencesCm: circumferencesCm,
      ),
    );
    activeStudent.currentWeightKg = weightKg;
    activeStudent.bodyFatPercent = bodyFatPercent;
    _persistAndNotify();
  }

  /// Adiciona uma nova foto da evolução do aluno (Frente, Costas ou Perfil).
  void addEvolutionPhoto({
    required String pose,
    required double weightKg,
    required String notes,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    activeStudent.evolutionPhotos.insert(
      0,
      EvolutionPhoto(
        id: 'photo-${now.microsecondsSinceEpoch}',
        pose: pose,
        dateLabel: dateStr,
        weightKg: weightKg,
        notes: notes,
        imageUrl: 'https://i.pravatar.cc/300?u=${now.millisecondsSinceEpoch}',
      ),
    );
    _persistAndNotify();
  }

  /// Envia um novo formulário de Anamnese (Corporal, Alimentar e Espacial) com status 'Pendente'.
  AnamnesisSubmission submitAnamnesis({
    required String type,
    required Map<String, String> corporalAnswers,
    required Map<String, String> alimentarAnswers,
    required Map<String, String> espacialAnswers,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final nextId = activeStudent.anamnesisSubmissions.length + 10;
    final submission = AnamnesisSubmission(
      id: nextId,
      studentName: activeStudent.name,
      type: type,
      dateLabel: dateStr,
      status: 'Pendente',
      corporalAnswers: corporalAnswers,
      alimentarAnswers: alimentarAnswers,
      espacialAnswers: espacialAnswers,
    );
    activeStudent.anamnesisSubmissions.insert(0, submission);
    _persistAndNotify();
    return submission;
  }

  /// Exporta o payload completo de sincronização Mobile -> Web em JSON formatado.
  String exportSyncPayloadJson({int? studentId}) {
    final target = studentId != null
        ? _students.firstWhere(
            (s) => s.id == studentId,
            orElse: () => activeStudent,
          )
        : activeStudent;
    final payload = {
      'schemaVersion': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'student': target.toSyncJson(),
      'communityFeed': _communityPosts.map((p) => p.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
