import 'package:flutter/material.dart';

import '../models/profile_evolution_models.dart';
import '../models/workout_models.dart';
import '../state/app_state.dart';
import '../state/recovery_calculator.dart';
import '../theme/rec_theme.dart';
import '../widgets/exercise_animation_widget.dart';
import '../widgets/muscle_body_3d_widget.dart';

class YouScreen extends StatefulWidget {
  final RecAppState appState;

  const YouScreen({super.key, required this.appState});

  @override
  State<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends State<YouScreen> {
  int _selectedExerciseIndex = 0;
  String _selectedPeriod = 'Semana'; // 'Semana' | 'Mês' | 'Ano'
  String _recoveryFilter = 'Todos'; // 'Todos' | 'Trabalhados' | 'Anterior' | 'Posterior'
  int? _selectedCalendarDay;

  @override
  Widget build(BuildContext context) {
    final student = widget.appState.activeStudent;
    final subTab = widget.appState.youSubTabIndex;

    const tabs = [
      (0, 'Visão Geral', Icons.insights_rounded),
      (1, 'Exercícios Feitos', Icons.show_chart_rounded),
      (2, 'Medidas', Icons.straighten_rounded),
      (3, 'Fotos & Check-in', Icons.camera_alt_outlined),
    ];

    return Column(
      children: [
        // Barra superior da aba You com perfil e sub-tabs
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: const BoxDecoration(
            color: RecTheme.cardBackground,
            border: Border(bottom: BorderSide(color: RecTheme.borderSubtle)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: RecTheme.primaryRed.withValues(alpha: 0.2),
                    child: Text(
                      student.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: RecTheme.primaryRed,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${student.name} · Espaço You',
                          style: const TextStyle(
                            color: RecTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Plano ${student.plan} · Objetivo: ${student.objective} · Peso: ${student.currentWeightKg} kg',
                          style: const TextStyle(
                            color: RecTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tabs.map((t) {
                    final selected = subTab == t.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        key: Key('you_subtab_${t.$1}'),
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => widget.appState.setYouSubTab(t.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? RecTheme.primaryRed
                                : RecTheme.surfaceInput,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? RecTheme.primaryRed
                                  : RecTheme.borderSubtle,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                t.$3,
                                size: 15,
                                color: selected
                                    ? Colors.white
                                    : RecTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t.$2,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : RecTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (subTab) {
            0 => _buildOverviewSubTab(context, student),
            1 => _buildExercisesEvolutionSubTab(student),
            2 => _buildMeasurementsSubTab(context, student),
            _ => _buildPhotosAndAnamnesisSubTab(context, student),
          },
        ),
      ],
    );
  }

  /// Sub-tab 0: Visão Geral
  /// - Duração, volume e treinos feitos ao longo da semana (com gráfico comparativo de peso total levantado em kg inteiros)
  /// - Ilustração 3D com fibras musculares trabalhadas na semana (~19 subdivisões)
  /// - Gráfico de recuperação muscular por grupamento (modelo científico SRA / Impulse-Response)
  /// - Calendário multi-mês interativo com os dias treinados
  /// - Recordes pessoais batidos (PRs) com animação vetorial biomecânica e modal
  Widget _buildOverviewSubTab(
    BuildContext context,
    StudentMobileProfile student,
  ) {
    final totalDuration = student.weeklyMetrics.fold(
      0,
      (s, m) => s + m.durationMinutes,
    );
    final totalVolumeKg = student.weeklyMetrics.fold(
      0,
      (s, m) => s + m.integerVolumeKg,
    );
    final totalWorkouts = student.weeklyMetrics.fold(
      0,
      (s, m) => s + m.workoutsCount,
    );
    final maxVolume = student.weeklyMetrics.fold(
      1,
      (maxV, m) => m.integerVolumeKg > maxV ? m.integerVolumeKg : maxV,
    );

    final filteredRecovery = student.muscleRecovery.where((rec) {
      return switch (_recoveryFilter) {
        'Trabalhados' => rec.weeklySetsCompleted > 0,
        'Anterior' => rec.group.isFrontBody,
        'Posterior' => !rec.group.isFrontBody,
        _ => true,
      };
    }).toList();

    final calYear = widget.appState.calendarYear;
    final calMonth = widget.appState.calendarMonth;
    final calendarDays = widget.appState.buildCalendarDaysForMonth(
      year: calYear,
      month: calMonth,
      student: student,
    );
    final selectedDaySessions = _selectedCalendarDay != null
        ? widget.appState.sessionsForDate(
            calYear,
            calMonth,
            _selectedCalendarDay!,
            student: student,
          )
        : const <CompletedWorkoutSession>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Duração, Volume e Treinos na Semana + Gráfico Comparativo (Peso Total Levantado em kg inteiros)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RecTheme.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RecTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Visão Geral da Semana · Comparativo',
                      style: TextStyle(
                        color: RecTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Peso levantado / sessão (kg)',
                    style: TextStyle(
                      color: RecTheme.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _statBox(
                      'DURAÇÃO SEMANAL',
                      '${totalDuration}min',
                      RecTheme.primaryRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox(
                      'VOLUME TOTAL',
                      '$totalVolumeKg kg',
                      RecTheme.emerald,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox(
                      'TREINOS FEITOS',
                      '$totalWorkouts sessões',
                      RecTheme.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 138,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: student.weeklyMetrics.map((m) {
                    final heightFactor = (m.integerVolumeKg / maxVolume).clamp(
                      0.08,
                      1.0,
                    );
                    final active = m.workoutsCount > 0 && m.integerVolumeKg > 0;
                    return Column(
                      key: Key('weekly_bar_${m.label}'),
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          active ? '${m.integerVolumeKg} kg' : '-',
                          style: TextStyle(
                            color: active
                                ? RecTheme.textPrimary
                                : RecTheme.textMuted,
                            fontSize: 9.5,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 26,
                          height: 82 * heightFactor,
                          decoration: BoxDecoration(
                            color: active
                                ? RecTheme.primaryRed
                                : RecTheme.surfaceInput,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m.label,
                          style: const TextStyle(
                            color: RecTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Ilustração Anatômica 3D com Fibras Musculares Trabalhadas na Semana
        MuscleBody3DWidget(muscleStatuses: student.muscleRecovery),
        const SizedBox(height: 14),

        // 2.5. Gráfico de Radar de Volume Muscular (Semana / Mês) conforme Modelo Referencial
        MuscleVolumeRadarChartWidget(sessions: student.completedSessions),
        const SizedBox(height: 14),

        // 3. Recuperação Muscular em Eixo Horizontal com Logos Anatômicos + Opção "Ver tudo"
        Builder(
          builder: (context) {
            final overallRecoveryPercent = student.muscleRecovery.isEmpty
                ? 100
                : (student.muscleRecovery.fold<int>(
                        0,
                        (sum, item) => sum + item.recoveryPercent,
                      ) /
                      student.muscleRecovery.length)
                    .round()
                    .clamp(0, 100);
            final ringColor = _recoveryPillColor(overallRecoveryPercent);

            return Container(
              key: const Key('muscle_recovery_card'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                color: RecTheme.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: RecTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recuperação muscular',
                              style: TextStyle(
                                color: RecTheme.textPrimary,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Veja quais músculos estão prontos para treinar',
                              style: TextStyle(
                                color: RecTheme.textSecondary,
                                fontSize: 12.5,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        key: const Key('overall_recovery_gauge'),
                        width: 58,
                        height: 58,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 54,
                              height: 54,
                              child: CircularProgressIndicator(
                                value: (overallRecoveryPercent / 100.0).clamp(
                                  0.0,
                                  1.0,
                                ),
                                strokeWidth: 4.5,
                                strokeCap: StrokeCap.round,
                                backgroundColor: RecTheme.surfaceInput,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ringColor,
                                ),
                              ),
                            ),
                            Text(
                              '$overallRecoveryPercent%',
                              style: const TextStyle(
                                color: RecTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ['Todos', 'Trabalhados', 'Anterior', 'Posterior'].map(
                            (filter) {
                              final selected = _recoveryFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  key: Key('recovery_filter_$filter'),
                                  label: Text(
                                    filter,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  selected: selected,
                                  selectedColor: RecTheme.primaryRed,
                                  onSelected: (_) =>
                                      setState(() => _recoveryFilter = filter),
                                ),
                              );
                            },
                          ).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // 1 & 2. Eixo horizontal com os grupamentos + ícones (logos anatômicos) e pílulas de %
                  if (filteredRecovery.isEmpty)
                    Container(
                      key: const Key('recovery_horizontal_empty_state'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: RecTheme.surfaceInput,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: RecTheme.borderSubtle),
                      ),
                      child: const Text(
                        'Nenhum grupamento muscular encontrado para este filtro na semana.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: RecTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      key: const Key('recovery_horizontal_scroll'),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: filteredRecovery.map((rec) {
                          final pillColor = _recoveryPillColor(
                            rec.recoveryPercent,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              key: Key(
                                'recovery_horizontal_item_${rec.group.name}',
                              ),
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _openMuscleRecoveryFullFeature(
                                context,
                                student,
                                initialSelectedGroup: rec.group,
                              ),
                              child: SizedBox(
                                width: 72,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MuscleGroupLogoWidget(
                                      key: Key(
                                        'recovery_logo_${rec.group.name}',
                                      ),
                                      group: rec.group,
                                      width: 66,
                                      height: 78,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pillColor,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '${rec.recoveryPercent}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      rec.group.shortLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: RecTheme.textSecondary,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 10),
                  // 3. Opção "Ver tudo" abrindo uma nova feature na tela
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: const Key('recovery_see_all_button'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                      onPressed: () =>
                          _openMuscleRecoveryFullFeature(context, student),
                      child: const Text(
                        'Ver tudo',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        // 4. Calendário Multi-mês Interativo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RecTheme.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RecTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Calendário · Dias Treinados no Mês (${widget.appState.calendarMonthYearLabel})',
                      style: const TextStyle(
                        color: RecTheme.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: const Key('calendar_prev_month_button'),
                        tooltip: 'Mês Anterior',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: RecTheme.textPrimary,
                        ),
                        onPressed: () {
                          setState(() => _selectedCalendarDay = null);
                          widget.appState.navigateCalendarMonth(-1);
                        },
                      ),
                      IconButton(
                        key: const Key('calendar_next_month_button'),
                        tooltip: 'Próximo Mês',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: RecTheme.textPrimary,
                        ),
                        onPressed: () {
                          setState(() => _selectedCalendarDay = null);
                          widget.appState.navigateCalendarMonth(1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${calendarDays.where((d) => d.trained).length} dias com treino registrado em ${widget.appState.calendarMonthYearLabel} · Toque em um dia para ver a sessão',
                style: const TextStyle(color: RecTheme.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: calendarDays.map((d) {
                  final isSelectedDay = _selectedCalendarDay == d.dayOfMonth;
                  return GestureDetector(
                    key: Key(
                      'calendar_day_${calYear}_${calMonth}_${d.dayOfMonth}',
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCalendarDay = isSelectedDay
                            ? null
                            : d.dayOfMonth;
                      });
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelectedDay
                            ? RecTheme.primaryRed
                            : (d.trained
                                  ? RecTheme.primaryRed.withValues(alpha: 0.22)
                                  : RecTheme.surfaceInput),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelectedDay
                              ? Colors.white
                              : (d.trained
                                    ? RecTheme.primaryRed
                                    : RecTheme.borderSubtle),
                        ),
                      ),
                      child: Text(
                        '${d.dayOfMonth}',
                        style: TextStyle(
                          color: (d.trained || isSelectedDay)
                              ? RecTheme.textPrimary
                              : RecTheme.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_selectedCalendarDay != null) ...[
                const SizedBox(height: 12),
                Container(
                  key: const Key('calendar_day_sessions_panel'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RecTheme.surfaceInput,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: RecTheme.borderSubtle),
                  ),
                  child: selectedDaySessions.isEmpty
                      ? Text(
                          'Dia ${_selectedCalendarDay.toString().padLeft(2, '0')}/${calMonth.toString().padLeft(2, '0')}/$calYear · Descanso (nenhuma sessão registrada).',
                          style: const TextStyle(
                            color: RecTheme.textSecondary,
                            fontSize: 12,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: selectedDaySessions.map((sess) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${sess.workoutName} (${sess.totalSets} séries · ${sess.durationMinutes}min)',
                                      style: const TextStyle(
                                        color: RecTheme.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${sess.integerWeightLiftedKg} kg',
                                    style: const TextStyle(
                                      color: RecTheme.emerald,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 5. Recordes Pessoais (GIF + Data + Peso + Repetições -> Lista de Exercícios -> 5 Recordes)
        Container(
          key: const Key('personal_records_overview_card'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RecTheme.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RecTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Recordes Pessoais',
                      style: TextStyle(
                        color: RecTheme.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    key: const Key('register_new_pr_button'),
                    onPressed: () => _showRegisterPrDialog(context),
                    icon: const Icon(Icons.add_circle_outline, size: 15),
                    label: const Text(
                      'Novo PR',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Veja seus melhores levantamentos e a evolução ao longo do tempo',
                style: TextStyle(color: RecTheme.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              ...student.personalRecords.map(
                (pr) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    key: Key('pr_item_${pr.exerciseName}'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openPersonalRecordsAllExercises(
                      context,
                      student,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: RecTheme.surfaceInput,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: RecTheme.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          ExerciseAnimationWidget(
                            animationKey: pr.animationKey,
                            exerciseName: pr.exerciseName,
                            width: 56,
                            height: 56,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pr.exerciseName,
                                  style: const TextStyle(
                                    color: RecTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pr.shortPtDateLabel,
                                  style: const TextStyle(
                                    color: RecTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${pr.integerWeightKg} kg',
                                style: const TextStyle(
                                  color: RecTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${pr.integerWeightKg}kg x ${pr.reps} reps',
                                style: const TextStyle(
                                  color: RecTheme.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sub-tab 1: Exercícios Feitos
  /// - Lista TODOS os exercícios que o aluno já fez
  /// - Em "Semana":
  ///   * Se o exercício aparece >= 2 vezes na mesma semana -> analisa as sessões dentro da semana
  ///   * Se o exercício aparece apenas 1 vez naquela semana -> compara com as semanas seguintes/do mesmo mês onde o exercício aparece
  Widget _buildExercisesEvolutionSubTab(StudentMobileProfile student) {
    final evolutions = student.exerciseEvolutions;
    if (evolutions.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum exercício registrado ainda.',
          style: TextStyle(color: RecTheme.textSecondary),
        ),
      );
    }
    if (_selectedExerciseIndex >= evolutions.length) {
      _selectedExerciseIndex = 0;
    }
    final currentEvo = evolutions[_selectedExerciseIndex];
    final points = switch (_selectedPeriod) {
      'Mês' => currentEvo.monthlyMarks,
      'Ano' => currentEvo.yearlyMarks,
      _ => currentEvo.weeklyMarks,
    };
    final maxW = points.fold(
      1,
      (m, p) => p.integerMaxWeightKg > m ? p.integerMaxWeightKg : m,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Evolução de Cargas por Exercício',
                style: TextStyle(
                  color: RecTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: RecTheme.surfaceInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RecTheme.borderSubtle),
              ),
              child: Text(
                '${evolutions.length} exercícios feitos',
                style: const TextStyle(
                  color: RecTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Seletor de TODOS os exercícios já feitos pelo aluno
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(evolutions.length, (i) {
            final evo = evolutions[i];
            final selected = _selectedExerciseIndex == i;
            return ChoiceChip(
              key: Key('exercise_chip_${evo.exerciseName}'),
              label: Text(
                evo.exerciseName,
                style: const TextStyle(fontSize: 11.5),
              ),
              selected: selected,
              selectedColor: RecTheme.primaryRed,
              onSelected: (_) => setState(() => _selectedExerciseIndex = i),
            );
          }),
        ),
        const SizedBox(height: 14),
        // Seletor de Período (Semana | Mês | Ano)
        Row(
          children: ['Semana', 'Mês', 'Ano'].map((period) {
            final active = _selectedPeriod == period;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                key: Key('period_filter_$period'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: active
                      ? RecTheme.primaryRed
                      : RecTheme.surfaceInput,
                  foregroundColor: active
                      ? Colors.white
                      : RecTheme.textSecondary,
                ),
                onPressed: () => setState(() => _selectedPeriod = period),
                child: Text(period),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        // Gráfico de Evolução das Marcas de Pesos Batidos
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RecTheme.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RecTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${currentEvo.exerciseName} · Evolução ($_selectedPeriod)',
                style: const TextStyle(
                  color: RecTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedPeriod == 'Semana'
                    ? currentEvo.weeklyComparisonSubtitle
                    : 'Grupamento principal: ${currentEvo.muscleGroup.label} (${currentEvo.muscleGroup.fiberDirectionDescription})',
                key: const Key('exercise_comparison_mode_subtitle'),
                style: const TextStyle(
                  color: RecTheme.primaryRedLight,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: points.map((pt) {
                    final ratio = (pt.integerMaxWeightKg / maxW).clamp(
                      0.15,
                      1.0,
                    );
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${pt.integerMaxWeightKg} kg',
                          style: const TextStyle(
                            color: RecTheme.primaryRedLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${pt.reps} reps',
                          style: const TextStyle(
                            color: RecTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 34,
                          height: 100 * ratio,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                RecTheme.primaryRedLight,
                                RecTheme.primaryRed,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pt.label,
                          style: const TextStyle(
                            color: RecTheme.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sub-tab 2: Medidas (registrar e acompanhar medidas dos grupamentos musculares).
  Widget _buildMeasurementsSubTab(
    BuildContext context,
    StudentMobileProfile student,
  ) {
    final entries = student.bodyMeasurements;
    final latest = entries.isNotEmpty ? entries.first : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Medidas dos Grupamentos Musculares',
                style: TextStyle(
                  color: RecTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton.icon(
              key: const Key('add_measurement_button'),
              onPressed: () => _showAddMeasurementDialog(context, latest),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Registrar Medidas'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (latest != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RecTheme.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RecTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Última Avaliação · ${latest.dateLabel} (${latest.weightKg} kg · ${latest.bodyFatPercent}% BF)',
                  style: const TextStyle(
                    color: RecTheme.primaryRedLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Divider(height: 18),
                ...latest.circumferencesCm.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: const TextStyle(
                            color: RecTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${e.value.toStringAsFixed(1)} cm',
                          style: const TextStyle(
                            color: RecTheme.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Sub-tab 3: Fotos de Evolução + Central de Anamneses (incluindo as informações da
  /// Anamnese/Avaliação Física realizada pelo professor: peso, altura, % gordura, % massa magra, IMC, dobras, etc.).
  Widget _buildPhotosAndAnamnesisSubTab(
    BuildContext context,
    StudentMobileProfile student,
  ) {
    final eval = student.coachPhysicalAssessment;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Seção 1: Fotos de Evolução
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RecTheme.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RecTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Fotos de Evolução (Frente, Costas, Perfil)',
                      style: TextStyle(
                        color: RecTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    key: const Key('add_evolution_photo_button'),
                    onPressed: () =>
                        _showAddPhotoDialog(context, student.currentWeightKg),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 15),
                    label: const Text('Nova Foto'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (student.evolutionPhotos.isEmpty)
                const Text(
                  'Nenhuma foto adicionada ainda.',
                  style: TextStyle(color: RecTheme.textSecondary, fontSize: 12),
                )
              else
                ...student.evolutionPhotos.map(
                  (photo) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: RecTheme.surfaceInput,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: RecTheme.primaryRed),
                      ),
                      child: const Icon(
                        Icons.photo_camera_back_rounded,
                        color: RecTheme.primaryRed,
                      ),
                    ),
                    title: Text(
                      'Pose: ${photo.pose} · ${photo.weightKg} kg',
                      style: const TextStyle(
                        color: RecTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${photo.dateLabel} · ${photo.notes}',
                      style: const TextStyle(
                        color: RecTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Seção 2: Central de Anamneses & Avaliação Física Realizada pelo Professor
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RecTheme.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: RecTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Central de Anamneses & Check-in',
                          style: TextStyle(
                            color: RecTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Anamnese clínica realizada pelo professor + formulários Corporal, Alimentar e Espacial',
                          style: TextStyle(
                            color: RecTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    key: const Key('open_anamnesis_wizard_button'),
                    onPressed: () => _showAnamnesisWizardDialog(context),
                    child: const Text('Novo Check-in'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Card de Avaliação Física e Anamnese realizada pelo Professor
              Container(
                key: const Key('coach_physical_assessment_card'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: RecTheme.surfaceInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: RecTheme.primaryRed.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Anamnese & Avaliação Física do Professor',
                            style: TextStyle(
                              color: RecTheme.primaryRedLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        Text(
                          eval.evaluatedAt,
                          style: const TextStyle(
                            color: RecTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${eval.coachName} · Protocolo: ${eval.protocolName}',
                      style: const TextStyle(
                        color: RecTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statBox(
                            'PESO ATUAL',
                            '${eval.weightKg.toStringAsFixed(1)} kg',
                            RecTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statBox(
                            'ALTURA',
                            '${eval.heightMeters.toStringAsFixed(2)} m (${eval.heightCm} cm)',
                            RecTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statBox(
                            'IMC',
                            '${eval.bmi.toStringAsFixed(1)} kg/m²',
                            RecTheme.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _statBox(
                            '% DE GORDURA',
                            '${eval.bodyFatPercent.toStringAsFixed(1)}% (${eval.fatMassKg.toStringAsFixed(1)} kg)',
                            RecTheme.primaryRedLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statBox(
                            '% MASSA MAGRA',
                            '${eval.leanMassPercent.toStringAsFixed(1)}% (${eval.leanMassKg.toStringAsFixed(1)} kg)',
                            RecTheme.emerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Parecer do Professor: ${eval.coachDiagnosticNotes}',
                      style: const TextStyle(
                        color: RecTheme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Avaliação Postural: ${eval.posturalAssessment}',
                      style: const TextStyle(
                        color: RecTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                'Histórico de Anamneses (Toque para inspecionar respostas e medidas completas)',
                style: TextStyle(
                  color: RecTheme.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ...student.anamnesisSubmissions.map((sub) {
                final badgeColor = sub.status == 'Analisado'
                    ? RecTheme.emerald
                    : (sub.status == 'Negado'
                          ? RecTheme.primaryRed
                          : RecTheme.amber);
                return ListTile(
                  key: Key('anamnesis_submission_tile_${sub.id}'),
                  onTap: () =>
                      _showAnamnesisDetailsModal(context, sub, eval),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    sub.type,
                    style: const TextStyle(
                      color: RecTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    'Enviado em ${sub.dateLabel} · Toque para ver avaliação completa',
                    style: const TextStyle(
                      color: RecTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sub.status,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  void _showAnamnesisDetailsModal(
    BuildContext context,
    AnamnesisSubmission sub,
    CoachPhysicalAssessment eval,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: RecTheme.cardBackground,
          title: Text(
            '${sub.type} · ${sub.studentName}',
            style: const TextStyle(
              color: RecTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dados da Avaliação Física do Professor (${eval.evaluatedAt}):',
                  style: const TextStyle(
                    color: RecTheme.primaryRedLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '• Peso: ${eval.weightKg.toStringAsFixed(1)} kg | Altura: ${eval.heightMeters.toStringAsFixed(2)} m | IMC: ${eval.bmi.toStringAsFixed(1)}\n'
                  '• Percentual de Gordura: ${eval.bodyFatPercent.toStringAsFixed(1)}% (${eval.fatMassKg.toStringAsFixed(1)} kg)\n'
                  '• Percentual de Massa Magra: ${eval.leanMassPercent.toStringAsFixed(1)}% (${eval.leanMassKg.toStringAsFixed(1)} kg)\n'
                  '• Taxa Metabólica Basal: ${eval.basalMetabolicRateKcal} kcal | Gordura Visceral: Nível ${eval.visceralFatLevel.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: RecTheme.textPrimary,
                    fontSize: 12,
                  ),
                ),
                const Divider(height: 18),
                const Text(
                  'Dobras Cutâneas (mm):',
                  style: TextStyle(
                    color: RecTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                ...eval.skinfoldsMm.entries.map(
                  (e) => Text(
                    '• ${e.key}: ${e.value.toStringAsFixed(1)} mm',
                    style: const TextStyle(
                      color: RecTheme.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                const Divider(height: 18),
                const Text(
                  'Respostas da Anamnese Corporal, Alimentar e Espacial:',
                  style: TextStyle(
                    color: RecTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                ...sub.corporalAnswers.entries.map(
                  (e) => Text(
                    '• ${e.key}: ${e.value}',
                    style: const TextStyle(
                      color: RecTheme.textPrimary,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                ...sub.alimentarAnswers.entries.map(
                  (e) => Text(
                    '• ${e.key}: ${e.value}',
                    style: const TextStyle(
                      color: RecTheme.textPrimary,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                ...sub.espacialAnswers.entries.map(
                  (e) => Text(
                    '• ${e.key}: ${e.value}',
                    style: const TextStyle(
                      color: RecTheme.textPrimary,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              key: const Key('close_anamnesis_details_modal_button'),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterPrDialog(BuildContext context) {
    final exCtrl = TextEditingController(text: 'Supino Reto com Barra');
    final weightCtrl = TextEditingController(text: '46');
    final repsCtrl = TextEditingController(text: '8');
    MuscleGroup selectedMuscle = MuscleGroup.peitoralMaior;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Registrar Novo Recorde Pessoal (PR)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      key: const Key('pr_dialog_exercise_input'),
                      controller: exCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Exercício',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MuscleGroup>(
                      initialValue: selectedMuscle,
                      dropdownColor: RecTheme.surfaceInput,
                      decoration: const InputDecoration(
                        labelText: 'Subdivisão Muscular Alvo',
                      ),
                      items: MuscleGroup.values
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedMuscle = v);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('pr_dialog_weight_input'),
                            controller: weightCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Nova Carga (kg)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            key: const Key('pr_dialog_reps_input'),
                            controller: repsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Repetições',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  key: const Key('save_pr_submit_button'),
                  onPressed: () {
                    widget.appState.recordExerciseExecutionOrPr(
                      exerciseName: exCtrl.text.trim().isEmpty
                          ? 'Supino Reto com Barra'
                          : exCtrl.text.trim(),
                      primaryMuscle: selectedMuscle,
                      weightKg: double.tryParse(weightCtrl.text) ?? 50,
                      reps: int.tryParse(repsCtrl.text) ?? 8,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Salvar PR'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statBox(String title, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RecTheme.surfaceInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RecTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: RecTheme.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMeasurementDialog(
    BuildContext context,
    BodyMeasurementEntry? latest,
  ) {
    final weightCtrl = TextEditingController(
      text: '${latest?.weightKg ?? 70.0}',
    );
    final bfCtrl = TextEditingController(
      text: '${latest?.bodyFatPercent ?? 18.0}',
    );
    final chestCtrl = TextEditingController(
      text: '${latest?.circumferencesCm['Peitoral'] ?? 96.0}',
    );
    final armCtrl = TextEditingController(
      text: '${latest?.circumferencesCm['Braço Direito'] ?? 35.0}',
    );
    final waistCtrl = TextEditingController(
      text: '${latest?.circumferencesCm['Cintura'] ?? 75.0}',
    );
    final thighCtrl = TextEditingController(
      text: '${latest?.circumferencesCm['Coxa Direita'] ?? 58.0}',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar Medidas Corporais'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso Atual (kg)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bfCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '% de Gordura'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: chestCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peitoral (cm)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: armCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Braço Contraído (cm)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: waistCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cintura (cm)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: thighCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Coxa (cm)'),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('save_measurement_submit'),
            onPressed: () {
              widget.appState.addBodyMeasurement(
                weightKg: double.tryParse(weightCtrl.text) ?? 70,
                bodyFatPercent: double.tryParse(bfCtrl.text) ?? 18,
                circumferencesCm: {
                  'Peitoral': double.tryParse(chestCtrl.text) ?? 96,
                  'Braço Direito': double.tryParse(armCtrl.text) ?? 35,
                  'Cintura': double.tryParse(waistCtrl.text) ?? 75,
                  'Coxa Direita': double.tryParse(thighCtrl.text) ?? 58,
                },
              );
              Navigator.pop(ctx);
            },
            child: const Text('Salvar Medidas'),
          ),
        ],
      ),
    );
  }

  void _showAddPhotoDialog(BuildContext context, double defaultWeight) {
    String selectedPose = 'Frente';
    final weightCtrl = TextEditingController(text: '$defaultWeight');
    final notesCtrl = TextEditingController(
      text: 'Registro de evolução mensal em jejum.',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Text('Adicionar Foto de Evolução'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedPose,
                    dropdownColor: RecTheme.surfaceInput,
                    decoration: const InputDecoration(
                      labelText: 'Pose da Foto',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Frente', child: Text('Frente')),
                      DropdownMenuItem(value: 'Costas', child: Text('Costas')),
                      DropdownMenuItem(value: 'Perfil', child: Text('Perfil')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => selectedPose = v);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso na data (kg)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(labelText: 'Observações'),
                  ),
                ],
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  key: const Key('save_photo_submit'),
                  onPressed: () {
                    widget.appState.addEvolutionPhoto(
                      pose: selectedPose,
                      weightKg:
                          double.tryParse(weightCtrl.text) ?? defaultWeight,
                      notes: notesCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Salvar Foto'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAnamnesisWizardDialog(BuildContext context) {
    int step = 0;
    final lesoesCtrl = TextEditingController(text: 'Nenhuma lesão articular.');
    final refeicoesCtrl = TextEditingController(
      text: '4 a 5 refeições bem distribuídas.',
    );
    final localCtrl = TextEditingController(
      text: 'Academia completa · 5x na semana.',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setWizardState) {
            return AlertDialog(
              title: Text('Wizard Anamnese · Etapa ${step + 1}/3'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (step == 0) ...[
                    const Text(
                      '1. Anamnese Corporal',
                      style: TextStyle(
                        color: RecTheme.primaryRedLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lesoesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Possui lesões ou dores articulares?',
                      ),
                    ),
                  ] else if (step == 1) ...[
                    const Text(
                      '2. Anamnese Alimentar',
                      style: TextStyle(
                        color: RecTheme.primaryRedLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: refeicoesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Rotina de refeições e suplementos',
                      ),
                    ),
                  ] else ...[
                    const Text(
                      '3. Anamnese Espacial',
                      style: TextStyle(
                        color: RecTheme.primaryRedLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: localCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Local de treino e disponibilidade',
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                if (step > 0)
                  OutlinedButton(
                    onPressed: () => setWizardState(() => step -= 1),
                    child: const Text('Voltar'),
                  ),
                if (step < 2)
                  ElevatedButton(
                    key: const Key('wizard_next_button'),
                    onPressed: () => setWizardState(() => step += 1),
                    child: const Text('Próximo'),
                  )
                else
                  ElevatedButton(
                    key: const Key('wizard_submit_button'),
                    onPressed: () {
                      widget.appState.submitAnamnesis(
                        type: 'Anamnese Completa Check-in',
                        corporalAnswers: {
                          'Possui lesões ou dores articulares?': lesoesCtrl.text
                              .trim(),
                        },
                        alimentarAnswers: {
                          'Quantas refeições faz por dia?': refeicoesCtrl.text
                              .trim(),
                        },
                        espacialAnswers: {
                          'Local de treino': localCtrl.text.trim(),
                        },
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Enviar para o Treinador'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// Retorna a cor do badge/pílula de percentual de recuperação muscular
  /// seguindo o modelo de referência visual (Verde vibrante -> Verde-lima -> Amarelo-oliva -> Laranja -> Vermelho).
  static Color _recoveryPillColor(int recoveryPercent) {
    if (recoveryPercent >= 92) {
      return const Color(0xFF34C759); // Verde vibrante (ex: 94%)
    } else if (recoveryPercent >= 88) {
      return const Color(0xFF84CC16); // Verde-lima (ex: 91%)
    } else if (recoveryPercent >= 80) {
      return const Color(0xFFC2B213); // Amarelo-oliva (ex: 86%)
    } else if (recoveryPercent >= 65) {
      return const Color(0xFFD97706); // Âmbar/Laranja (ex: 76%, 79%)
    } else {
      return RecTheme.primaryRed; // Vermelho (< 65%, em fadiga)
    }
  }

  void _openMuscleRecoveryFullFeature(
    BuildContext context,
    StudentMobileProfile student, {
    MuscleGroup? initialSelectedGroup,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MuscleRecoveryFullFeatureScreen(
          student: student,
          initialSelectedGroup: initialSelectedGroup,
        ),
      ),
    );
  }

  void _openPersonalRecordsAllExercises(
    BuildContext context,
    StudentMobileProfile student,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PersonalRecordsAllExercisesScreen(
          student: student,
          appState: widget.appState,
        ),
      ),
    );
  }
}

/// Nova Feature de Tela Cheia ("Ver tudo" em Recuperação Muscular):
/// Central de Prontidão & Recuperação Muscular por Grupamento (Modelo Científico SRA / Banister).
class MuscleRecoveryFullFeatureScreen extends StatefulWidget {
  final StudentMobileProfile student;
  final MuscleGroup? initialSelectedGroup;

  const MuscleRecoveryFullFeatureScreen({
    super.key,
    required this.student,
    this.initialSelectedGroup,
  });

  @override
  State<MuscleRecoveryFullFeatureScreen> createState() =>
      _MuscleRecoveryFullFeatureScreenState();
}

class _MuscleRecoveryFullFeatureScreenState
    extends State<MuscleRecoveryFullFeatureScreen> {
  String _selectedFilter = 'Todos';
  late MuscleGroup _inspectedGroup;

  @override
  void initState() {
    super.initState();
    _inspectedGroup =
        widget.initialSelectedGroup ??
        (widget.student.muscleRecovery.isNotEmpty
            ? widget.student.muscleRecovery.first.group
            : MuscleGroup.peitoralMaior);
  }

  Color _badgeColor(int pct) => _YouScreenState._recoveryPillColor(pct);

  int _estimatedHoursToFullRecovery(MuscleRecoveryStatus status) {
    if (status.recoveryPercent >= 95) return 0;
    final remainingFraction = (95 - status.recoveryPercent) / 100.0;
    return (remainingFraction * status.group.recoveryTauHours * 2.2)
        .ceil()
        .clamp(1, 72);
  }

  @override
  Widget build(BuildContext context) {
    final allRecoveries = widget.student.muscleRecovery;
    final overallRecoveryPercent = allRecoveries.isEmpty
        ? 100
        : (allRecoveries.fold<int>(0, (s, r) => s + r.recoveryPercent) /
                  allRecoveries.length)
              .round()
              .clamp(0, 100);

    final readyCount = allRecoveries
        .where((r) => r.recoveryPercent >= 80)
        .length;
    final moderateCount = allRecoveries
        .where((r) => r.recoveryPercent >= 60 && r.recoveryPercent < 80)
        .length;
    final fatiguedCount = allRecoveries
        .where((r) => r.recoveryPercent < 60)
        .length;

    final readyCandidates =
        allRecoveries.where((r) => r.recoveryPercent >= 80).toList()..sort(
          (a, b) => b.recoveryPercent.compareTo(a.recoveryPercent),
        );
    final readyGroupsNames = readyCandidates
        .take(5)
        .map((r) => r.group.shortLabel)
        .join(', ');

    bool matchesFilter(MuscleRecoveryStatus rec, String filterName) {
      return switch (filterName) {
        'Prontos (≥80%)' => rec.recoveryPercent >= 80,
        'Em Recuperação' =>
          rec.recoveryPercent >= 60 && rec.recoveryPercent < 80,
        'Fatigados (<60%)' => rec.recoveryPercent < 60,
        'Trabalhados' => rec.weeklySetsCompleted > 0,
        'Anterior' => rec.group.isFrontBody,
        'Posterior' => !rec.group.isFrontBody,
        _ => true,
      };
    }

    final filtered = allRecoveries
        .where((rec) => matchesFilter(rec, _selectedFilter))
        .toList();

    final inspectedStatus = allRecoveries.firstWhere(
      (r) => r.group == _inspectedGroup,
      orElse: () => allRecoveries.isNotEmpty
          ? allRecoveries.first
          : MuscleRecoveryStatus(
              group: _inspectedGroup,
              recoveryPercent: 100,
              weeklySetsCompleted: 0,
              hoursSinceLastTrained: 0,
            ),
    );
    final estHoursRemaining = _estimatedHoursToFullRecovery(inspectedStatus);

    return Scaffold(
      key: const Key('muscle_recovery_full_feature_screen'),
      backgroundColor: RecTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: RecTheme.cardBackground,
        foregroundColor: RecTheme.textPrimary,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recuperação Muscular Completa',
              style: TextStyle(
                color: RecTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Prontidão de Treino · Modelo Científico SRA & Impulse-Response',
              style: TextStyle(
                color: RecTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Painel Global de Prontidão & Recomendação Inteligente de Treino
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RecTheme.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RecTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              value: (overallRecoveryPercent / 100.0).clamp(
                                0.0,
                                1.0,
                              ),
                              strokeWidth: 5.5,
                              strokeCap: StrokeCap.round,
                              backgroundColor: RecTheme.surfaceInput,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _badgeColor(overallRecoveryPercent),
                              ),
                            ),
                          ),
                          Text(
                            '$overallRecoveryPercent%',
                            style: const TextStyle(
                              color: RecTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            overallRecoveryPercent >= 80
                                ? 'Prontidão Alta para Treinar'
                                : (overallRecoveryPercent >= 65
                                      ? 'Recuperação Sistêmica Moderada'
                                      : 'Alta Fadiga Acumulada'),
                            style: const TextStyle(
                              color: RecTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            readyGroupsNames.isNotEmpty
                                ? 'Sugestão de hoje: priorizar $readyGroupsNames (prontos para carga máxima).'
                                : 'Sugestão de hoje: priorizar sessão regenerativa ou mobilidade.',
                            style: const TextStyle(
                              color: RecTheme.textSecondary,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCounterBox(
                        'PRONTOS (≥80%)',
                        '$readyCount músc.',
                        const Color(0xFF34C759),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _summaryCounterBox(
                        'EM RECUP. (60-79%)',
                        '$moderateCount músc.',
                        const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _summaryCounterBox(
                        'FATIGADOS (<60%)',
                        '$fatiguedCount músc.',
                        RecTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Card de Diagnóstico Fisiológico do Grupamento Selecionado (com Logo Anatômico Ampliado)
          Container(
            key: const Key('recovery_feature_inspected_card'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RecTheme.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _badgeColor(
                  inspectedStatus.recoveryPercent,
                ).withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: RecTheme.surfaceInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RecTheme.borderSubtle),
                  ),
                  child: MuscleGroupLogoWidget(
                    group: inspectedStatus.group,
                    width: 78,
                    height: 92,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              inspectedStatus.group.label,
                              style: const TextStyle(
                                color: RecTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _badgeColor(
                                inspectedStatus.recoveryPercent,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${inspectedStatus.recoveryPercent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${inspectedStatus.group.macroGroup} · Vista ${inspectedStatus.group.isFrontBody ? "Anterior" : "Posterior"} · ${inspectedStatus.weeklySetsCompleted} séries na semana',
                        style: const TextStyle(
                          color: RecTheme.primaryRedLight,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fibras: ${inspectedStatus.group.fiberDirectionDescription}',
                        style: const TextStyle(
                          color: RecTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estHoursRemaining == 0
                            ? 'Status SRA: 100% Pronto para novo estímulo intenso (τ = ${inspectedStatus.group.recoveryTauHours.toStringAsFixed(0)}h)'
                            : 'Status SRA: Último treino há ${inspectedStatus.hoursSinceLastTrained}h · Recuperação plena em ~${estHoursRemaining}h (τ = ${inspectedStatus.group.recoveryTauHours.toStringAsFixed(0)}h)',
                        style: const TextStyle(
                          color: RecTheme.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Filtros Rápidos e Lista Completa dos 19 Grupamentos com Logos e Barras SRA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RecTheme.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RecTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Todos os Grupamentos Musculares (19 Subdivisões)',
                  style: TextStyle(
                    color: RecTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Toque em qualquer grupamento abaixo para inspecionar sua prontidão SRA e fibras anatômicas',
                  style: TextStyle(color: RecTheme.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    'Todos',
                    'Prontos (≥80%)',
                    'Em Recuperação',
                    'Fatigados (<60%)',
                    'Trabalhados',
                    'Anterior',
                    'Posterior',
                  ].map((filter) {
                    final selected = _selectedFilter == filter;
                    return ChoiceChip(
                      key: Key('recovery_feature_filter_$filter'),
                      label: Text(
                        filter,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: selected,
                      selectedColor: RecTheme.primaryRed,
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = filter;
                          final matching = allRecoveries
                              .where((rec) => matchesFilter(rec, filter))
                              .toList();
                          if (matching.isNotEmpty &&
                              !matching.any(
                                (rec) => rec.group == _inspectedGroup,
                              )) {
                            _inspectedGroup = matching.first.group;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  Container(
                    key: const Key('recovery_feature_empty_state'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: RecTheme.surfaceInput,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RecTheme.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Nenhum grupamento muscular enquadrado neste filtro.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: RecTheme.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          key: const Key('recovery_feature_reset_filter_button'),
                          onPressed: () =>
                              setState(() => _selectedFilter = 'Todos'),
                          child: const Text('Mostrar todos os 19 grupamentos'),
                        ),
                      ],
                    ),
                  )
                else
                  ...filtered.map((rec) {
                  final pillColor = _badgeColor(rec.recoveryPercent);
                  final isSelected = rec.group == _inspectedGroup;
                  final estHours = _estimatedHoursToFullRecovery(rec);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      key: Key('recovery_row_${rec.group.name}'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _inspectedGroup = rec.group),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? pillColor.withValues(alpha: 0.12)
                              : RecTheme.surfaceInput,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? pillColor
                                : RecTheme.borderSubtle,
                          ),
                        ),
                        child: Row(
                          children: [
                            MuscleGroupLogoWidget(
                              group: rec.group,
                              width: 52,
                              height: 62,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          rec.group.label,
                                          style: const TextStyle(
                                            color: RecTheme.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: pillColor,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '${rec.recoveryPercent}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${rec.weeklySetsCompleted} séries na semana · ${estHours == 0 ? "Pronto para treinar" : "Pronto em ~${estHours}h"}',
                                    style: const TextStyle(
                                      color: RecTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: (rec.recoveryPercent / 100.0)
                                          .clamp(0.0, 1.0),
                                      minHeight: 6,
                                      backgroundColor: RecTheme.cardBackground,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        pillColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCounterBox(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: RecTheme.surfaceInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RecTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: RecTheme.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PersonalRecordRankingFilter {
  maxWeight('Peso Máximo'),
  bestOneRm('Melhor 1RM Estimado'),
  maxReps('Repetições Máximas');

  final String label;
  const _PersonalRecordRankingFilter(this.label);
}

/// Nova Feature 1 (4ª Imagem): Lista completa de TODOS os exercícios feitos pelo aluno
/// com filtros por "Peso Máximo", "Melhor 1RM Estimado" e "Repetições Máximas" e botão "COMPARTILHAR".
class PersonalRecordsAllExercisesScreen extends StatefulWidget {
  final StudentMobileProfile student;
  final RecAppState appState;

  const PersonalRecordsAllExercisesScreen({
    super.key,
    required this.student,
    required this.appState,
  });

  @override
  State<PersonalRecordsAllExercisesScreen> createState() =>
      _PersonalRecordsAllExercisesScreenState();
}

class _PersonalRecordsAllExercisesScreenState
    extends State<PersonalRecordsAllExercisesScreen> {
  _PersonalRecordRankingFilter _activeFilter =
      _PersonalRecordRankingFilter.maxWeight;

  @override
  Widget build(BuildContext context) {
    final summaries = RecoveryCalculator.computeAllExercisesCompleteRecords(
      widget.student,
    );

    final sortedSummaries = List<ExerciseCompleteRecordSummary>.from(summaries)
      ..sort((a, b) {
        return switch (_activeFilter) {
          _PersonalRecordRankingFilter.maxWeight =>
            b.maxWeightKg.compareTo(a.maxWeightKg),
          _PersonalRecordRankingFilter.bestOneRm =>
            b.estimatedOneRepMaxKg.compareTo(a.estimatedOneRepMaxKg),
          _PersonalRecordRankingFilter.maxReps => b.maxReps.compareTo(a.maxReps),
        };
      });

    return Scaffold(
      key: const Key('personal_records_all_exercises_screen'),
      backgroundColor: RecTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: RecTheme.scaffoldBackground,
        foregroundColor: RecTheme.textPrimary,
        elevation: 0,
        title: const Text(
          'Recordes Pessoais',
          style: TextStyle(
            color: RecTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _PersonalRecordRankingFilter.values.map((filter) {
                  final selected = _activeFilter == filter;
                  final filterKey = switch (filter) {
                    _PersonalRecordRankingFilter.maxWeight =>
                      const Key('pr_filter_max_weight'),
                    _PersonalRecordRankingFilter.bestOneRm =>
                      const Key('pr_filter_best_1rm'),
                    _PersonalRecordRankingFilter.maxReps =>
                      const Key('pr_filter_max_reps'),
                  };
                  return ChoiceChip(
                    key: filterKey,
                    showCheckmark: true,
                    checkmarkColor: Colors.white,
                    label: Text(
                      filter.label,
                      style: TextStyle(
                        color: selected ? Colors.white : RecTheme.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: selected,
                    backgroundColor: RecTheme.scaffoldBackground,
                    selectedColor: const Color(0xFF343140),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF524E63)
                          : RecTheme.borderSubtle,
                    ),
                    shape: const StadiumBorder(),
                    onSelected: (_) => setState(() => _activeFilter = filter),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: sortedSummaries.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum exercício registrado ainda.',
                      style: TextStyle(color: RecTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: sortedSummaries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final summary = sortedSummaries[index];
                      final (dateLabel, mainMetric, subMetric) =
                          switch (_activeFilter) {
                            _PersonalRecordRankingFilter.maxWeight => (
                              summary.maxWeightDateLabel,
                              '${summary.maxWeightKg} kg',
                              '${summary.maxWeightKg}kg x ${summary.maxWeightReps} reps',
                            ),
                            _PersonalRecordRankingFilter.bestOneRm => (
                              summary.oneRepMaxDateLabel,
                              '${summary.estimatedOneRepMaxKg} kg',
                              summary.oneRepMaxShortSetLabel,
                            ),
                            _PersonalRecordRankingFilter.maxReps => (
                              summary.maxRepsDateLabel,
                              '${summary.maxReps} reps',
                              '${summary.maxRepsWeightKg}kg x ${summary.maxReps} reps',
                            ),
                          };

                      return InkWell(
                        key: Key('pr_all_exercise_row_${summary.exerciseName}'),
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ExercisePersonalRecordsDetailScreen(
                                    summary: summary,
                                  ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              ExerciseAnimationWidget(
                                animationKey: summary.animationKey,
                                exerciseName: summary.exerciseName,
                                width: 58,
                                height: 58,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      summary.exerciseName,
                                      style: const TextStyle(
                                        color: RecTheme.textPrimary,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateLabel,
                                      style: const TextStyle(
                                        color: RecTheme.textMuted,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    mainMetric,
                                    style: const TextStyle(
                                      color: RecTheme.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    subMetric,
                                    style: const TextStyle(
                                      color: RecTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              key: const Key('pr_all_exercises_share_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              onPressed: () {
                if (sortedSummaries.isNotEmpty) {
                  final top = sortedSummaries.first;
                  widget.appState.publishCustomCommunitySummary(
                    workoutTitle: 'Recorde Pessoal · ${top.exerciseName}',
                    caption:
                        'Novo recorde em ${top.exerciseName}: Peso Máximo ${top.maxWeightKg}kg · 1RM Estimado ${top.estimatedOneRepMaxKg}kg!',
                    totalVolumeKg: top.maxSessionVolumeKg,
                    setsCount: top.maxSessionSetsCount,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Recordes pessoais compartilhados na comunidade!',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.reply_rounded, size: 20),
              label: const Text(
                'COMPARTILHAR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nova Feature 2 (5ª Imagem): Detalhes dos 5 Recordes Pessoais batidos em um exercício:
/// 1. 1RM Estimado, 2. Peso Máximo, 3. Repetições Máximas, 4. Volume da Sessão Máximo, 5. Volume Máximo de uma Série
/// + Botão "Ver histórico de recordes" + Seção "Desempenho Estimado" (Fórmula de Epley).
class ExercisePersonalRecordsDetailScreen extends StatefulWidget {
  final ExerciseCompleteRecordSummary summary;

  const ExercisePersonalRecordsDetailScreen({super.key, required this.summary});

  @override
  State<ExercisePersonalRecordsDetailScreen> createState() =>
      _ExercisePersonalRecordsDetailScreenState();
}

class _ExercisePersonalRecordsDetailScreenState
    extends State<ExercisePersonalRecordsDetailScreen> {
  int _selectedSubTab = 2; // 0: Histórico, 1: Progresso, 2: Recordes, 3: Classificação

  static const _subTabLabels = [
    'Histórico',
    'Progresso',
    'Recordes',
    'Classificação',
  ];

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    const epleyRepsList = [1, 2, 3, 5, 8, 10, 12];

    return Scaffold(
      key: const Key('exercise_personal_records_detail_screen'),
      backgroundColor: RecTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: RecTheme.scaffoldBackground,
        foregroundColor: RecTheme.textPrimary,
        elevation: 0,
        title: Text(
          s.exerciseName,
          style: const TextStyle(
            color: RecTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de sub-abas idêntica à referência ("Histórico | Progresso | Recordes | Classificação")
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: RecTheme.borderSubtle)),
            ),
            child: Row(
              children: List.generate(_subTabLabels.length, (i) {
                final active = _selectedSubTab == i;
                return Expanded(
                  child: InkWell(
                    key: Key('exercise_detail_subtab_$i'),
                    onTap: () => setState(() => _selectedSubTab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: active ? Colors.white : Colors.transparent,
                            width: 2.2,
                          ),
                        ),
                      ),
                      child: Text(
                        _subTabLabels[i],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active
                              ? RecTheme.textPrimary
                              : RecTheme.textMuted,
                          fontSize: 12.5,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: switch (_selectedSubTab) {
              0 => _buildHistoryTab(s),
              1 => _buildProgressTab(s, epleyRepsList),
              3 => _buildClassificationTab(s),
              _ => _buildRecordsTab(context, s, epleyRepsList),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsTab(
    BuildContext context,
    ExerciseCompleteRecordSummary s,
    List<int> epleyRepsList,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        const Text(
          'Recordes Pessoais',
          style: TextStyle(
            color: RecTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Veja os seus melhores levantamentos para ${s.exerciseName}',
          style: const TextStyle(color: RecTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),
        _buildPrMedalRow(
          rowKey: const Key('record_row_1rm'),
          title: '1RM Estimado',
          dateLabel: s.oneRepMaxDateLabel,
          mainValue: '${s.estimatedOneRepMaxKg}kg',
          subValue: s.oneRepMaxSetLabel,
        ),
        const SizedBox(height: 18),
        _buildPrMedalRow(
          rowKey: const Key('record_row_max_weight'),
          title: 'Peso Máximo',
          dateLabel: s.maxWeightDateLabel,
          mainValue: '${s.maxWeightKg}kg',
          subValue: s.maxWeightSetLabel,
        ),
        const SizedBox(height: 18),
        _buildPrMedalRow(
          rowKey: const Key('record_row_max_reps'),
          title: 'Repetições Máximas',
          dateLabel: s.maxRepsDateLabel,
          mainValue: '${s.maxReps}',
          subValue: s.maxRepsSetLabel,
        ),
        const SizedBox(height: 18),
        _buildPrMedalRow(
          rowKey: const Key('record_row_max_session_volume'),
          title: 'Volume da Sessão Máximo',
          dateLabel: s.maxSessionDateLabel,
          mainValue: '${s.maxSessionVolumeKg}kg',
          subValue: '${s.maxSessionSetsCount} Séries',
        ),
        const SizedBox(height: 18),
        _buildPrMedalRow(
          rowKey: const Key('record_row_max_set_volume'),
          title: 'Volume Máximo de uma Série',
          dateLabel: s.maxSingleSetDateLabel,
          mainValue: '${s.maxSingleSetVolumeKg}kg',
          subValue: s.maxSingleSetLabel,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            key: const Key('exercise_pr_history_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            onPressed: () => _showPrHistorySheet(context, s),
            child: const Text(
              'Ver histórico de recordes',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Desempenho Estimado',
          style: TextStyle(
            color: RecTheme.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Verifique quantas repetições você pode fazer com diferentes pesos, estimadas usando a fórmula de Epley.',
          style: TextStyle(color: RecTheme.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: RecTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RecTheme.borderSubtle),
          ),
          child: Column(
            children: epleyRepsList.map((targetReps) {
              final estimatedWeight = targetReps == 1
                  ? s.estimatedOneRepMaxKg
                  : (s.estimatedOneRepMaxKg / (1.0 + targetReps / 30.0))
                        .round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$targetReps ${targetReps == 1 ? "repetição (1RM)" : "repetições"}',
                      style: const TextStyle(
                        color: RecTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${estimatedWeight}kg',
                      style: const TextStyle(
                        color: RecTheme.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPrMedalRow({
    required Key rowKey,
    required String title,
    required String dateLabel,
    required String mainValue,
    required String subValue,
  }) {
    return Row(
      key: rowKey,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _GoldPrMedalIcon(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: RecTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                dateLabel,
                style: const TextStyle(color: RecTheme.textMuted, fontSize: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              mainValue,
              style: const TextStyle(
                color: RecTheme.textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subValue,
              style: const TextStyle(
                color: RecTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryTab(ExerciseCompleteRecordSummary s) {
    if (s.historyEntries.isEmpty) {
      return const Center(
        child: Text(
          'Sem marcos históricos adicionais registrados.',
          style: TextStyle(color: RecTheme.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: s.historyEntries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, idx) {
        final item = s.historyEntries[idx];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: RecTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RecTheme.borderSubtle),
          ),
          child: Row(
            children: [
              const _GoldPrMedalIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.recordType,
                      style: const TextStyle(
                        color: RecTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      item.dateLabel,
                      style: const TextStyle(
                        color: RecTheme.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.valueLabel,
                    style: const TextStyle(
                      color: RecTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    item.detailLabel,
                    style: const TextStyle(
                      color: RecTheme.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressTab(
    ExerciseCompleteRecordSummary s,
    List<int> epleyRepsList,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ExerciseAnimationWidget(
            animationKey: s.animationKey,
            exerciseName: s.exerciseName,
            width: 240,
            height: 170,
            showPhaseLabel: true,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: RecTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RecTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Músculo Alvo Principal: ${s.primaryMuscle.label}',
                style: const TextStyle(
                  color: RecTheme.primaryRedLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.primaryMuscle.fiberDirectionDescription,
                style: const TextStyle(
                  color: RecTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationTab(ExerciseCompleteRecordSummary s) {
    final ratioLabel = s.estimatedOneRepMaxKg >= 100
        ? 'Nível Avançado (1RM ${s.estimatedOneRepMaxKg}kg)'
        : (s.estimatedOneRepMaxKg >= 50
              ? 'Nível Intermediário (1RM ${s.estimatedOneRepMaxKg}kg)'
              : 'Nível Base em Evolução (1RM ${s.estimatedOneRepMaxKg}kg)');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RecTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: RecTheme.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Classificação de Força no Exercício',
              style: TextStyle(
                color: RecTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ratioLabel,
              style: const TextStyle(
                color: Color(0xFFFACC15),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Baseado em seu melhor 1RM estimado (${s.estimatedOneRepMaxKg}kg) e volume máximo por sessão (${s.maxSessionVolumeKg}kg).',
              style: const TextStyle(
                color: RecTheme.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrHistorySheet(
    BuildContext context,
    ExerciseCompleteRecordSummary s,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: RecTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          key: const Key('exercise_pr_history_modal'),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico de Recordes · ${s.exerciseName}',
                style: const TextStyle(
                  color: RecTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (s.historyEntries.isEmpty)
                const Text(
                  'Nenhum histórico anterior registrado.',
                  style: TextStyle(color: RecTheme.textSecondary),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: s.historyEntries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final entry = s.historyEntries[i];
                      return Row(
                        children: [
                          const _GoldPrMedalIcon(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.recordType,
                                  style: const TextStyle(
                                    color: RecTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  entry.dateLabel,
                                  style: const TextStyle(
                                    color: RecTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                entry.valueLabel,
                                style: const TextStyle(
                                  color: RecTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                entry.detailLabel,
                                style: const TextStyle(
                                  color: RecTheme.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoldPrMedalIcon extends StatelessWidget {
  const _GoldPrMedalIcon();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.workspace_premium_outlined,
          color: Color(0xFFFACC15),
          size: 24,
        ),
        Transform.translate(
          offset: const Offset(0, -4),
          child: const Text(
            'PR',
            style: TextStyle(
              color: Color(0xFFFACC15),
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}
