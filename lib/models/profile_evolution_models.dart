import 'nutrition_models.dart';
import 'workout_models.dart';

/// Modelos da aba "You" (Visão Geral, Recuperação Muscular SRA, Ilustração Anatômica de Fibras,
/// Exercícios Feitos, Medidas, Fotos, Anamnese & Avaliação Física do Professor),
/// além da Agenda Comparativa, Sininho de Notificações e Comunidade ("Community").

class WeeklyTrainingMetric {
  final String label; // ex: 'Seg', 'Ter', 'Qua'
  final int durationMinutes;
  final double volumeKg;
  final int workoutsCount;
  final List<String> sessionTitles;

  const WeeklyTrainingMetric({
    required this.label,
    required this.durationMinutes,
    required this.volumeKg,
    required this.workoutsCount,
    this.sessionTitles = const [],
  });

  /// Peso total levantado em kg inteiros (nunca número racional/tonelada decimal).
  int get integerVolumeKg => volumeKg.round();

  Map<String, dynamic> toJson() => {
    'label': label,
    'durationMinutes': durationMinutes,
    'volumeKg': integerVolumeKg,
    'workoutsCount': workoutsCount,
    'sessionTitles': sessionTitles,
  };

  factory WeeklyTrainingMetric.fromJson(Map<String, dynamic> json) =>
      WeeklyTrainingMetric(
        label: json['label'] as String,
        durationMinutes: (json['durationMinutes'] as num).round(),
        volumeKg: (json['volumeKg'] as num).toDouble(),
        workoutsCount: (json['workoutsCount'] as num).round(),
        sessionTitles:
            (json['sessionTitles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}

/// Status de recuperação muscular e ativação semanal por subdivisão anatômica (~19 músculos).
class MuscleRecoveryStatus {
  final MuscleGroup group;
  final int recoveryPercent; // 0 a 100%
  final int weeklySetsCompleted;
  final int hoursSinceLastTrained;
  final double residualFatigueDose;

  const MuscleRecoveryStatus({
    required this.group,
    required this.recoveryPercent,
    required this.weeklySetsCompleted,
    required this.hoursSinceLastTrained,
    this.residualFatigueDose = 0.0,
  });

  bool get workedThisWeek => weeklySetsCompleted > 0;

  /// Percentual de desgaste muscular (0 a 100%) derivado do cálculo de fadiga/recuperação
  /// e do recrutamento semanal nos treinos registrados pelo aluno.
  int get wearPercent {
    if (!workedThisWeek && recoveryPercent >= 100) {
      return 0;
    }
    final acuteWear = (100 - recoveryPercent).clamp(0, 100);
    final minWeeklyWear = (weeklySetsCompleted * 3).clamp(6, 35);
    return acuteWear > minWeeklyWear ? acuteWear : minWeeklyWear;
  }

  /// Índice normalizado de desgaste (0.0 = menos desgaste / azul, 1.0 = mais desgaste / vermelho).
  double get wearNormalized => (wearPercent / 100.0).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'group': group.name,
    'recoveryPercent': recoveryPercent,
    'wearPercent': wearPercent,
    'weeklySetsCompleted': weeklySetsCompleted,
    'hoursSinceLastTrained': hoursSinceLastTrained,
    'residualFatigueDose': double.parse(
      residualFatigueDose.toStringAsFixed(2),
    ),
  };

  factory MuscleRecoveryStatus.fromJson(Map<String, dynamic> json) =>
      MuscleRecoveryStatus(
        group: MuscleGroup.fromKey(json['group'] as String),
        recoveryPercent: (json['recoveryPercent'] as num).round(),
        weeklySetsCompleted: (json['weeklySetsCompleted'] as num).round(),
        hoursSinceLastTrained: (json['hoursSinceLastTrained'] as num).round(),
        residualFatigueDose:
            (json['residualFatigueDose'] as num?)?.toDouble() ?? 0.0,
      );
}

/// Recorde Pessoal (PR) batido pelo aluno, acompanhado de animação biomecânica do exercício.
class PersonalRecord {
  final String id;
  final String exerciseName;
  final double weightKg;
  final int reps;
  final String dateLabel;
  final double previousBestKg;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final String animationKey;
  final String? referenceGifPath;

  PersonalRecord({
    required this.id,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.dateLabel,
    required this.previousBestKg,
    MuscleGroup? primaryMuscle,
    this.secondaryMuscles = const [],
    String? animationKey,
    this.referenceGifPath,
  }) : primaryMuscle = primaryMuscle ?? _inferPrimaryMuscle(exerciseName),
       animationKey =
           animationKey ?? WorkoutExercise.inferAnimationKey(exerciseName);

  static MuscleGroup _inferPrimaryMuscle(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('inclinado')) return MuscleGroup.peitoralSuperior;
    if (lower.contains('supino') ||
        lower.contains('crucifixo') ||
        lower.contains('crossover')) {
      return MuscleGroup.peitoralMaior;
    }
    if (lower.contains('agachamento') || lower.contains('leg press')) {
      return MuscleGroup.quadriceps;
    }
    if (lower.contains('elevação pélvica')) return MuscleGroup.gluteoMaximo;
    if (lower.contains('stiff')) return MuscleGroup.posteriores;
    if (lower.contains('puxada') || lower.contains('remada')) {
      return MuscleGroup.dorsal;
    }
    if (lower.contains('elevação lateral')) return MuscleGroup.deltoideLateral;
    if (lower.contains('desenvolvimento')) return MuscleGroup.deltoideAnterior;
    if (lower.contains('rosca')) return MuscleGroup.biceps;
    if (lower.contains('tríceps') || lower.contains('triceps')) {
      return MuscleGroup.triceps;
    }
    if (lower.contains('panturrilha')) return MuscleGroup.panturrilhas;
    return MuscleGroup.peitoralMaior;
  }

  double get improvementKg => weightKg - previousBestKg;
  int get integerWeightKg => weightKg.round();
  int get integerPreviousBestKg => previousBestKg.round();
  int get integerImprovementKg =>
      (weightKg - previousBestKg).round().clamp(1, 9999);

  /// 1RM estimado via fórmula de Epley.
  int get estimatedOneRepMaxKg =>
      reps <= 1 ? weightKg.round() : (weightKg * (1.0 + reps / 30.0)).round();

  /// Converte `'23/10/2026'` em `'23 out. 2026'`.
  String get shortPtDateLabel {
    const months = [
      'jan.',
      'fev.',
      'mar.',
      'abr.',
      'mai.',
      'jun.',
      'jul.',
      'ago.',
      'set.',
      'out.',
      'nov.',
      'dez.',
    ];
    final parts = dateLabel.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null && m >= 1 && m <= 12) {
        return '${d.toString().padLeft(2, '0')} ${months[m - 1]} $y';
      }
    }
    return dateLabel;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseName': exerciseName,
    'weightKg': weightKg,
    'reps': reps,
    'dateLabel': dateLabel,
    'previousBestKg': previousBestKg,
    'primaryMuscle': primaryMuscle.name,
    'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
    'animationKey': animationKey,
    if (referenceGifPath != null) 'referenceGifPath': referenceGifPath,
  };

  factory PersonalRecord.fromJson(Map<String, dynamic> json) => PersonalRecord(
    id: json['id'] as String,
    exerciseName: json['exerciseName'] as String,
    weightKg: (json['weightKg'] as num).toDouble(),
    reps: json['reps'] as int,
    dateLabel: json['dateLabel'] as String,
    previousBestKg: (json['previousBestKg'] as num).toDouble(),
    primaryMuscle: json['primaryMuscle'] != null
        ? MuscleGroup.fromKey(json['primaryMuscle'] as String)
        : null,
    secondaryMuscles:
        (json['secondaryMuscles'] as List<dynamic>?)
            ?.map((e) => MuscleGroup.fromKey(e as String))
            .toList() ??
        const [],
    animationKey: json['animationKey'] as String?,
    referenceGifPath: json['referenceGifPath'] as String?,
  );
}

/// Ponto de evolução de carga de um exercício específico.
class WeightMarkPoint {
  final String label; // ex: 'Sessão 1 (Seg)', 'Sem 1', 'Ago', '2026'
  final double maxWeightKg;
  final int reps;
  final String? sessionDateLabel;

  const WeightMarkPoint({
    required this.label,
    required this.maxWeightKg,
    required this.reps,
    this.sessionDateLabel,
  });

  int get integerMaxWeightKg => maxWeightKg.round();

  Map<String, dynamic> toJson() => {
    'label': label,
    'maxWeightKg': maxWeightKg,
    'reps': reps,
    if (sessionDateLabel != null) 'sessionDateLabel': sessionDateLabel,
  };

  factory WeightMarkPoint.fromJson(Map<String, dynamic> json) =>
      WeightMarkPoint(
        label: json['label'] as String,
        maxWeightKg: (json['maxWeightKg'] as num).toDouble(),
        reps: json['reps'] as int,
        sessionDateLabel: json['sessionDateLabel'] as String?,
      );
}

/// Histórico de evolução de cargas de um exercício em Semana (Sessões na semana vs. Semanas do mês), Mês e Ano.
class ExerciseWeightEvolution {
  final String exerciseName;
  final MuscleGroup muscleGroup;
  final List<WeightMarkPoint> weeklyMarks;
  final List<WeightMarkPoint> monthlyMarks;
  final List<WeightMarkPoint> yearlyMarks;
  final int occurrencesInActiveWeek;
  final String weeklyComparisonSubtitle;

  const ExerciseWeightEvolution({
    required this.exerciseName,
    required this.muscleGroup,
    required this.weeklyMarks,
    required this.monthlyMarks,
    required this.yearlyMarks,
    this.occurrencesInActiveWeek = 1,
    this.weeklyComparisonSubtitle =
        'Comparativo entre semanas do mesmo mês (1x na semana)',
  });

  bool get isIntraWeekSessionComparison => occurrencesInActiveWeek >= 2;

  Map<String, dynamic> toJson() => {
    'exerciseName': exerciseName,
    'muscleGroup': muscleGroup.name,
    'occurrencesInActiveWeek': occurrencesInActiveWeek,
    'weeklyComparisonSubtitle': weeklyComparisonSubtitle,
    'weeklyMarks': weeklyMarks.map((e) => e.toJson()).toList(),
    'monthlyMarks': monthlyMarks.map((e) => e.toJson()).toList(),
    'yearlyMarks': yearlyMarks.map((e) => e.toJson()).toList(),
  };

  factory ExerciseWeightEvolution.fromJson(Map<String, dynamic> json) =>
      ExerciseWeightEvolution(
        exerciseName: json['exerciseName'] as String,
        muscleGroup: MuscleGroup.fromKey(json['muscleGroup'] as String),
        occurrencesInActiveWeek:
            (json['occurrencesInActiveWeek'] as num?)?.round() ?? 1,
        weeklyComparisonSubtitle:
            json['weeklyComparisonSubtitle'] as String? ??
            'Comparativo entre semanas do mesmo mês',
        weeklyMarks: (json['weeklyMarks'] as List<dynamic>)
            .map((e) => WeightMarkPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        monthlyMarks: (json['monthlyMarks'] as List<dynamic>)
            .map((e) => WeightMarkPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        yearlyMarks: (json['yearlyMarks'] as List<dynamic>)
            .map((e) => WeightMarkPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Registro de medidas corporais e de grupamentos musculares (cm / kg / %).
class BodyMeasurementEntry {
  final String id;
  final String dateLabel;
  final double weightKg;
  final double bodyFatPercent;
  final Map<String, double> circumferencesCm;

  BodyMeasurementEntry({
    required this.id,
    required this.dateLabel,
    required this.weightKg,
    required this.bodyFatPercent,
    required this.circumferencesCm,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateLabel': dateLabel,
    'weightKg': weightKg,
    'bodyFatPercent': bodyFatPercent,
    'circumferencesCm': circumferencesCm,
  };

  factory BodyMeasurementEntry.fromJson(Map<String, dynamic> json) =>
      BodyMeasurementEntry(
        id: json['id'] as String,
        dateLabel: json['dateLabel'] as String,
        weightKg: (json['weightKg'] as num).toDouble(),
        bodyFatPercent: (json['bodyFatPercent'] as num).toDouble(),
        circumferencesCm: (json['circumferencesCm'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      );
}

/// Foto de evolução do aluno (Frente, Costas, Perfil).
class EvolutionPhoto {
  final String id;
  final String pose; // 'Frente', 'Costas', 'Perfil'
  final String dateLabel;
  final double weightKg;
  final String notes;
  final String imageUrl;

  const EvolutionPhoto({
    required this.id,
    required this.pose,
    required this.dateLabel,
    required this.weightKg,
    this.notes = '',
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'pose': pose,
    'dateLabel': dateLabel,
    'weightKg': weightKg,
    'notes': notes,
    'imageUrl': imageUrl,
  };

  factory EvolutionPhoto.fromJson(Map<String, dynamic> json) => EvolutionPhoto(
    id: json['id'] as String,
    pose: json['pose'] as String,
    dateLabel: json['dateLabel'] as String,
    weightKg: (json['weightKg'] as num).toDouble(),
    notes: json['notes'] as String? ?? '',
    imageUrl: json['imageUrl'] as String,
  );
}

/// Avaliação Física & Antropométrica realizada pelo Professor (exibida em "Central de Anamneses").
class CoachPhysicalAssessment {
  final String id;
  final String coachName;
  final String evaluatedAt;
  final String protocolName; // ex: 'Pollock 7 Dobras + Bioimpedância'
  final double weightKg;
  final double heightMeters;
  final double bodyFatPercent;
  final double leanMassPercent;
  final double visceralFatLevel;
  final int basalMetabolicRateKcal;
  final double previousWeightKg;
  final double previousBodyFatPercent;
  final double previousLeanMassPercent;
  final Map<String, double> skinfoldsMm;
  final Map<String, double> keyCircumferencesCm;
  final String posturalAssessment;
  final String coachDiagnosticNotes;

  const CoachPhysicalAssessment({
    required this.id,
    required this.coachName,
    required this.evaluatedAt,
    required this.protocolName,
    required this.weightKg,
    required this.heightMeters,
    required this.bodyFatPercent,
    required this.leanMassPercent,
    required this.visceralFatLevel,
    required this.basalMetabolicRateKcal,
    required this.previousWeightKg,
    required this.previousBodyFatPercent,
    required this.previousLeanMassPercent,
    required this.skinfoldsMm,
    required this.keyCircumferencesCm,
    required this.posturalAssessment,
    required this.coachDiagnosticNotes,
  });

  int get heightCm => (heightMeters * 100).round();
  double get bmi => weightKg / (heightMeters * heightMeters);
  double get fatMassKg => weightKg * (bodyFatPercent / 100.0);
  double get leanMassKg => weightKg * (leanMassPercent / 100.0);
  double get weightDeltaKg => weightKg - previousWeightKg;
  double get bodyFatDeltaPercent => bodyFatPercent - previousBodyFatPercent;
  double get leanMassDeltaPercent => leanMassPercent - previousLeanMassPercent;

  Map<String, dynamic> toJson() => {
    'id': id,
    'coachName': coachName,
    'evaluatedAt': evaluatedAt,
    'protocolName': protocolName,
    'weightKg': weightKg,
    'heightMeters': heightMeters,
    'bodyFatPercent': bodyFatPercent,
    'leanMassPercent': leanMassPercent,
    'visceralFatLevel': visceralFatLevel,
    'basalMetabolicRateKcal': basalMetabolicRateKcal,
    'previousWeightKg': previousWeightKg,
    'previousBodyFatPercent': previousBodyFatPercent,
    'previousLeanMassPercent': previousLeanMassPercent,
    'skinfoldsMm': skinfoldsMm,
    'keyCircumferencesCm': keyCircumferencesCm,
    'posturalAssessment': posturalAssessment,
    'coachDiagnosticNotes': coachDiagnosticNotes,
  };

  factory CoachPhysicalAssessment.fromJson(Map<String, dynamic> json) =>
      CoachPhysicalAssessment(
        id: json['id'] as String,
        coachName: json['coachName'] as String,
        evaluatedAt: json['evaluatedAt'] as String,
        protocolName: json['protocolName'] as String,
        weightKg: (json['weightKg'] as num).toDouble(),
        heightMeters: (json['heightMeters'] as num).toDouble(),
        bodyFatPercent: (json['bodyFatPercent'] as num).toDouble(),
        leanMassPercent: (json['leanMassPercent'] as num).toDouble(),
        visceralFatLevel: (json['visceralFatLevel'] as num).toDouble(),
        basalMetabolicRateKcal: (json['basalMetabolicRateKcal'] as num).round(),
        previousWeightKg: (json['previousWeightKg'] as num).toDouble(),
        previousBodyFatPercent:
            (json['previousBodyFatPercent'] as num).toDouble(),
        previousLeanMassPercent:
            (json['previousLeanMassPercent'] as num).toDouble(),
        skinfoldsMm: (json['skinfoldsMm'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
        keyCircumferencesCm:
            (json['keyCircumferencesCm'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, (v as num).toDouble()),
            ),
        posturalAssessment: json['posturalAssessment'] as String,
        coachDiagnosticNotes: json['coachDiagnosticNotes'] as String,
      );
}

/// Resposta de formulário de Anamnese (Corporal, Alimentar e Espacial) sincronizada com a Web.
class AnamnesisSubmission {
  final int id;
  final String studentName;
  final String type; // 'Anamnese Completa', 'Pré-seleção', etc.
  final String dateLabel;
  String status; // 'Pendente', 'Analisado', 'Negado'
  final Map<String, String> corporalAnswers;
  final Map<String, String> alimentarAnswers;
  final Map<String, String> espacialAnswers;

  AnamnesisSubmission({
    required this.id,
    required this.studentName,
    required this.type,
    required this.dateLabel,
    required this.status,
    required this.corporalAnswers,
    required this.alimentarAnswers,
    required this.espacialAnswers,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'aluno': studentName,
    'tipo': type,
    'data': dateLabel,
    'status': status,
    'secoes': [
      {
        'titulo': 'Anamnese Corporal',
        'respostas': corporalAnswers.entries
            .map((e) => {'pergunta': e.key, 'resposta': e.value})
            .toList(),
      },
      {
        'titulo': 'Anamnese Alimentar',
        'respostas': alimentarAnswers.entries
            .map((e) => {'pergunta': e.key, 'resposta': e.value})
            .toList(),
      },
      {
        'titulo': 'Anamnese Espacial',
        'respostas': espacialAnswers.entries
            .map((e) => {'pergunta': e.key, 'resposta': e.value})
            .toList(),
      },
    ],
  };

  factory AnamnesisSubmission.fromJson(Map<String, dynamic> json) {
    final corporal = <String, String>{};
    final alimentar = <String, String>{};
    final espacial = <String, String>{};

    final secoes = json['secoes'] as List<dynamic>? ?? const [];
    for (final s in secoes) {
      final map = s as Map<String, dynamic>;
      final titulo = map['titulo'] as String? ?? '';
      final respostas = map['respostas'] as List<dynamic>? ?? const [];
      for (final r in respostas) {
        final rMap = r as Map<String, dynamic>;
        final p = rMap['pergunta'] as String;
        final resp = rMap['resposta'] as String;
        if (titulo.contains('Corporal')) {
          corporal[p] = resp;
        } else if (titulo.contains('Alimentar')) {
          alimentar[p] = resp;
        } else {
          espacial[p] = resp;
        }
      }
    }

    return AnamnesisSubmission(
      id: json['id'] as int,
      studentName: json['aluno'] as String,
      type: json['tipo'] as String,
      dateLabel: json['data'] as String,
      status: json['status'] as String,
      corporalAnswers: corporal,
      alimentarAnswers: alimentar,
      espacialAnswers: espacial,
    );
  }
}

/// Registro diário para a Agenda Comparativa (dias treinados vs. não treinados,
/// metas batidas vs. não batidas dentro de determinado prazo).
class AgendaDayComparison {
  final int dayOfMonth;
  final String dateLabel;
  final bool trained;
  final bool caloriesGoalMet;
  final bool waterGoalMet;
  final String? workoutTitle;

  const AgendaDayComparison({
    required this.dayOfMonth,
    required this.dateLabel,
    required this.trained,
    required this.caloriesGoalMet,
    required this.waterGoalMet,
    this.workoutTitle,
  });

  bool get allGoalsMet => trained && caloriesGoalMet && waterGoalMet;

  Map<String, dynamic> toJson() => {
    'dayOfMonth': dayOfMonth,
    'dateLabel': dateLabel,
    'trained': trained,
    'caloriesGoalMet': caloriesGoalMet,
    'waterGoalMet': waterGoalMet,
    if (workoutTitle != null) 'workoutTitle': workoutTitle,
  };

  factory AgendaDayComparison.fromJson(Map<String, dynamic> json) =>
      AgendaDayComparison(
        dayOfMonth: json['dayOfMonth'] as int,
        dateLabel: json['dateLabel'] as String,
        trained: json['trained'] as bool,
        caloriesGoalMet: json['caloriesGoalMet'] as bool,
        waterGoalMet: json['waterGoalMet'] as bool,
        workoutTitle: json['workoutTitle'] as String?,
      );
}

/// Comentário na aba Community.
class CommunityComment {
  final String authorName;
  final String text;
  final String timeAgo;

  const CommunityComment({
    required this.authorName,
    required this.text,
    required this.timeAgo,
  });

  Map<String, dynamic> toJson() => {
    'authorName': authorName,
    'text': text,
    'timeAgo': timeAgo,
  };

  factory CommunityComment.fromJson(Map<String, dynamic> json) =>
      CommunityComment(
        authorName: json['authorName'] as String,
        text: json['text'] as String,
        timeAgo: json['timeAgo'] as String,
      );
}

/// Post compartilhado na Comunidade ('Community', alternada pelo Avatar da Home).
class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String workoutTitle;
  final double totalVolumeKg;
  final int setsCount;
  final String durationLabel;
  final String caption;
  final String timeAgo;
  int likesCount;
  bool isLikedByMe;
  final List<CommunityComment> comments;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.workoutTitle,
    required this.totalVolumeKg,
    required this.setsCount,
    required this.durationLabel,
    required this.caption,
    required this.timeAgo,
    this.likesCount = 0,
    this.isLikedByMe = false,
    List<CommunityComment>? comments,
  }) : comments = comments ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorName': authorName,
    'authorAvatarUrl': authorAvatarUrl,
    'workoutTitle': workoutTitle,
    'totalVolumeKg': totalVolumeKg,
    'setsCount': setsCount,
    'durationLabel': durationLabel,
    'caption': caption,
    'timeAgo': timeAgo,
    'likesCount': likesCount,
    'isLikedByMe': isLikedByMe,
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    id: json['id'] as String,
    authorName: json['authorName'] as String,
    authorAvatarUrl: json['authorAvatarUrl'] as String,
    workoutTitle: json['workoutTitle'] as String,
    totalVolumeKg: (json['totalVolumeKg'] as num).toDouble(),
    setsCount: json['setsCount'] as int,
    durationLabel: json['durationLabel'] as String,
    caption: json['caption'] as String,
    timeAgo: json['timeAgo'] as String,
    likesCount: json['likesCount'] as int? ?? 0,
    isLikedByMe: json['isLikedByMe'] as bool? ?? false,
    comments: (json['comments'] as List<dynamic>?)
        ?.map((c) => CommunityComment.fromJson(c as Map<String, dynamic>))
        .toList(),
  );
}

enum NotificationCategory {
  coachWorkoutUpdate,
  coachMessage,
  communityLike,
  communityComment,
  anamnesisRequest,
}

/// Item do Sininho de Notificações no canto superior direito da Home.
class RecNotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final NotificationCategory category;
  bool isRead;

  RecNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.category,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'timeAgo': timeAgo,
    'category': category.name,
    'isRead': isRead,
  };

  factory RecNotificationItem.fromJson(Map<String, dynamic> json) =>
      RecNotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timeAgo: json['timeAgo'] as String,
        category: NotificationCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => NotificationCategory.coachMessage,
        ),
        isRead: json['isRead'] as bool? ?? false,
      );
}

/// Perfil completo do Aluno sincronizado entre Mobile e Web (`AlunoDetalhe` do `mock.ts`).
class StudentMobileProfile {
  final int id;
  final String name;
  final String plan;
  final String objective;
  final String avatarUrl;
  final String startDate;
  final String subscriptionStatus; // 'Em dia', 'Atrasado', 'Pendente'
  double currentWeightKg;
  final double targetWeightKg;
  double bodyFatPercent;
  final NutrientProfile dailyTargetNutrients;
  final WaterIntakeTracker waterTracker;
  final List<WorkoutPlanDay> workoutDays;
  final List<CompletedWorkoutSession> completedSessions;
  final List<SuggestedMeal> suggestedMeals;
  final List<CustomConsumedFood> customConsumedFoods;
  List<WeeklyTrainingMetric> weeklyMetrics;
  List<MuscleRecoveryStatus> muscleRecovery;
  List<PersonalRecord> personalRecords;
  List<ExerciseWeightEvolution> exerciseEvolutions;
  final List<BodyMeasurementEntry> bodyMeasurements;
  final List<EvolutionPhoto> evolutionPhotos;
  final List<AnamnesisSubmission> anamnesisSubmissions;
  CoachPhysicalAssessment coachPhysicalAssessment;
  List<AgendaDayComparison> agendaDays;
  final List<RecNotificationItem> notifications;

  StudentMobileProfile({
    required this.id,
    required this.name,
    required this.plan,
    required this.objective,
    required this.avatarUrl,
    required this.startDate,
    required this.subscriptionStatus,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.bodyFatPercent,
    required this.dailyTargetNutrients,
    required this.waterTracker,
    required this.workoutDays,
    required this.completedSessions,
    required this.suggestedMeals,
    required this.customConsumedFoods,
    required this.weeklyMetrics,
    required this.muscleRecovery,
    required this.personalRecords,
    required this.exerciseEvolutions,
    required this.bodyMeasurements,
    required this.evolutionPhotos,
    required this.anamnesisSubmissions,
    required this.coachPhysicalAssessment,
    required this.agendaDays,
    required this.notifications,
  });

  /// Soma todos os nutrientes ingeridos na Dieta Sugerida + Alimentos Consumidos fora da dieta.
  NutrientProfile get totalIngestedNutrients {
    final fromSuggested = suggestedMeals.fold(
      NutrientProfile.zero,
      (acc, meal) => acc + meal.totalIngestedNutrients,
    );
    final fromCustom = customConsumedFoods.fold(
      NutrientProfile.zero,
      (acc, food) => acc + food.nutrients,
    );
    return fromSuggested + fromCustom;
  }

  /// Exporta o estado completo do aluno em formato JSON compatível com o painel Web do professor e persistência local.
  Map<String, dynamic> toSyncJson() => {
    'id': id,
    'nome': name,
    'plano': plan,
    'objetivo': objective,
    'foto': avatarUrl,
    'inicio': startDate,
    'statusAssinatura': subscriptionStatus,
    'pesoAtual': currentWeightKg,
    'pesoMeta': targetWeightKg,
    'gorduraAtual': bodyFatPercent,
    'macros': {
      'proteinas': totalIngestedNutrients.proteinG.round(),
      'carboidratos': totalIngestedNutrients.carbsG.round(),
      'gorduras': totalIngestedNutrients.fatG.round(),
      'metaCalorica': dailyTargetNutrients.calories.round(),
      'caloriasAtuais': totalIngestedNutrients.calories.round(),
    },
    'macrosMeta': {
      'proteinas': dailyTargetNutrients.proteinG.round(),
      'carboidratos': dailyTargetNutrients.carbsG.round(),
      'gorduras': dailyTargetNutrients.fatG.round(),
    },
    'nutrientesDetalhadosIngeridos': totalIngestedNutrients.toJson(),
    'nutrientesMetaDiaria': dailyTargetNutrients.toJson(),
    'agua': waterTracker.toJson(),
    'fichasTreino': workoutDays.map((w) => w.toJson()).toList(),
    'sessoesTreinoExecutadas': completedSessions
        .map((s) => s.toJson())
        .toList(),
    'dietaSugerida': suggestedMeals.map((m) => m.toJson()).toList(),
    'alimentosConsumidosAvulsos': customConsumedFoods
        .map((c) => c.toJson())
        .toList(),
    'metricasSemanais': weeklyMetrics.map((m) => m.toJson()).toList(),
    'recuperacaoMuscular': muscleRecovery.map((m) => m.toJson()).toList(),
    'recordesPessoais': personalRecords.map((p) => p.toJson()).toList(),
    'evolucaoExercicios': exerciseEvolutions.map((e) => e.toJson()).toList(),
    'medidasCorporais': bodyMeasurements.map((b) => b.toJson()).toList(),
    'fotosEvolucao': evolutionPhotos.map((p) => p.toJson()).toList(),
    'anamneses': anamnesisSubmissions.map((a) => a.toJson()).toList(),
    'avaliacaoFisicaProfessor': coachPhysicalAssessment.toJson(),
    'agendaComparativa': agendaDays.map((a) => a.toJson()).toList(),
    'notificacoes': notifications.map((n) => n.toJson()).toList(),
  };

  factory StudentMobileProfile.fromSyncJson(Map<String, dynamic> json) {
    return StudentMobileProfile(
      id: json['id'] as int,
      name: json['nome'] as String,
      plan: json['plano'] as String,
      objective: json['objetivo'] as String,
      avatarUrl: json['foto'] as String,
      startDate: json['inicio'] as String,
      subscriptionStatus: json['statusAssinatura'] as String,
      currentWeightKg: (json['pesoAtual'] as num).toDouble(),
      targetWeightKg: (json['pesoMeta'] as num).toDouble(),
      bodyFatPercent: (json['gorduraAtual'] as num).toDouble(),
      dailyTargetNutrients: NutrientProfile.fromJson(
        json['nutrientesMetaDiaria'] as Map<String, dynamic>,
      ),
      waterTracker: WaterIntakeTracker.fromJson(
        json['agua'] as Map<String, dynamic>,
      ),
      workoutDays: (json['fichasTreino'] as List<dynamic>)
          .map((w) => WorkoutPlanDay.fromJson(w as Map<String, dynamic>))
          .toList(),
      completedSessions: (json['sessoesTreinoExecutadas'] as List<dynamic>)
          .map(
            (s) => CompletedWorkoutSession.fromJson(s as Map<String, dynamic>),
          )
          .toList(),
      suggestedMeals: (json['dietaSugerida'] as List<dynamic>)
          .map((m) => SuggestedMeal.fromJson(m as Map<String, dynamic>))
          .toList(),
      customConsumedFoods: (json['alimentosConsumidosAvulsos'] as List<dynamic>)
          .map((c) => CustomConsumedFood.fromJson(c as Map<String, dynamic>))
          .toList(),
      weeklyMetrics: (json['metricasSemanais'] as List<dynamic>)
          .map((m) => WeeklyTrainingMetric.fromJson(m as Map<String, dynamic>))
          .toList(),
      muscleRecovery: (json['recuperacaoMuscular'] as List<dynamic>)
          .map((m) => MuscleRecoveryStatus.fromJson(m as Map<String, dynamic>))
          .toList(),
      personalRecords: (json['recordesPessoais'] as List<dynamic>)
          .map((p) => PersonalRecord.fromJson(p as Map<String, dynamic>))
          .toList(),
      exerciseEvolutions: (json['evolucaoExercicios'] as List<dynamic>)
          .map(
            (e) => ExerciseWeightEvolution.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      bodyMeasurements: (json['medidasCorporais'] as List<dynamic>)
          .map((b) => BodyMeasurementEntry.fromJson(b as Map<String, dynamic>))
          .toList(),
      evolutionPhotos: (json['fotosEvolucao'] as List<dynamic>)
          .map((p) => EvolutionPhoto.fromJson(p as Map<String, dynamic>))
          .toList(),
      anamnesisSubmissions: (json['anamneses'] as List<dynamic>)
          .map((a) => AnamnesisSubmission.fromJson(a as Map<String, dynamic>))
          .toList(),
      coachPhysicalAssessment: CoachPhysicalAssessment.fromJson(
        json['avaliacaoFisicaProfessor'] as Map<String, dynamic>,
      ),
      agendaDays: (json['agendaComparativa'] as List<dynamic>)
          .map((a) => AgendaDayComparison.fromJson(a as Map<String, dynamic>))
          .toList(),
      notifications: (json['notificacoes'] as List<dynamic>)
          .map((n) => RecNotificationItem.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Período de análise do Gráfico de Radar de Volume Muscular na aba "You".
enum MuscleVolumePeriod {
  week('Esta semana', 'Semana'),
  month('Este mês', 'Mês');

  final String heading;
  final String shortLabel;
  const MuscleVolumePeriod(this.heading, this.shortLabel);
}

/// Métrica agregada de volume de treino (séries e kg) por grupamento/eixo do Gráfico de Radar.
class MuscleVolumeAxisMetric {
  final String axisId;
  final String label;
  final List<MuscleGroup> groups;
  final int totalSets;
  final int totalVolumeKg;
  final double normalizedVolume;

  const MuscleVolumeAxisMetric({
    required this.axisId,
    required this.label,
    required this.groups,
    required this.totalSets,
    required this.totalVolumeKg,
    required this.normalizedVolume,
  });

  MuscleGroup get primaryLogoGroup => groups.first;

  Map<String, dynamic> toJson() => {
    'axisId': axisId,
    'label': label,
    'groups': groups.map((g) => g.name).toList(),
    'totalSets': totalSets,
    'totalVolumeKg': totalVolumeKg,
    'normalizedVolume': double.parse(normalizedVolume.toStringAsFixed(3)),
  };

  factory MuscleVolumeAxisMetric.fromJson(Map<String, dynamic> json) =>
      MuscleVolumeAxisMetric(
        axisId: json['axisId'] as String,
        label: json['label'] as String,
        groups: (json['groups'] as List<dynamic>)
            .map((e) => MuscleGroup.fromKey(e as String))
            .toList(),
        totalSets: (json['totalSets'] as num).round(),
        totalVolumeKg: (json['totalVolumeKg'] as num).round(),
        normalizedVolume: (json['normalizedVolume'] as num).toDouble(),
      );
}

/// Entrada cronológica de histórico de recordes batidos em um exercício.
class ExerciseRecordHistoryEntry {
  final String dateLabel;
  final String recordType;
  final String valueLabel;
  final String detailLabel;

  const ExerciseRecordHistoryEntry({
    required this.dateLabel,
    required this.recordType,
    required this.valueLabel,
    required this.detailLabel,
  });
}

/// Consolidação dos 5 recordes pessoais de um exercício específico:
/// 1RM Estimado, Peso Máximo, Repetições Máximas, Volume da Sessão Máximo e Volume Máximo de uma Série.
class ExerciseCompleteRecordSummary {
  final String exerciseName;
  final String animationKey;
  final MuscleGroup primaryMuscle;

  final int estimatedOneRepMaxKg;
  final String oneRepMaxDateLabel;
  final String oneRepMaxSetLabel;
  final String oneRepMaxShortSetLabel;

  final int maxWeightKg;
  final int maxWeightReps;
  final String maxWeightDateLabel;
  final String maxWeightSetLabel;

  final int maxReps;
  final int maxRepsWeightKg;
  final String maxRepsDateLabel;
  final String maxRepsSetLabel;

  final int maxSessionVolumeKg;
  final int maxSessionSetsCount;
  final String maxSessionDateLabel;

  final int maxSingleSetVolumeKg;
  final String maxSingleSetDateLabel;
  final String maxSingleSetLabel;

  final List<ExerciseRecordHistoryEntry> historyEntries;

  const ExerciseCompleteRecordSummary({
    required this.exerciseName,
    required this.animationKey,
    required this.primaryMuscle,
    required this.estimatedOneRepMaxKg,
    required this.oneRepMaxDateLabel,
    required this.oneRepMaxSetLabel,
    required this.oneRepMaxShortSetLabel,
    required this.maxWeightKg,
    required this.maxWeightReps,
    required this.maxWeightDateLabel,
    required this.maxWeightSetLabel,
    required this.maxReps,
    required this.maxRepsWeightKg,
    required this.maxRepsDateLabel,
    required this.maxRepsSetLabel,
    required this.maxSessionVolumeKg,
    required this.maxSessionSetsCount,
    required this.maxSessionDateLabel,
    required this.maxSingleSetVolumeKg,
    required this.maxSingleSetDateLabel,
    required this.maxSingleSetLabel,
    this.historyEntries = const [],
  });
}
