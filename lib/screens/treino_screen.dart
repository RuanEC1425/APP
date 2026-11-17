import 'dart:async';
import 'package:flutter/material.dart';

import '../models/workout_models.dart';
import '../state/app_state.dart';
import '../theme/rec_theme.dart';

class TreinoScreen extends StatefulWidget {
  final RecAppState appState;

  const TreinoScreen({super.key, required this.appState});

  @override
  State<TreinoScreen> createState() => _TreinoScreenState();
}

class _TreinoScreenState extends State<TreinoScreen> {
  Timer? _restTimer;
  int _remainingRestSeconds = 0;
  String _activeRestExerciseName = '';

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer(int seconds, String exerciseName) {
    _restTimer?.cancel();
    setState(() {
      _remainingRestSeconds = seconds;
      _activeRestExerciseName = exerciseName;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingRestSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingRestSeconds = 0;
        });
      } else {
        setState(() {
          _remainingRestSeconds -= 1;
        });
      }
    });
  }

  void _adjustRestTimer(int deltaSeconds) {
    setState(() {
      _remainingRestSeconds = (_remainingRestSeconds + deltaSeconds).clamp(
        0,
        600,
      );
      if (_remainingRestSeconds == 0) {
        _restTimer?.cancel();
      }
    });
  }

  Color _colorForSetType(SetType type) {
    switch (type) {
      case SetType.warmUp:
        return RecTheme.amber;
      case SetType.feeder:
        return RecTheme.cyan;
      case SetType.working:
        return RecTheme.emerald;
      case SetType.top:
        return RecTheme.primaryRed;
      case SetType.backoff:
        return RecTheme.blue;
      case SetType.drop:
        return RecTheme.purple;
      case SetType.superSet:
        return const Color(0xFFEC4899);
      case SetType.cluster:
        return const Color(0xFFF97316);
      case SetType.custom:
        return RecTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.appState.activeStudent;
    final days = student.workoutDays;
    final activeDay = widget.appState.activeWorkoutDay;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            // Cabeçalho da Ficha do Treinador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ficha Prescrita pelo Treinador',
                        style: TextStyle(
                          color: RecTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sincronizado com o banco de exercícios da REC Consultoria',
                        style: TextStyle(
                          color: RecTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: RecTheme.emerald.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: RecTheme.emerald.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '${activeDay.durationWeeks} Semanas · ${activeDay.status}',
                    style: const TextStyle(
                      color: RecTheme.emerald,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Abas de Divisão (Treino A, B, C, D)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(days.length, (index) {
                  final d = days[index];
                  final selected =
                      widget.appState.selectedWorkoutDayIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      key: Key('workout_day_tab_${d.code}'),
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => widget.appState.selectWorkoutDay(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? RecTheme.primaryRed
                              : RecTheme.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? RecTheme.primaryRed
                                : RecTheme.borderSubtle,
                          ),
                        ),
                        child: Text(
                          'Treino ${d.code}',
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : RecTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // Card Resumo da Divisão Atual + Legenda de Tipos de Série
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
                    activeDay.title,
                    style: const TextStyle(
                      color: RecTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    activeDay.subtitle,
                    style: const TextStyle(
                      color: RecTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: SetType.values
                        .where((t) => t != SetType.custom)
                        .map((type) {
                          final color = _colorForSetType(type);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: color.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              '${type.shortCode}: ${type.label}',
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lista de Exercícios Prescritos pelo Treinador
            ...activeDay.exercises.map(
              (exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildExerciseCard(context, exercise),
              ),
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('finish_prescribed_workout_button'),
                onPressed: () {
                  final completed = widget.appState.finishActivePrescribedWorkout(
                    durationMinutes: 56,
                    notes:
                        'Concluído pela aba Treino (${activeDay.completedSets}/${activeDay.totalSets} séries).',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${completed.workoutName} salvo no histórico da Home (${completed.totalWeightLiftedKg.toStringAsFixed(0)} kg)!',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Finalizar Treino Prescrito'),
              ),
            ),
          ],
        ),

        // Cronômetro Flutuante de Descanso
        if (_remainingRestSeconds > 0)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: RecTheme.primaryRed, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_rounded,
                    color: RecTheme.primaryRed,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Descanso · $_activeRestExerciseName',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: RecTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${_remainingRestSeconds}s restantes',
                          style: const TextStyle(
                            color: RecTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _adjustRestTimer(-15),
                    icon: const Text(
                      '-15s',
                      style: TextStyle(
                        color: RecTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _adjustRestTimer(15),
                    icon: const Text(
                      '+15s',
                      style: TextStyle(
                        color: RecTheme.primaryRedLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _adjustRestTimer(-9999),
                    child: const Text('Pular'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseCard(BuildContext context, WorkoutExercise exercise) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RecTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RecTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do Exercício + Grupamento + Descanso
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: RecTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _pillBadge(
                          label: 'Músculo: ${exercise.primaryMuscle.label}',
                          color: RecTheme.primaryRed,
                        ),
                        _pillBadge(
                          label:
                              'Faixa Sugerida: ${exercise.targetRepsRange} reps',
                          color: RecTheme.emerald,
                        ),
                        InkWell(
                          onTap: () => _startRestTimer(
                            exercise.restSeconds,
                            exercise.name,
                          ),
                          child: _pillBadge(
                            label:
                                'Descanso: ${exercise.restSeconds}s (Iniciar)',
                            color: RecTheme.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Adicionar Série / Tipo de Série',
                onPressed: () => _showAddSetDialog(context, exercise),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: RecTheme.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Técnica Avançada cadastrada pelo treinador
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: RecTheme.surfaceInput,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RecTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: RecTheme.primaryRed,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Técnica Avançada: ${exercise.advancedTechnique}',
                        style: const TextStyle(
                          color: RecTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (exercise.coachNotes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Obs. Treinador: ${exercise.coachNotes}',
                    style: const TextStyle(
                      color: RecTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cabeçalho das Séries
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 112,
                  child: Text(
                    'TIPO DE SÉRIE',
                    style: TextStyle(
                      color: RecTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'META REPS',
                    style: TextStyle(
                      color: RecTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    'CARGA (KG)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: RecTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    'FEITO',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: RecTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 8),

          // Linhas de Séries (Warm-up, Feeder, Working, Top, Backoff, Drop, Super, Cluster, Custom)
          ...exercise.sets.map((s) {
            final typeColor = _colorForSetType(s.type);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: typeColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '#${s.index} ${s.displayTypeLabel}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${s.targetReps} reps',
                      style: const TextStyle(
                        color: RecTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    child: InkWell(
                      onTap: () => _showEditWeightDialog(context, exercise, s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: RecTheme.surfaceInput,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: RecTheme.borderSubtle),
                        ),
                        child: Text(
                          '${s.weightKg.toStringAsFixed(0)} kg',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: RecTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Checkbox(
                      key: Key('checkbox_${exercise.id}_${s.id}'),
                      value: s.completed,
                      onChanged: (val) {
                        final checked = val ?? false;
                        widget.appState.updateExerciseSet(
                          exerciseId: exercise.id,
                          setId: s.id,
                          completed: checked,
                        );
                        if (checked) {
                          _startRestTimer(exercise.restSeconds, exercise.name);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _pillBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showEditWeightDialog(
    BuildContext context,
    WorkoutExercise exercise,
    ExerciseSet setItem,
  ) {
    final weightCtrl = TextEditingController(
      text: setItem.weightKg.toStringAsFixed(0),
    );
    final repsCtrl = TextEditingController(text: '${setItem.completedReps}');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${exercise.name} · ${setItem.displayTypeLabel}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Carga Utilizada (kg)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: repsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Repetições Executadas',
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.appState.updateExerciseSet(
                exerciseId: exercise.id,
                setId: setItem.id,
                weightKg: double.tryParse(weightCtrl.text) ?? setItem.weightKg,
                completedReps:
                    int.tryParse(repsCtrl.text) ?? setItem.completedReps,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Salvar Série'),
          ),
        ],
      ),
    );
  }

  void _showAddSetDialog(BuildContext context, WorkoutExercise exercise) {
    SetType selectedType = SetType.working;
    final customLabelCtrl = TextEditingController();
    final repsCtrl = TextEditingController(text: exercise.targetRepsRange);
    final weightCtrl = TextEditingController(
      text: exercise.sets.isNotEmpty
          ? exercise.sets.last.weightKg.toStringAsFixed(0)
          : '40',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: Text('Nova Série · ${exercise.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<SetType>(
                      initialValue: selectedType,
                      dropdownColor: RecTheme.surfaceInput,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Série',
                      ),
                      items: SetType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => selectedType = v);
                        }
                      },
                    ),
                    if (selectedType == SetType.custom) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: customLabelCtrl,
                        decoration: const InputDecoration(
                          labelText:
                              'Nome do Tipo Customizado (ex: Rest-Pause)',
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      controller: repsCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Faixa de Repetições (ex: 8 a 10)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Carga Inicial (kg)',
                      ),
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
                  onPressed: () {
                    widget.appState.addSetToExercise(
                      exerciseId: exercise.id,
                      type: selectedType,
                      customTypeLabel: selectedType == SetType.custom
                          ? customLabelCtrl.text.trim()
                          : null,
                      targetReps: repsCtrl.text.trim(),
                      weightKg: double.tryParse(weightCtrl.text) ?? 40,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
