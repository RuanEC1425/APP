/// Modelos de Treino, Séries, Exercícios, Subdivisões Anatômicas (~19 músculos) e Sessões Executadas.
/// Projetados com serialização JSON (`toJson`/`fromJson`) para sincronização
/// direta com o painel Web do professor (`app-web-consultoria`) e persistência local.
library;

/// Tipos de série suportados nativamente + suporte a tipo customizado cadastrado pelo treinador.
enum SetType {
  warmUp('Warm-up Set', 'W', 0.0),
  feeder('Feeder Set', 'F', 0.35),
  working('Working Set', 'WK', 0.85),
  top('Top Set', 'TOP', 1.0),
  backoff('Backoff Set', 'BO', 0.80),
  drop('Drop Set', 'DRP', 1.0),
  superSet('Super Set', 'SS', 0.95),
  cluster('Cluster Set', 'CL', 1.0),
  custom('Custom Set', 'C', 0.85);

  final String label;
  final String shortCode;
  /// Fator de esforço fisiológico (E) para o modelo Impulse-Response / SRA de fadiga muscular.
  final double effortMultiplier;
  const SetType(this.label, this.shortCode, this.effortMultiplier);

  static SetType fromKey(String key) {
    return SetType.values.firstWhere(
      (e) => e.name == key || e.label.toLowerCase() == key.toLowerCase(),
      orElse: () => SetType.custom,
    );
  }
}

/// 19 Subdivisões anatômicas musculares monitoradas em todo o app (Modelos, Exercícios,
/// Recuperação Científica SRA/Impulse-Response, Gráficos e Mapa Anatômico de Fibras).
enum MuscleGroup {
  // ======================= VISTA ANTERIOR (FRENTE) =======================
  peitoralSuperior(
    'Peitoral Superior',
    'Peito Sup.',
    'Peito',
    true,
    18.0, // τ = 18h (~54h p/ 95%)
    9.0,
    'Fibras claviculares oblíquas ascendentes convergindo ao úmero',
  ),
  peitoralMaior(
    'Peitoral Maior',
    'Peito Maior',
    'Peito',
    true,
    20.0, // τ = 20h (~60h p/ 95%)
    11.0,
    'Fibras esternocostais horizontais em leque convergente',
  ),
  deltoideAnterior(
    'Deltoide Anterior',
    'Delt. Ant.',
    'Ombros',
    true,
    15.0, // τ = 15h (~45h p/ 95%)
    9.0,
    'Fibras paralelas oblíquas anteriores da clavícula ao tubérculo deltoideo',
  ),
  deltoideLateral(
    'Deltoide Lateral',
    'Delt. Lat.',
    'Ombros',
    true,
    15.0, // τ = 15h (~45h p/ 95%)
    10.0,
    'Fibras multipenadas acromiais de alta densidade',
  ),
  biceps(
    'Bíceps Braquial',
    'Bíceps',
    'Braços',
    true,
    16.0, // τ = 16h (~48h p/ 95%)
    9.0,
    'Fibras fusiformes longitudinais (cabeça longa e curta)',
  ),
  antebraco(
    'Antebraço',
    'Antebraço',
    'Braços',
    true,
    12.0, // τ = 12h (~36h p/ 95%)
    10.0,
    'Fibras flexoras e braquiorradiais diagonais densas',
  ),
  retoAbdominal(
    'Reto Abdominal',
    'Abdômen',
    'Core',
    true,
    12.0, // τ = 12h (~36h p/ 95%)
    10.0,
    'Fibras verticais segmentadas por intersecções tendíneas',
  ),
  obliquos(
    'Oblíquos',
    'Oblíquos',
    'Core',
    true,
    12.0, // τ = 12h (~36h p/ 95%)
    9.0,
    'Fibras diagonais cruzadas da caixa torácica à crista ilíaca',
  ),
  quadriceps(
    'Quadríceps',
    'Quadríceps',
    'Pernas',
    true,
    24.0, // τ = 24h (~72h p/ 95%)
    12.0,
    'Fibras bipenadas (reto femoral) e oblíquas (vasto lateral/medial)',
  ),
  adutores(
    'Adutores da Coxa',
    'Adutores',
    'Pernas',
    true,
    18.0, // τ = 18h (~54h p/ 95%)
    9.0,
    'Fibras oblíquas mediais do púbis à linha áspera do fêmur',
  ),

  // ======================= VISTA POSTERIOR (COSTAS) =======================
  trapezio(
    'Trapézio',
    'Trapézio',
    'Costas',
    false,
    16.0, // τ = 16h (~48h p/ 95%)
    10.0,
    'Fibras descendentes superiores, transversas médias e ascendentes inferiores',
  ),
  deltoidePosterior(
    'Deltoide Posterior',
    'Delt. Post.',
    'Ombros',
    false,
    14.0, // τ = 14h (~42h p/ 95%)
    9.0,
    'Fibras oblíquas posteriores da espinha da escápula ao úmero',
  ),
  dorsal(
    'Dorsal (Latíssimo)',
    'Dorsal',
    'Costas',
    false,
    20.0, // τ = 20h (~60h p/ 95%)
    12.0,
    'Fibras largas em leque ascendente da fáscia toracolombar ao úmero',
  ),
  lombar(
    'Lombar (Eretores)',
    'Lombar',
    'Costas',
    false,
    22.0, // τ = 22h (~66h p/ 95%)
    9.0,
    'Fibras paravertebrais verticais estabilizadoras da coluna',
  ),
  triceps(
    'Tríceps Braquial',
    'Tríceps',
    'Braços',
    false,
    16.0, // τ = 16h (~48h p/ 95%)
    9.0,
    'Fibras em ferradura (cabeça longa, lateral e medial)',
  ),
  gluteoMaximo(
    'Glúteo Máximo',
    'Glúteo Máx.',
    'Glúteos',
    false,
    20.0, // τ = 20h (~60h p/ 95%)
    11.0,
    'Fibras paralelas grossas oblíquas descendentes sacro-femorais',
  ),
  gluteoMedio(
    'Glúteo Médio',
    'Glúteo Méd.',
    'Glúteos',
    false,
    16.0, // τ = 16h (~48h p/ 95%)
    9.0,
    'Fibras radiadas superiores da crista ilíaca ao trocânter maior',
  ),
  posteriores(
    'Posteriores de Coxa',
    'Posteriores',
    'Pernas',
    false,
    24.0, // τ = 24h (~72h p/ 95% - alto dano excêntrico)
    10.0,
    'Fibras longas fusiformes e semimembranosas (bíceps femoral/semitendíneo)',
  ),
  panturrilhas(
    'Panturrilhas',
    'Panturrilhas',
    'Pernas',
    false,
    12.0, // τ = 12h (~36h p/ 95%)
    10.0,
    'Fibras penadas de alta resistência (gastrocnêmio medial/lateral e sóleo)',
  );

  final String label;
  final String shortLabel;
  final String macroGroup;
  final bool isFrontBody;
  /// Constante de tempo de decaimento exponencial da fadiga (τ_m em horas).
  final double recoveryTauHours;
  /// Capacidade de dose de séries equivalentes por sessão (C_m) que leva a recuperação a 0%.
  final double capacitySets;
  /// Descrição anatômica da direção das fibras musculares exibida na inspeção.
  final String fiberDirectionDescription;

  const MuscleGroup(
    this.label,
    this.shortLabel,
    this.macroGroup,
    this.isFrontBody,
    this.recoveryTauHours,
    this.capacitySets,
    this.fiberDirectionDescription,
  );

  // Aliases estáticos para manter 100% de compatibilidade com referências legadas:
  static const MuscleGroup peito = MuscleGroup.peitoralMaior;
  static const MuscleGroup ombros = MuscleGroup.deltoideLateral;
  static const MuscleGroup abdomen = MuscleGroup.retoAbdominal;
  static const MuscleGroup costas = MuscleGroup.dorsal;
  static const MuscleGroup gluteos = MuscleGroup.gluteoMaximo;

  static List<MuscleGroup> get frontGroups =>
      MuscleGroup.values.where((m) => m.isFrontBody).toList();

  static List<MuscleGroup> get backGroups =>
      MuscleGroup.values.where((m) => !m.isFrontBody).toList();

  static MuscleGroup fromKey(String key) {
    final normalized = key.trim().toLowerCase();
    switch (normalized) {
      case 'peito':
        return MuscleGroup.peitoralMaior;
      case 'ombros':
      case 'ombro':
        return MuscleGroup.deltoideLateral;
      case 'abdomen':
      case 'abdômen':
        return MuscleGroup.retoAbdominal;
      case 'costas':
        return MuscleGroup.dorsal;
      case 'gluteos':
      case 'glúteos':
        return MuscleGroup.gluteoMaximo;
    }
    return MuscleGroup.values.firstWhere(
      (e) =>
          e.name.toLowerCase() == normalized ||
          e.label.toLowerCase() == normalized ||
          e.shortLabel.toLowerCase() == normalized,
      orElse: () => MuscleGroup.peitoralMaior,
    );
  }
}

/// Representa uma série individual dentro de um exercício.
class ExerciseSet {
  final String id;
  final int index;
  final SetType type;
  final String? customTypeLabel;
  final String targetReps; // ex: "8 a 10", "12", "6-8 + 6-8"
  double weightKg;
  int completedReps;
  bool completed;

  ExerciseSet({
    required this.id,
    required this.index,
    required this.type,
    this.customTypeLabel,
    required this.targetReps,
    required this.weightKg,
    required this.completedReps,
    this.completed = false,
  });

  String get displayTypeLabel =>
      type == SetType.custom && (customTypeLabel?.isNotEmpty ?? false)
      ? customTypeLabel!
      : type.label;

  double get setVolumeKg => completed ? (weightKg * completedReps) : 0.0;

  ExerciseSet copyWith({
    String? id,
    int? index,
    SetType? type,
    String? customTypeLabel,
    String? targetReps,
    double? weightKg,
    int? completedReps,
    bool? completed,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      index: index ?? this.index,
      type: type ?? this.type,
      customTypeLabel: customTypeLabel ?? this.customTypeLabel,
      targetReps: targetReps ?? this.targetReps,
      weightKg: weightKg ?? this.weightKg,
      completedReps: completedReps ?? this.completedReps,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'index': index,
    'type': type.name,
    if (customTypeLabel != null) 'customTypeLabel': customTypeLabel,
    'targetReps': targetReps,
    'weightKg': weightKg,
    'completedReps': completedReps,
    'completed': completed,
  };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    id: json['id'] as String,
    index: json['index'] as int,
    type: SetType.fromKey(json['type'] as String),
    customTypeLabel: json['customTypeLabel'] as String?,
    targetReps: json['targetReps'] as String,
    weightKg: (json['weightKg'] as num).toDouble(),
    completedReps: json['completedReps'] as int,
    completed: json['completed'] as bool? ?? false,
  );
}

/// Representa um exercício dentro da ficha de treino (ou banco de exercícios do treinador).
class WorkoutExercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final String targetRepsRange;
  final int restSeconds;
  final String advancedTechnique; // Técnica avançada prescrita pelo treinador
  final String coachNotes;
  final List<ExerciseSet> sets;
  final String animationKey;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.targetRepsRange,
    required this.restSeconds,
    required this.advancedTechnique,
    this.coachNotes = '',
    required this.sets,
    String? animationKey,
  }) : animationKey = animationKey ?? inferAnimationKey(name);

  static String inferAnimationKey(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('supino')) return 'bench_press';
    if (lower.contains('crucifixo') || lower.contains('crossover')) {
      return 'chest_fly';
    }
    if (lower.contains('agachamento') || lower.contains('leg press')) {
      return 'squat';
    }
    if (lower.contains('elevação pélvica') || lower.contains('glúteo')) {
      return 'hip_thrust';
    }
    if (lower.contains('stiff') || lower.contains('terra')) {
      return 'romanian_deadlift';
    }
    if (lower.contains('puxada') || lower.contains('remada')) {
      return 'lat_pulldown';
    }
    if (lower.contains('desenvolvimento') || lower.contains('elevação lateral')) {
      return 'shoulder_press';
    }
    if (lower.contains('rosca')) return 'bicep_curl';
    if (lower.contains('tríceps') || lower.contains('triceps')) {
      return 'tricep_pushdown';
    }
    if (lower.contains('panturrilha')) return 'calf_raise';
    if (lower.contains('abdominal') || lower.contains('prancha')) {
      return 'crunch';
    }
    return 'compound_lift';
  }

  int get completedSetsCount => sets.where((s) => s.completed).length;

  double get totalVolumeKg =>
      sets.fold(0.0, (sum, item) => sum + item.setVolumeKg);

  WorkoutExercise copyWith({
    String? id,
    String? name,
    MuscleGroup? primaryMuscle,
    List<MuscleGroup>? secondaryMuscles,
    String? targetRepsRange,
    int? restSeconds,
    String? advancedTechnique,
    String? coachNotes,
    List<ExerciseSet>? sets,
    String? animationKey,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      targetRepsRange: targetRepsRange ?? this.targetRepsRange,
      restSeconds: restSeconds ?? this.restSeconds,
      advancedTechnique: advancedTechnique ?? this.advancedTechnique,
      coachNotes: coachNotes ?? this.coachNotes,
      sets: sets ?? this.sets.map((s) => s.copyWith()).toList(),
      animationKey: animationKey ?? this.animationKey,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'primaryMuscle': primaryMuscle.name,
    'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
    'targetRepsRange': targetRepsRange,
    'restSeconds': restSeconds,
    'advancedTechnique': advancedTechnique,
    'coachNotes': coachNotes,
    'animationKey': animationKey,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      WorkoutExercise(
        id: json['id'] as String,
        name: json['name'] as String,
        primaryMuscle: MuscleGroup.fromKey(json['primaryMuscle'] as String),
        secondaryMuscles:
            (json['secondaryMuscles'] as List<dynamic>?)
                ?.map((e) => MuscleGroup.fromKey(e as String))
                .toList() ??
            const [],
        targetRepsRange: json['targetRepsRange'] as String,
        restSeconds: json['restSeconds'] as int,
        advancedTechnique: json['advancedTechnique'] as String,
        coachNotes: json['coachNotes'] as String? ?? '',
        animationKey: json['animationKey'] as String?,
        sets: (json['sets'] as List<dynamic>)
            .map((s) => ExerciseSet.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

/// Divisão da ficha de treino criada pelo treinador (ex: Treino A, B, C, D).
class WorkoutPlanDay {
  final String id;
  final String code; // 'A', 'B', 'C', 'D'
  final String title;
  final String subtitle;
  final int durationWeeks;
  final String startDate;
  final String status; // 'Ativo', 'Vencendo', 'Concluído'
  final List<WorkoutExercise> exercises;

  WorkoutPlanDay({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.durationWeeks,
    required this.startDate,
    this.status = 'Ativo',
    required this.exercises,
  });

  int get totalSets => exercises.fold(0, (s, e) => s + e.sets.length);
  int get completedSets =>
      exercises.fold(0, (s, e) => s + e.completedSetsCount);
  double get currentVolumeKg =>
      exercises.fold(0.0, (s, e) => s + e.totalVolumeKg);

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'subtitle': subtitle,
    'durationWeeks': durationWeeks,
    'startDate': startDate,
    'status': status,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutPlanDay.fromJson(Map<String, dynamic> json) => WorkoutPlanDay(
    id: json['id'] as String,
    code: json['code'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    durationWeeks: json['durationWeeks'] as int,
    startDate: json['startDate'] as String,
    status: json['status'] as String? ?? 'Ativo',
    exercises: (json['exercises'] as List<dynamic>)
        .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// Registro detalhado de um exercício executado dentro de uma sessão concluída.
class CompletedExerciseLog {
  final String exerciseName;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final List<ExerciseSet> sets;
  final String animationKey;

  CompletedExerciseLog({
    required this.exerciseName,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.sets,
    String? animationKey,
  }) : animationKey =
           animationKey ?? WorkoutExercise.inferAnimationKey(exerciseName);

  double get maxWeightKg {
    final completedSets = sets.where((s) => s.completed);
    final source = completedSets.isNotEmpty ? completedSets : sets;
    return source.fold(0.0, (m, s) => s.weightKg > m ? s.weightKg : m);
  }

  int get repsAtMaxWeight {
    final completedSets = sets.where((s) => s.completed);
    final source = completedSets.isNotEmpty ? completedSets : sets;
    ExerciseSet? best;
    for (final s in source) {
      if (best == null ||
          s.weightKg > best.weightKg ||
          (s.weightKg == best.weightKg && s.completedReps > best.completedReps)) {
        best = s;
      }
    }
    return best?.completedReps ?? 0;
  }

  int get completedSetsCount {
    final c = sets.where((s) => s.completed).length;
    return c > 0 ? c : sets.length;
  }

  double get totalVolumeKg {
    double vol = 0;
    for (final s in sets) {
      if (s.completed) {
        vol += s.weightKg * s.completedReps;
      }
    }
    if (vol == 0) {
      for (final s in sets) {
        vol += s.weightKg * s.completedReps;
      }
    }
    return vol;
  }

  Map<String, dynamic> toJson() => {
    'exerciseName': exerciseName,
    'primaryMuscle': primaryMuscle.name,
    'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
    'animationKey': animationKey,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory CompletedExerciseLog.fromJson(Map<String, dynamic> json) =>
      CompletedExerciseLog(
        exerciseName: json['exerciseName'] as String,
        primaryMuscle: MuscleGroup.fromKey(json['primaryMuscle'] as String),
        secondaryMuscles:
            (json['secondaryMuscles'] as List<dynamic>?)
                ?.map((e) => MuscleGroup.fromKey(e as String))
                .toList() ??
            const [],
        animationKey: json['animationKey'] as String?,
        sets: (json['sets'] as List<dynamic>)
            .map((s) => ExerciseSet.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

/// Sessão de treino concluída pelo aluno (exibida na Home e usada para derivar
/// Visão Geral da Semana, Recuperação Muscular SRA, Calendário Multi-mês, PRs e Exercícios Feitos).
class CompletedWorkoutSession {
  final String id;
  String workoutName;
  double totalWeightLiftedKg;
  int totalSets;
  int durationMinutes;
  final DateTime completedAt;
  final bool isFreeSession; // true quando criada por "Iniciar sessão de treino"
  final List<MuscleGroup> workedMuscles;
  final List<CompletedExerciseLog> exerciseLogs;
  bool isSaved;
  bool isShared;
  String notes;

  CompletedWorkoutSession({
    required this.id,
    required this.workoutName,
    required this.totalWeightLiftedKg,
    required this.totalSets,
    required this.durationMinutes,
    required this.completedAt,
    this.isFreeSession = false,
    this.workedMuscles = const [],
    this.exerciseLogs = const [],
    this.isSaved = false,
    this.isShared = false,
    this.notes = '',
  });

  int get integerWeightLiftedKg => totalWeightLiftedKg.round();

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}min';
    }
    return '${mins}min';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutName': workoutName,
    'totalWeightLiftedKg': totalWeightLiftedKg.round(),
    'totalSets': totalSets,
    'durationMinutes': durationMinutes,
    'completedAt': completedAt.toIso8601String(),
    'isFreeSession': isFreeSession,
    'workedMuscles': workedMuscles.map((m) => m.name).toList(),
    'exerciseLogs': exerciseLogs.map((e) => e.toJson()).toList(),
    'isSaved': isSaved,
    'isShared': isShared,
    'notes': notes,
  };

  factory CompletedWorkoutSession.fromJson(Map<String, dynamic> json) =>
      CompletedWorkoutSession(
        id: json['id'] as String,
        workoutName: json['workoutName'] as String,
        totalWeightLiftedKg: (json['totalWeightLiftedKg'] as num).toDouble(),
        totalSets: json['totalSets'] as int,
        durationMinutes: json['durationMinutes'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
        isFreeSession: json['isFreeSession'] as bool? ?? false,
        workedMuscles:
            (json['workedMuscles'] as List<dynamic>?)
                ?.map((e) => MuscleGroup.fromKey(e as String))
                .toList() ??
            const [],
        exerciseLogs:
            (json['exerciseLogs'] as List<dynamic>?)
                ?.map(
                  (e) =>
                      CompletedExerciseLog.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const [],
        isSaved: json['isSaved'] as bool? ?? false,
        isShared: json['isShared'] as bool? ?? false,
        notes: json['notes'] as String? ?? '',
      );
}
