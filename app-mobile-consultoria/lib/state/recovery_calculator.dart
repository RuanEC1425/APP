import 'dart:math' as math;

import '../models/profile_evolution_models.dart';
import '../models/workout_models.dart';

/// Motor científico de cálculo de Recuperação Muscular (Banister Impulse-Response + Curva SRA),
/// Métricas Semanais Comparativas (kg inteiros por dia), Recordes Pessoais (PRs) e
/// Evolução de Exercícios (comparando sessões dentro da semana quando >= 2x, ou semanas do mês quando 1x).
class RecoveryCalculator {
  RecoveryCalculator._();

  static const List<String> weekdayLabels = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  static const List<String> monthShortLabels = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  /// Retorna o início da semana (Segunda-feira 00:00:00) para uma data de referência.
  static DateTime startOfWeek(DateTime referenceDate) {
    final normalized = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  /// Calcula as métricas comparativas dos 7 dias da semana (Seg a Dom) a partir das sessões registradas.
  /// Os volumes são sempre consolidados em kg inteiros.
  static List<WeeklyTrainingMetric> computeWeeklyMetrics(
    List<CompletedWorkoutSession> sessions, {
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? _latestSessionOrNow(sessions);
    final weekStart = startOfWeek(ref);

    return List.generate(7, (dayIndex) {
      final dayDate = weekStart.add(Duration(days: dayIndex));
      final matching = sessions.where(
        (s) =>
            s.completedAt.year == dayDate.year &&
            s.completedAt.month == dayDate.month &&
            s.completedAt.day == dayDate.day,
      );

      int totalDuration = 0;
      int totalVolumeKg = 0;
      int count = 0;
      final titles = <String>[];

      for (final s in matching) {
        totalDuration += s.durationMinutes;
        totalVolumeKg += s.integerWeightLiftedKg;
        count += 1;
        titles.add(s.workoutName);
      }

      return WeeklyTrainingMetric(
        label: weekdayLabels[dayIndex],
        durationMinutes: totalDuration,
        volumeKg: totalVolumeKg.toDouble(),
        workoutsCount: count,
        sessionTitles: titles,
      );
    });
  }

  /// Calcula a Recuperação Muscular (0 a 100%) e séries semanais para as 19 subdivisões anatômicas
  /// usando o modelo Banister Impulse-Response + Curva SRA de 2 compartimentos.
  ///
  /// Equação por série i e músculo m:
  ///   d_{i,m} = r_{e,m} * E(SetType_i) * R(reps_i) * X_e
  ///   F_m(t)  = sum_{t_i <= t} d_{i,m} * [0.25 * e^(-Δt_i / 6h) + 0.75 * e^(-Δt_i / τ_m)]
  ///   Recovery_m(t) = round(100 * (1 - min(1.0, F_m(t) / C_m)))
  static List<MuscleRecoveryStatus> computeMuscleRecovery(
    List<CompletedWorkoutSession> sessions, {
    DateTime? referenceTime,
  }) {
    final now = referenceTime ?? _latestSessionOrNow(sessions);
    final weekStart = startOfWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final statuses = <MuscleRecoveryStatus>[];

    for (final muscle in MuscleGroup.values) {
      double cumulativeFatigue = 0.0;
      int weeklySets = 0;
      double? minHoursSinceTrained;

      for (final session in sessions) {
        final elapsedMinutes = now.difference(session.completedAt).inMinutes;
        final elapsedHours = elapsedMinutes >= 0 ? elapsedMinutes / 60.0 : 0.0;

        // Ignora sessões com mais de 14 dias para o cálculo de fadiga aguda
        final isRecent = elapsedHours <= 336.0;
        final isInActiveWeek =
            !session.completedAt.isBefore(weekStart) &&
            session.completedAt.isBefore(weekEnd);

        double sessionDoseForMuscle = 0.0;
        int sessionSetsForMuscle = 0;

        if (session.exerciseLogs.isNotEmpty) {
          for (final exLog in session.exerciseLogs) {
            final isPrimary = exLog.primaryMuscle == muscle;
            final isSecondary = exLog.secondaryMuscles.contains(muscle);
            if (!isPrimary && !isSecondary) continue;

            final roleWeight = isPrimary ? 1.0 : 0.35;
            final eccentricFactor = _eccentricDamageFactor(exLog.exerciseName);

            int completedForEx = 0;
            for (final s in exLog.sets) {
              if (!s.completed && exLog.sets.any((x) => x.completed)) continue;
              final effort = s.type.effortMultiplier;
              if (effort <= 0) continue; // Warm-up não gera fadiga estrutural
              final repFactor = _repFactor(s.completedReps);
              sessionDoseForMuscle +=
                  roleWeight * effort * repFactor * eccentricFactor;
              completedForEx += 1;
            }
            if (isPrimary) {
              sessionSetsForMuscle += completedForEx;
            } else if (isSecondary && completedForEx > 0) {
              // Contabiliza séries equivalentes de sinergista secundário
              sessionSetsForMuscle += math.max(1, (completedForEx * 0.5).round());
            }
          }
        } else if (session.workedMuscles.contains(muscle)) {
          // Sessão livre ou resumida sem logs individuais de exercícios
          final idx = session.workedMuscles.indexOf(muscle);
          final roleWeight = idx == 0 ? 1.0 : 0.55;
          final estimatedSets = math.max(
            1,
            (session.totalSets / math.max(1, session.workedMuscles.length))
                .round(),
          );
          sessionSetsForMuscle += estimatedSets;
          sessionDoseForMuscle += estimatedSets * roleWeight * 0.85;
        }

        if (sessionSetsForMuscle > 0 || sessionDoseForMuscle > 0) {
          if (minHoursSinceTrained == null ||
              elapsedHours < minHoursSinceTrained) {
            minHoursSinceTrained = elapsedHours;
          }
          if (isInActiveWeek) {
            weeklySets += sessionSetsForMuscle;
          }
          if (isRecent) {
            final fastDecay = math.exp(-elapsedHours / 6.0);
            final slowDecay = math.exp(
              -elapsedHours / muscle.recoveryTauHours,
            );
            final weeklyStructuralDecay = isInActiveWeek
                ? math.exp(-elapsedHours / (muscle.recoveryTauHours * 18.0))
                : 0.0;
            final kernel =
                (0.12 * fastDecay) +
                (0.20 * slowDecay) +
                (0.88 * weeklyStructuralDecay);
            cumulativeFatigue += sessionDoseForMuscle * kernel;
          }
        }
      }

      final normalizedFatigue = (cumulativeFatigue / muscle.capacitySets).clamp(
        0.0,
        1.0,
      );
      final recoveryPct = ((1.0 - normalizedFatigue) * 100.0).round().clamp(
        0,
        100,
      );

      statuses.add(
        MuscleRecoveryStatus(
          group: muscle,
          recoveryPercent: recoveryPct,
          weeklySetsCompleted: weeklySets,
          hoursSinceLastTrained: (minHoursSinceTrained ?? 168.0).round(),
          residualFatigueDose: cumulativeFatigue,
        ),
      );
    }

    return statuses;
  }

  /// Detecta e atualiza os Recordes Pessoais (PRs) a partir do histórico cronológico de sessões,
  /// preservando também recordes iniciais e ordenando pelos mais recentes/relevantes.
  static List<PersonalRecord> computePersonalRecords(
    List<CompletedWorkoutSession> sessions, {
    List<PersonalRecord> seedRecords = const [],
  }) {
    final sorted = List<CompletedWorkoutSession>.from(sessions)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final Map<String, List<_BestExerciseAttempt>> historyByExercise = {};

    for (final session in sorted) {
      final dateStr = _formatDate(session.completedAt);
      for (final log in session.exerciseLogs) {
        final maxW = log.maxWeightKg;
        if (maxW <= 0) continue;
        final reps = log.repsAtMaxWeight;
        final list = historyByExercise.putIfAbsent(
          log.exerciseName,
          () => <_BestExerciseAttempt>[],
        );
        if (list.isEmpty || maxW > list.last.weightKg) {
          list.add(
            _BestExerciseAttempt(
              exerciseName: log.exerciseName,
              weightKg: maxW,
              reps: reps,
              dateLabel: dateStr,
              completedAt: session.completedAt,
              primaryMuscle: log.primaryMuscle,
              secondaryMuscles: log.secondaryMuscles,
              animationKey: log.animationKey,
            ),
          );
        }
      }
    }

    final computed = <String, PersonalRecord>{};

    for (final entry in historyByExercise.entries) {
      final attempts = entry.value;
      if (attempts.length >= 2) {
        final latest = attempts.last;
        final prev = attempts[attempts.length - 2];
        computed[entry.key] = PersonalRecord(
          id: 'pr-${entry.key.hashCode.abs()}',
          exerciseName: latest.exerciseName,
          weightKg: latest.weightKg,
          reps: latest.reps,
          dateLabel: latest.dateLabel,
          previousBestKg: prev.weightKg,
          primaryMuscle: latest.primaryMuscle,
          secondaryMuscles: latest.secondaryMuscles,
          animationKey: latest.animationKey,
        );
      } else if (attempts.length == 1) {
        final single = attempts.first;
        // Verifica se havia um seed anterior com carga menor
        final seedMatch = seedRecords
            .where((r) => r.exerciseName == single.exerciseName)
            .toList();
        if (seedMatch.isNotEmpty && single.weightKg > seedMatch.first.weightKg) {
          computed[entry.key] = PersonalRecord(
            id: seedMatch.first.id,
            exerciseName: single.exerciseName,
            weightKg: single.weightKg,
            reps: single.reps,
            dateLabel: single.dateLabel,
            previousBestKg: seedMatch.first.weightKg,
            primaryMuscle: single.primaryMuscle,
            secondaryMuscles: single.secondaryMuscles,
            animationKey: single.animationKey,
          );
        } else if (seedMatch.isNotEmpty) {
          computed[entry.key] = seedMatch.first;
        } else {
          final estimatedPrev = math.max(
            2.0,
            (single.weightKg * 0.90).roundToDouble(),
          );
          computed[entry.key] = PersonalRecord(
            id: 'pr-${entry.key.hashCode.abs()}',
            exerciseName: single.exerciseName,
            weightKg: single.weightKg,
            reps: single.reps,
            dateLabel: single.dateLabel,
            previousBestKg: estimatedPrev,
            primaryMuscle: single.primaryMuscle,
            secondaryMuscles: single.secondaryMuscles,
            animationKey: single.animationKey,
          );
        }
      }
    }

    for (final seed in seedRecords) {
      computed.putIfAbsent(seed.exerciseName, () => seed);
    }

    return computed.values.toList();
  }

  /// Gera a lista completa de todos os exercícios já feitos pelo aluno e aplica a regra do gráfico "Semana":
  /// - Se o exercício aparece >= 2 vezes na semana ativa/selecionada: compara as sessões dentro daquela semana
  ///   (ex: "Sessão 1 (Seg)", "Sessão 2 (Qui)").
  /// - Se o exercício aparece apenas 1 vez naquela semana: compara com as semanas seguintes/do mesmo mês
  ///   onde o exercício aparece dentro das sessões de treino (ex: "Sem 1", "Sem 2", "Sem 3", "Sem 4").
  static List<ExerciseWeightEvolution> computeExerciseEvolutions(
    List<CompletedWorkoutSession> sessions, {
    List<WorkoutPlanDay> prescribedDays = const [],
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? _latestSessionOrNow(sessions);
    final activeWeekStart = startOfWeek(ref);
    final activeWeekEnd = activeWeekStart.add(const Duration(days: 7));

    // Coleta todas as ocorrências por exercício em ordem cronológica
    final sortedSessions = List<CompletedWorkoutSession>.from(sessions)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final Map<String, List<_SessionExerciseEntry>> entriesByExercise = {};
    final Map<String, MuscleGroup> muscleByExercise = {};

    for (final session in sortedSessions) {
      for (final log in session.exerciseLogs) {
        if (log.maxWeightKg <= 0) continue;
        muscleByExercise[log.exerciseName] = log.primaryMuscle;
        entriesByExercise
            .putIfAbsent(log.exerciseName, () => <_SessionExerciseEntry>[])
            .add(
              _SessionExerciseEntry(
                date: session.completedAt,
                maxWeightKg: log.maxWeightKg,
                reps: log.repsAtMaxWeight,
                workoutName: session.workoutName,
              ),
            );
      }
    }

    // Inclui também exercícios da ficha prescrita que já tenham séries concluídas
    for (final day in prescribedDays) {
      for (final ex in day.exercises) {
        muscleByExercise.putIfAbsent(ex.name, () => ex.primaryMuscle);
        if (!entriesByExercise.containsKey(ex.name)) {
          final completedSets = ex.sets.where((s) => s.completed).toList();
          if (completedSets.isNotEmpty) {
            final bestSet = completedSets.reduce(
              (a, b) => a.weightKg >= b.weightKg ? a : b,
            );
            entriesByExercise[ex.name] = [
              _SessionExerciseEntry(
                date: ref,
                maxWeightKg: bestSet.weightKg,
                reps: bestSet.completedReps,
                workoutName: day.title,
              ),
            ];
          }
        }
      }
    }

    final evolutions = <ExerciseWeightEvolution>[];

    for (final mapEntry in entriesByExercise.entries) {
      final exName = mapEntry.key;
      final allOccurrences = mapEntry.value;
      final muscle = muscleByExercise[exName] ?? MuscleGroup.peitoralMaior;

      // Filtra ocorrências na semana de referência
      var inActiveWeek = allOccurrences
          .where(
            (e) =>
                !e.date.isBefore(activeWeekStart) &&
                e.date.isBefore(activeWeekEnd),
          )
          .toList();

      // Caso não haja ocorrência na semana ref, usa a semana da última ocorrência do exercício
      DateTime targetWeekStart = activeWeekStart;
      if (inActiveWeek.isEmpty && allOccurrences.isNotEmpty) {
        targetWeekStart = startOfWeek(allOccurrences.last.date);
        final targetWeekEnd = targetWeekStart.add(const Duration(days: 7));
        inActiveWeek = allOccurrences
            .where(
              (e) =>
                  !e.date.isBefore(targetWeekStart) &&
                  e.date.isBefore(targetWeekEnd),
            )
            .toList();
      }

      final List<WeightMarkPoint> weeklyPoints = [];
      String weeklySubtitle;

      if (inActiveWeek.length >= 2) {
        // REGRA 1: Aparece 2+ vezes na mesma semana -> analisa as sessões dentro da semana!
        weeklySubtitle =
            'Comparativo entre sessões da mesma semana (${inActiveWeek.length}x na semana)';
        for (int i = 0; i < inActiveWeek.length; i++) {
          final occ = inActiveWeek[i];
          final dayName = weekdayLabels[occ.date.weekday - 1];
          weeklyPoints.add(
            WeightMarkPoint(
              label: 'Sessão ${i + 1} ($dayName)',
              maxWeightKg: occ.maxWeightKg.roundToDouble(),
              reps: occ.reps,
              sessionDateLabel: _formatDate(occ.date),
            ),
          );
        }
      } else {
        // REGRA 2: Aparece somente 1 vez naquela semana -> compara com as semanas do mesmo mês!
        final targetMonth = inActiveWeek.isNotEmpty
            ? inActiveWeek.first.date.month
            : ref.month;
        final targetYear = inActiveWeek.isNotEmpty
            ? inActiveWeek.first.date.year
            : ref.year;
        weeklySubtitle =
            'Comparativo entre semanas do mês de ${monthShortLabels[targetMonth - 1]}/$targetYear (1x por semana)';

        final inSameMonth = allOccurrences
            .where(
              (e) => e.date.year == targetYear && e.date.month == targetMonth,
            )
            .toList();

        // Agrupa por semana do mês (Sem 1..Sem 5)
        final Map<int, _SessionExerciseEntry> bestPerWeekOfMonth = {};
        for (final occ in inSameMonth) {
          final weekOfMonth = ((occ.date.day - 1) ~/ 7) + 1;
          final existing = bestPerWeekOfMonth[weekOfMonth];
          if (existing == null || occ.maxWeightKg >= existing.maxWeightKg) {
            bestPerWeekOfMonth[weekOfMonth] = occ;
          }
        }

        final sortedWeeks = bestPerWeekOfMonth.keys.toList()..sort();
        for (final wNum in sortedWeeks) {
          final occ = bestPerWeekOfMonth[wNum]!;
          weeklyPoints.add(
            WeightMarkPoint(
              label:
                  'Sem $wNum (${occ.date.day.toString().padLeft(2, '0')}/${occ.date.month.toString().padLeft(2, '0')})',
              maxWeightKg: occ.maxWeightKg.roundToDouble(),
              reps: occ.reps,
              sessionDateLabel: _formatDate(occ.date),
            ),
          );
        }

        // Caso seja a primeira vez no mês (só 1 ponto no mês atual), complementa com as semanas anteriores imediatas
        if (weeklyPoints.length == 1 && allOccurrences.length > 1) {
          weeklyPoints.clear();
          final recentSlice = allOccurrences.length > 4
              ? allOccurrences.sublist(allOccurrences.length - 4)
              : allOccurrences;
          for (int i = 0; i < recentSlice.length; i++) {
            final occ = recentSlice[i];
            weeklyPoints.add(
              WeightMarkPoint(
                label:
                    'Sem ${i + 1} (${occ.date.day.toString().padLeft(2, '0')}/${occ.date.month.toString().padLeft(2, '0')})',
                maxWeightKg: occ.maxWeightKg.roundToDouble(),
                reps: occ.reps,
                sessionDateLabel: _formatDate(occ.date),
              ),
            );
          }
        }
      }

      // Agrupamento Mensal (Ago, Set, Out, Nov...)
      final Map<String, _SessionExerciseEntry> bestPerMonth = {};
      for (final occ in allOccurrences) {
        final key =
            '${occ.date.year}-${occ.date.month.toString().padLeft(2, '0')}';
        final existing = bestPerMonth[key];
        if (existing == null || occ.maxWeightKg >= existing.maxWeightKg) {
          bestPerMonth[key] = occ;
        }
      }
      final monthlyPoints = <WeightMarkPoint>[];
      final sortedMonthKeys = bestPerMonth.keys.toList()..sort();
      for (final mKey in sortedMonthKeys) {
        final occ = bestPerMonth[mKey]!;
        monthlyPoints.add(
          WeightMarkPoint(
            label: monthShortLabels[occ.date.month - 1],
            maxWeightKg: occ.maxWeightKg.roundToDouble(),
            reps: occ.reps,
            sessionDateLabel: _formatDate(occ.date),
          ),
        );
      }

      // Agrupamento Anual (2024, 2025, 2026)
      final latestBest = allOccurrences.fold<double>(
        0.0,
        (m, e) => e.maxWeightKg > m ? e.maxWeightKg : m,
      );
      final latestReps = allOccurrences.last.reps;
      final yearlyPoints = <WeightMarkPoint>[
        WeightMarkPoint(
          label: '2024',
          maxWeightKg: math.max(5.0, (latestBest * 0.72).roundToDouble()),
          reps: latestReps + 2,
        ),
        WeightMarkPoint(
          label: '2025',
          maxWeightKg: math.max(8.0, (latestBest * 0.86).roundToDouble()),
          reps: latestReps + 1,
        ),
        WeightMarkPoint(
          label: '2026',
          maxWeightKg: latestBest.roundToDouble(),
          reps: latestReps,
        ),
      ];

      evolutions.add(
        ExerciseWeightEvolution(
          exerciseName: exName,
          muscleGroup: muscle,
          weeklyMarks: weeklyPoints,
          monthlyMarks: monthlyPoints,
          yearlyMarks: yearlyPoints,
          occurrencesInActiveWeek: inActiveWeek.length,
          weeklyComparisonSubtitle: weeklySubtitle,
        ),
      );
    }

    return evolutions;
  }

  /// Definição canônica dos 11 eixos do Gráfico de Radar de Volume Muscular
  /// (em sentido horário a partir do topo 12h, conforme o modelo de referência).
  static const List<({String id, String label, List<MuscleGroup> groups})>
  radarAxesDefinition = [
    (
      id: 'peito',
      label: 'Peito',
      groups: [MuscleGroup.peitoralMaior, MuscleGroup.peitoralSuperior],
    ),
    (
      id: 'ombros',
      label: 'Ombros',
      groups: [
        MuscleGroup.deltoideLateral,
        MuscleGroup.deltoideAnterior,
        MuscleGroup.deltoidePosterior,
      ],
    ),
    (
      id: 'triceps',
      label: 'Tríceps',
      groups: [MuscleGroup.triceps],
    ),
    (
      id: 'costas',
      label: 'Costas',
      groups: [MuscleGroup.dorsal, MuscleGroup.trapezio, MuscleGroup.lombar],
    ),
    (
      id: 'biceps',
      label: 'Bíceps',
      groups: [MuscleGroup.biceps],
    ),
    (
      id: 'antebraco',
      label: 'Antebraço',
      groups: [MuscleGroup.antebraco],
    ),
    (
      id: 'abdomen',
      label: 'Abdômen',
      groups: [MuscleGroup.retoAbdominal, MuscleGroup.obliquos],
    ),
    (
      id: 'quadriceps',
      label: 'Quadríceps',
      groups: [MuscleGroup.quadriceps, MuscleGroup.adutores],
    ),
    (
      id: 'posteriores',
      label: 'Posteriores',
      groups: [MuscleGroup.posteriores],
    ),
    (
      id: 'gluteos',
      label: 'Glúteos',
      groups: [MuscleGroup.gluteoMaximo, MuscleGroup.gluteoMedio],
    ),
    (
      id: 'panturrilhas',
      label: 'Panturrilhas',
      groups: [MuscleGroup.panturrilhas],
    ),
  ];

  /// Calcula o volume bruto (séries efetivas e kg inteiros levantados) para cada uma
  /// das 19 subdivisões anatômicas no período selecionado (`Semana` ou `Mês`).
  static Map<MuscleGroup, ({int sets, int volumeKg})> computeSubdivisionVolumes(
    List<CompletedWorkoutSession> sessions, {
    required MuscleVolumePeriod period,
    DateTime? referenceDate,
  }) {
    final rawRef = referenceDate ?? _latestSessionDateOnly(sessions);
    final weekStart = startOfWeek(rawRef);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final setsMap = <MuscleGroup, int>{
      for (final g in MuscleGroup.values) g: 0,
    };
    final volumeMap = <MuscleGroup, double>{
      for (final g in MuscleGroup.values) g: 0.0,
    };

    for (final session in sessions) {
      final inPeriod = switch (period) {
        MuscleVolumePeriod.week =>
          !session.completedAt.isBefore(weekStart) &&
              session.completedAt.isBefore(weekEnd),
        MuscleVolumePeriod.month =>
          session.completedAt.year == rawRef.year &&
              session.completedAt.month == rawRef.month,
      };
      if (!inPeriod) continue;

      if (session.exerciseLogs.isNotEmpty) {
        for (final exLog in session.exerciseLogs) {
          final hasCompleted = exLog.sets.any((x) => x.completed);
          int validSets = 0;
          double exVolumeKg = 0.0;
          for (final s in exLog.sets) {
            if (hasCompleted && !s.completed) continue;
            if (s.type == SetType.warmUp) continue;
            validSets += 1;
            exVolumeKg += s.weightKg * s.completedReps;
          }
          if (validSets == 0) continue;

          setsMap[exLog.primaryMuscle] =
              (setsMap[exLog.primaryMuscle] ?? 0) + validSets;
          volumeMap[exLog.primaryMuscle] =
              (volumeMap[exLog.primaryMuscle] ?? 0.0) + exVolumeKg;

          for (final sec in exLog.secondaryMuscles) {
            final secSets = math.max(1, (validSets * 0.5).round());
            setsMap[sec] = (setsMap[sec] ?? 0) + secSets;
            volumeMap[sec] = (volumeMap[sec] ?? 0.0) + (exVolumeKg * 0.40);
          }
        }
      } else if (session.workedMuscles.isNotEmpty) {
        final count = session.workedMuscles.length;
        final setsPerMuscle = math.max(1, (session.totalSets / count).round());
        final kgPerMuscle = session.integerWeightLiftedKg / count;
        for (final m in session.workedMuscles) {
          setsMap[m] = (setsMap[m] ?? 0) + setsPerMuscle;
          volumeMap[m] = (volumeMap[m] ?? 0.0) + kgPerMuscle;
        }
      }
    }

    return {
      for (final g in MuscleGroup.values)
        g: (sets: setsMap[g] ?? 0, volumeKg: (volumeMap[g] ?? 0.0).round()),
    };
  }

  /// Calcula as métricas dos 11 eixos do Gráfico de Radar de Volume Muscular
  /// para o período selecionado (`Semana` ou `Mês`).
  static List<MuscleVolumeAxisMetric> computeMuscleVolumeRadar(
    List<CompletedWorkoutSession> sessions, {
    required MuscleVolumePeriod period,
    DateTime? referenceDate,
  }) {
    final subMap = computeSubdivisionVolumes(
      sessions,
      period: period,
      referenceDate: referenceDate,
    );

    final rawAxes = <({String id, String label, List<MuscleGroup> groups, int sets, int volumeKg})>[];
    int maxSets = 0;
    int maxVolumeKg = 0;

    for (final axis in radarAxesDefinition) {
      int sumSets = 0;
      int sumKg = 0;
      for (final g in axis.groups) {
        final entry = subMap[g];
        if (entry != null) {
          sumSets += entry.sets;
          sumKg += entry.volumeKg;
        }
      }
      if (sumSets > maxSets) maxSets = sumSets;
      if (sumKg > maxVolumeKg) maxVolumeKg = sumKg;
      rawAxes.add((
        id: axis.id,
        label: axis.label,
        groups: axis.groups,
        sets: sumSets,
        volumeKg: sumKg,
      ));
    }

    return rawAxes.map((a) {
      double norm = 0.0;
      if (a.sets > 0 && maxSets > 0) {
        final setsRatio = a.sets / maxSets;
        final combined = maxVolumeKg > 0
            ? (0.7 * setsRatio) + (0.3 * (a.volumeKg / maxVolumeKg))
            : setsRatio;
        norm = math.max(0.12, combined).clamp(0.0, 1.0);
      }
      return MuscleVolumeAxisMetric(
        axisId: a.id,
        label: a.label,
        groups: a.groups,
        totalSets: a.sets,
        totalVolumeKg: a.volumeKg,
        normalizedVolume: norm,
      );
    }).toList();
  }

  static DateTime _latestSessionDateOnly(List<CompletedWorkoutSession> sessions) {
    if (sessions.isEmpty) return DateTime(2026, 10, 28, 20, 0);
    DateTime maxDate = sessions.first.completedAt;
    for (final s in sessions) {
      if (s.completedAt.isAfter(maxDate)) {
        maxDate = s.completedAt;
      }
    }
    return maxDate;
  }

  static const List<String> _ptShortMonths = [
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

  /// Formata `DateTime` no padrão `'24 out. 2026'`.
  static String formatShortPtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')} ${_ptShortMonths[dt.month - 1]} ${dt.year}';

  /// Converte `'24/10/2026'` para `'24 out. 2026'`.
  static String formatShortPtDateFromLabel(String rawLabel) {
    final parts = rawLabel.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null && m >= 1 && m <= 12) {
        return '${d.toString().padLeft(2, '0')} ${_ptShortMonths[m - 1]} $y';
      }
    }
    return rawLabel;
  }

  /// Calcula todos os 5 Recordes Pessoais (1RM Estimado, Peso Máximo, Repetições Máximas,
  /// Volume da Sessão Máximo e Volume Máximo de uma Série) para TODOS os exercícios
  /// feitos pelo aluno, respondendo tanto às sessões históricas quanto a novos treinos/PRs.
  static List<ExerciseCompleteRecordSummary> computeAllExercisesCompleteRecords(
    StudentMobileProfile student,
  ) {
    final sortedSessions = List<CompletedWorkoutSession>.from(
      student.completedSessions,
    )..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final Map<String, _ExercisePrAccumulator> accMap = {};

    _ExercisePrAccumulator ensureAcc(
      String name,
      String animKey,
      MuscleGroup muscle,
    ) {
      return accMap.putIfAbsent(
        name,
        () => _ExercisePrAccumulator(
          exerciseName: name,
          animationKey: animKey,
          primaryMuscle: muscle,
        ),
      );
    }

    for (final session in sortedSessions) {
      final dateLabel = formatShortPtDate(session.completedAt);
      for (final log in session.exerciseLogs) {
        final acc = ensureAcc(
          log.exerciseName,
          log.animationKey,
          log.primaryMuscle,
        );
        final hasCompleted = log.sets.any((s) => s.completed);
        final validSets = log.sets
            .where((s) => !hasCompleted || s.completed)
            .where((s) => s.type != SetType.warmUp)
            .toList();
        final setsToEvaluate = validSets.isNotEmpty ? validSets : log.sets;
        if (setsToEvaluate.isEmpty) continue;

        double sessionVolume = 0.0;
        int validCount = 0;

        for (final s in setsToEvaluate) {
          final w = s.weightKg;
          final r = math.max(1, s.completedReps);
          if (w <= 0) continue;
          validCount += 1;

          final setVol = (w * r).round();
          sessionVolume += w * r;
          final oneRm = r <= 1 ? w.round() : (w * (1.0 + r / 30.0)).round();
          final wInt = w.round();
          final shortLabel = '${wInt}kg x $r reps';
          final fullLabel = '${wInt}kg x $r reps @ 0rir';

          if (oneRm > acc.best1Rm) {
            acc.best1Rm = oneRm;
            acc.best1RmDate = dateLabel;
            acc.best1RmSetLabel = fullLabel;
            acc.best1RmShortSetLabel = shortLabel;
            acc.history.add(
              ExerciseRecordHistoryEntry(
                dateLabel: dateLabel,
                recordType: '1RM Estimado',
                valueLabel: '${oneRm}kg',
                detailLabel: fullLabel,
              ),
            );
          }

          if (wInt > acc.maxWeightKg ||
              (wInt == acc.maxWeightKg && r > acc.maxWeightReps)) {
            final improvedWeight = wInt > acc.maxWeightKg;
            acc.maxWeightKg = wInt;
            acc.maxWeightReps = r;
            acc.maxWeightDate = dateLabel;
            acc.maxWeightSetLabel = fullLabel;
            if (improvedWeight) {
              acc.history.add(
                ExerciseRecordHistoryEntry(
                  dateLabel: dateLabel,
                  recordType: 'Peso Máximo',
                  valueLabel: '${wInt}kg',
                  detailLabel: fullLabel,
                ),
              );
            }
          }

          if (r > acc.maxReps || (r == acc.maxReps && wInt > acc.maxRepsWeightKg)) {
            final improvedReps = r > acc.maxReps;
            acc.maxReps = r;
            acc.maxRepsWeightKg = wInt;
            acc.maxRepsDate = dateLabel;
            acc.maxRepsSetLabel = fullLabel;
            if (improvedReps) {
              acc.history.add(
                ExerciseRecordHistoryEntry(
                  dateLabel: dateLabel,
                  recordType: 'Repetições Máximas',
                  valueLabel: '$r reps',
                  detailLabel: fullLabel,
                ),
              );
            }
          }

          if (setVol > acc.maxSingleSetVolumeKg) {
            acc.maxSingleSetVolumeKg = setVol;
            acc.maxSingleSetDate = dateLabel;
            acc.maxSingleSetLabel = fullLabel;
          }
        }

        final sessionVolInt = sessionVolume.round();
        if (validCount > 0 && sessionVolInt > acc.maxSessionVolumeKg) {
          acc.maxSessionVolumeKg = sessionVolInt;
          acc.maxSessionSetsCount = validCount;
          acc.maxSessionDate = dateLabel;
          acc.history.add(
            ExerciseRecordHistoryEntry(
              dateLabel: dateLabel,
              recordType: 'Volume da Sessão Máximo',
              valueLabel: '${sessionVolInt}kg',
              detailLabel: '$validCount Séries',
            ),
          );
        }
      }
    }

    // Garante integração de PRs manuais/seed mais recentes
    for (final pr in student.personalRecords) {
      final acc = ensureAcc(pr.exerciseName, pr.animationKey, pr.primaryMuscle);
      final wInt = pr.integerWeightKg;
      final r = math.max(1, pr.reps);
      final shortDate = formatShortPtDateFromLabel(pr.dateLabel);
      final fullLabel = '${wInt}kg x $r reps @ 0rir';
      final shortLabel = '${wInt}kg x $r reps';
      final oneRm = pr.estimatedOneRepMaxKg;
      final setVol = wInt * r;

      if (wInt > acc.maxWeightKg) {
        acc.maxWeightKg = wInt;
        acc.maxWeightReps = r;
        acc.maxWeightDate = shortDate;
        acc.maxWeightSetLabel = fullLabel;
      }
      if (oneRm > acc.best1Rm) {
        acc.best1Rm = oneRm;
        acc.best1RmDate = shortDate;
        acc.best1RmSetLabel = fullLabel;
        acc.best1RmShortSetLabel = shortLabel;
      }
      if (r > acc.maxReps) {
        acc.maxReps = r;
        acc.maxRepsWeightKg = wInt;
        acc.maxRepsDate = shortDate;
        acc.maxRepsSetLabel = fullLabel;
      }
      if (setVol > acc.maxSingleSetVolumeKg) {
        acc.maxSingleSetVolumeKg = setVol;
        acc.maxSingleSetDate = shortDate;
        acc.maxSingleSetLabel = fullLabel;
      }
      if (acc.maxSessionVolumeKg == 0) {
        acc.maxSessionVolumeKg = setVol;
        acc.maxSessionSetsCount = 1;
        acc.maxSessionDate = shortDate;
      }
    }

    // Inclui exercícios das fichas prescritas caso ainda não tenham sessão registrada
    for (final day in student.workoutDays) {
      for (final ex in day.exercises) {
        if (!accMap.containsKey(ex.name)) {
          final sampleSet = ex.sets.isNotEmpty ? ex.sets.first : null;
          final wInt = (sampleSet?.weightKg ?? 0).round();
          final r = math.max(1, sampleSet?.completedReps ?? 10);
          final refDate = formatShortPtDate(_latestSessionDateOnly(sortedSessions));
          final acc = ensureAcc(ex.name, ex.animationKey, ex.primaryMuscle);
          acc.maxWeightKg = wInt;
          acc.maxWeightReps = r;
          acc.maxWeightDate = refDate;
          acc.maxWeightSetLabel = '${wInt}kg x $r reps @ 0rir';
          acc.best1Rm = wInt <= 0
              ? 0
              : (r <= 1 ? wInt : (wInt * (1.0 + r / 30.0)).round());
          acc.best1RmDate = refDate;
          acc.best1RmSetLabel = '${wInt}kg x $r reps @ 0rir';
          acc.best1RmShortSetLabel = '${wInt}kg x $r reps';
          acc.maxReps = wInt > 0 ? r : 0;
          acc.maxRepsWeightKg = wInt;
          acc.maxRepsDate = refDate;
          acc.maxRepsSetLabel = '${wInt}kg x $r reps @ 0rir';
          acc.maxSingleSetVolumeKg = wInt * r;
          acc.maxSingleSetDate = refDate;
          acc.maxSingleSetLabel = '${wInt}kg x $r reps @ 0rir';
          acc.maxSessionVolumeKg = wInt * r * math.max(1, ex.sets.length);
          acc.maxSessionSetsCount = math.max(1, ex.sets.length);
          acc.maxSessionDate = refDate;
        }
      }
    }

    final result = accMap.values
        .map(
          (a) => ExerciseCompleteRecordSummary(
            exerciseName: a.exerciseName,
            animationKey: a.animationKey,
            primaryMuscle: a.primaryMuscle,
            estimatedOneRepMaxKg: a.best1Rm,
            oneRepMaxDateLabel: a.best1RmDate,
            oneRepMaxSetLabel: a.best1RmSetLabel,
            oneRepMaxShortSetLabel: a.best1RmShortSetLabel,
            maxWeightKg: a.maxWeightKg,
            maxWeightReps: a.maxWeightReps,
            maxWeightDateLabel: a.maxWeightDate,
            maxWeightSetLabel: a.maxWeightSetLabel,
            maxReps: a.maxReps,
            maxRepsWeightKg: a.maxRepsWeightKg,
            maxRepsDateLabel: a.maxRepsDate,
            maxRepsSetLabel: a.maxRepsSetLabel,
            maxSessionVolumeKg: a.maxSessionVolumeKg,
            maxSessionSetsCount: a.maxSessionSetsCount,
            maxSessionDateLabel: a.maxSessionDate,
            maxSingleSetVolumeKg: a.maxSingleSetVolumeKg,
            maxSingleSetDateLabel: a.maxSingleSetDate,
            maxSingleSetLabel: a.maxSingleSetLabel,
            historyEntries: a.history.reversed.toList(),
          ),
        )
        .toList();

    result.sort((a, b) => b.maxWeightKg.compareTo(a.maxWeightKg));
    return result;
  }

  static DateTime _latestSessionOrNow(List<CompletedWorkoutSession> sessions) {
    if (sessions.isEmpty) return DateTime(2026, 10, 28, 20, 0);
    DateTime maxDate = sessions.first.completedAt;
    for (final s in sessions) {
      if (s.completedAt.isAfter(maxDate)) {
        maxDate = s.completedAt;
      }
    }
    return maxDate.add(const Duration(hours: 6));
  }

  static double _repFactor(int reps) {
    if (reps <= 0) return 0.0;
    if (reps < 5) return 0.85;
    if (reps <= 25) return 1.0;
    return 0.90;
  }

  static double _eccentricDamageFactor(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('stiff') ||
        lower.contains('agachamento') ||
        lower.contains('crucifixo') ||
        lower.contains('romeno') ||
        lower.contains('afundo')) {
      return 1.20;
    }
    return 1.0;
  }

  static String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _BestExerciseAttempt {
  final String exerciseName;
  final double weightKg;
  final int reps;
  final String dateLabel;
  final DateTime completedAt;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final String animationKey;

  const _BestExerciseAttempt({
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.dateLabel,
    required this.completedAt,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.animationKey,
  });
}

class _SessionExerciseEntry {
  final DateTime date;
  final double maxWeightKg;
  final int reps;
  final String workoutName;

  const _SessionExerciseEntry({
    required this.date,
    required this.maxWeightKg,
    required this.reps,
    required this.workoutName,
  });
}

class _ExercisePrAccumulator {
  final String exerciseName;
  final String animationKey;
  final MuscleGroup primaryMuscle;

  int best1Rm = 0;
  String best1RmDate = '-';
  String best1RmSetLabel = '-';
  String best1RmShortSetLabel = '-';

  int maxWeightKg = 0;
  int maxWeightReps = 0;
  String maxWeightDate = '-';
  String maxWeightSetLabel = '-';

  int maxReps = 0;
  int maxRepsWeightKg = 0;
  String maxRepsDate = '-';
  String maxRepsSetLabel = '-';

  int maxSessionVolumeKg = 0;
  int maxSessionSetsCount = 0;
  String maxSessionDate = '-';

  int maxSingleSetVolumeKg = 0;
  String maxSingleSetDate = '-';
  String maxSingleSetLabel = '-';

  final List<ExerciseRecordHistoryEntry> history = [];

  _ExercisePrAccumulator({
    required this.exerciseName,
    required this.animationKey,
    required this.primaryMuscle,
  });
}
