import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/profile_evolution_models.dart';
import '../models/workout_models.dart';
import '../state/recovery_calculator.dart';
import '../theme/rec_theme.dart';

/// Ilustração Anatômica 3D Écorché Realista (Frente e Costas) das 19 subdivisões
/// musculares, modelada conforme a referência visual da aba "You":
/// - Corpo anatômico contínuo em escala de cinza/prata 3D esculpido (cabeça, face,
///   pescoço, aponeurose toracolombar, tendões, mãos, joelhos, tornozelos e pés);
/// - Colorido dinamicamente de acordo com o desgaste muscular calculado a partir
///   dos treinos registrados pelo aluno:
///   * Sem desgaste na semana -> Cinza anatômico 3D neutro
///   * Menos desgaste -> Mais Azul (#3B82F6 / #4A8FE7)
///   * Transição intermediária -> Gradiente contínuo entre Azul e Vermelho
///   * Mais desgaste -> Mais Vermelho (#DC2626 / #E04832)
class MuscleBody3DWidget extends StatefulWidget {
  final List<MuscleRecoveryStatus> muscleStatuses;

  const MuscleBody3DWidget({super.key, required this.muscleStatuses});

  /// Cor base para músculo sem treino registrado na semana (cinza anatômico 3D).
  static const Color unworkedMuscleColor = Color(0xFF9CA3AF);

  /// Cor de menor desgaste muscular (azul anatômico vibrante).
  static const Color lowWearBlueColor = Color(0xFF3B82F6);

  /// Cor intermediária do gradiente de desgaste (transição azul -> vermelho).
  static const Color midWearTransitionColor = Color(0xFF8B5CF6);

  /// Cor de maior desgaste muscular (vermelho/vermilion anatômico intenso).
  static const Color highWearRedColor = Color(0xFFE0422D);

  /// Calcula a cor de preenchimento muscular com base no índice normalizado de
  /// desgaste (`wearNormalized` de 0.0 a 1.0):
  /// - Quando `isWorked == false`: retorna cinza anatômico 3D (`unworkedMuscleColor`);
  /// - Quando `isWorked == true`: interpola num gradiente contínuo de Azul (menos
  ///   desgaste, 0.0) até Vermelho (mais desgaste, 1.0).
  static Color colorForWear(double wearNormalized, {bool isWorked = true}) {
    if (!isWorked) {
      return unworkedMuscleColor;
    }
    final t = wearNormalized.clamp(0.0, 1.0);
    if (t <= 0.42) {
      final localT = (t / 0.42).clamp(0.0, 1.0);
      return Color.lerp(
        lowWearBlueColor,
        const Color(0xFF6366F1),
        localT,
      )!;
    } else if (t <= 0.72) {
      final localT = ((t - 0.42) / 0.30).clamp(0.0, 1.0);
      return Color.lerp(
        const Color(0xFF6366F1),
        const Color(0xFFE13D52),
        localT,
      )!;
    } else {
      final localT = ((t - 0.72) / 0.28).clamp(0.0, 1.0);
      return Color.lerp(
        const Color(0xFFE13D52),
        highWearRedColor,
        localT,
      )!;
    }
  }

  /// Retorna a cor correspondente ao estado atual de desgaste de um grupamento.
  static Color statusWearColor(MuscleRecoveryStatus? status) {
    if (status == null) return unworkedMuscleColor;
    final worked = status.workedThisWeek || status.wearPercent > 0;
    return colorForWear(status.wearNormalized, isWorked: worked);
  }

  @override
  State<MuscleBody3DWidget> createState() => _MuscleBody3DWidgetState();
}

class _MuscleBody3DWidgetState extends State<MuscleBody3DWidget> {
  MuscleGroup? _selectedMuscle;
  bool _showFiberLines = true;

  static const double _canonWidth = 200.0;
  static const double _canonHeight = 420.0;

  Map<MuscleGroup, MuscleRecoveryStatus> get _statusMap {
    return {for (final s in widget.muscleStatuses) s.group: s};
  }

  /// Converte a posição do toque no canvas para coordenadas canônicas proporcionais
  /// (`sx` em [-0.5, 0.5] a partir do eixo central, `ny` em [0.0, 1.0] na altura do corpo).
  (double sx, double ny)? _toCanonicalCoords(Offset localPos, Size size) {
    if (size.width <= 0 || size.height <= 0) return null;
    final scale = math.min(
      size.width / _canonWidth,
      size.height / _canonHeight,
    );
    final figW = _canonWidth * scale;
    final figH = _canonHeight * scale;
    final left = (size.width - figW) * 0.5;
    final top = (size.height - figH) * 0.5;

    final sx = (localPos.dx - (left + figW * 0.5)) / figW;
    final ny = (localPos.dy - top) / figH;
    if (ny < 0.0 || ny > 1.0 || sx.abs() > 0.52) {
      // Fallback proporcional caso o toque ocorra nas bordas externas do canvas
      final fallbackSx = ((localPos.dx / size.width) - 0.5).clamp(-0.5, 0.5);
      final fallbackNy = (localPos.dy / size.height).clamp(0.0, 1.0);
      return (fallbackSx, fallbackNy);
    }
    return (sx, ny);
  }

  void _handleCanvasTap(Offset localPos, Size size, bool isFront) {
    final coords = _toCanonicalCoords(localPos, size);
    if (coords == null) return;
    final (sx, ny) = coords;
    final dx = sx.abs();

    final tapped = isFront ? _hitTestFront(dx, ny) : _hitTestBack(dx, ny);
    if (tapped != null) {
      setState(() {
        _selectedMuscle = _selectedMuscle == tapped ? null : tapped;
      });
    }
  }

  MuscleGroup? _hitTestFront(double dx, double ny) {
    if (ny >= 0.13 && ny <= 0.17 && dx >= 0.04 && dx <= 0.16) {
      return MuscleGroup.trapezio;
    }
    if (ny >= 0.15 && ny <= 0.25 && dx >= 0.16 && dx <= 0.34) {
      return dx > 0.23
          ? MuscleGroup.deltoideLateral
          : MuscleGroup.deltoideAnterior;
    }
    if (ny >= 0.15 && ny <= 0.205 && dx < 0.17) {
      return MuscleGroup.peitoralSuperior;
    }
    if (ny > 0.205 && ny <= 0.285 && dx <= 0.19) {
      return MuscleGroup.peitoralMaior;
    }
    if (ny >= 0.24 && ny <= 0.355 && dx >= 0.19 && dx <= 0.34) {
      return MuscleGroup.biceps;
    }
    if (ny > 0.355 && ny <= 0.49 && dx >= 0.22 && dx <= 0.42) {
      return MuscleGroup.antebraco;
    }
    if (ny > 0.28 && ny <= 0.46 && dx <= 0.085) {
      return MuscleGroup.retoAbdominal;
    }
    if (ny > 0.27 && ny <= 0.46 && dx > 0.085 && dx <= 0.175) {
      return MuscleGroup.obliquos;
    }
    if (ny > 0.46 && ny <= 0.67 && dx <= 0.075) {
      return MuscleGroup.adutores;
    }
    if (ny > 0.45 && ny <= 0.72 && dx > 0.045 && dx <= 0.22) {
      return MuscleGroup.quadriceps;
    }
    if (ny > 0.73 && ny <= 0.93 && dx <= 0.20) {
      return MuscleGroup.panturrilhas;
    }
    return null;
  }

  MuscleGroup? _hitTestBack(double dx, double ny) {
    if (ny >= 0.11 && ny <= 0.29 && dx <= 0.13) {
      return MuscleGroup.trapezio;
    }
    if (ny >= 0.15 && ny <= 0.24 && dx > 0.14 && dx <= 0.33) {
      return MuscleGroup.deltoidePosterior;
    }
    if (ny > 0.23 && ny <= 0.36 && dx >= 0.19 && dx <= 0.35) {
      return MuscleGroup.triceps;
    }
    if (ny > 0.355 && ny <= 0.49 && dx >= 0.22 && dx <= 0.42) {
      return MuscleGroup.antebraco;
    }
    if (ny > 0.21 && ny <= 0.37 && dx <= 0.20) {
      return MuscleGroup.dorsal;
    }
    if (ny > 0.35 && ny <= 0.445 && dx <= 0.13) {
      return MuscleGroup.lombar;
    }
    if (ny > 0.43 && ny <= 0.495 && dx >= 0.09 && dx <= 0.21) {
      return MuscleGroup.gluteoMedio;
    }
    if (ny > 0.45 && ny <= 0.58 && dx <= 0.20) {
      return MuscleGroup.gluteoMaximo;
    }
    if (ny > 0.57 && ny <= 0.73 && dx <= 0.20) {
      return MuscleGroup.posteriores;
    }
    if (ny > 0.73 && ny <= 0.93 && dx <= 0.20) {
      return MuscleGroup.panturrilhas;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final map = _statusMap;
    final selected = _selectedMuscle != null ? map[_selectedMuscle!] : null;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mapa Muscular Anatômico',
                      key: Key('anatomical_muscle_map_title'),
                      style: TextStyle(
                        color: RecTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Explore os músculos do treino · Cor varia do Azul (menos desgaste) ao Vermelho (mais desgaste)',
                      style: TextStyle(color: RecTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                key: const Key('toggle_muscle_fibers_button'),
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _showFiberLines = !_showFiberLines),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: RecTheme.primaryRed.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: RecTheme.primaryRed.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    _showFiberLines ? '3D FIBRAS ON' : '3D VIEW',
                    style: const TextStyle(
                      color: RecTheme.primaryRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Palco com fundo nativo do aplicativo (Frente e Costas lado a lado)
          Container(
            key: const Key('anatomy_native_stage'),
            height: 365,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'ANTERIOR (FRENTE)',
                        style: TextStyle(
                          color: RecTheme.textSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final sz = Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );
                            return GestureDetector(
                              key: const Key('anatomy_front_canvas'),
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (d) =>
                                  _handleCanvasTap(d.localPosition, sz, true),
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  size: sz,
                                  painter: _AnatomicalFiberPainter(
                                    isFront: true,
                                    statuses: map,
                                    selectedMuscle: _selectedMuscle,
                                    showFibers: _showFiberLines,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'POSTERIOR (COSTAS)',
                        style: TextStyle(
                          color: RecTheme.textSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final sz = Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );
                            return GestureDetector(
                              key: const Key('anatomy_back_canvas'),
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (d) =>
                                  _handleCanvasTap(d.localPosition, sz, false),
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  size: sz,
                                  painter: _AnatomicalFiberPainter(
                                    isFront: false,
                                    statuses: map,
                                    selectedMuscle: _selectedMuscle,
                                    showFibers: _showFiberLines,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Barra de legenda do gradiente de desgaste (Azul -> Gradiente -> Vermelho)
          Container(
            key: const Key('muscle_wear_gradient_legend'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: RecTheme.surfaceInput,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: RecTheme.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: MuscleBody3DWidget.unworkedMuscleColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Sem treino',
                  style: TextStyle(
                    color: RecTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Menos desgaste',
                  style: TextStyle(
                    color: Color(0xFF60A5FA),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: const LinearGradient(
                        colors: [
                          MuscleBody3DWidget.lowWearBlueColor,
                          Color(0xFF6366F1),
                          Color(0xFFE13D52),
                          MuscleBody3DWidget.highWearRedColor,
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Mais desgaste',
                  style: TextStyle(
                    color: Color(0xFFF87171),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Seletor horizontal das 19 subdivisões anatômicas sincronizado com a cor de desgaste
          SingleChildScrollView(
            key: const Key('muscle_chips_horizontal_scroll'),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MuscleGroup.values.map((group) {
                final st = map[group];
                final sets = st?.weeklySetsCompleted ?? 0;
                final wearPct = st?.wearPercent ?? 0;
                final isSelected = _selectedMuscle == group;
                final active = sets > 0 || wearPct > 0;
                final wearColor = MuscleBody3DWidget.statusWearColor(st);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    key: Key('muscle_chip_${group.name}'),
                    onTap: () {
                      setState(() {
                        _selectedMuscle = isSelected ? null : group;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? wearColor.withValues(alpha: 0.24)
                            : (active
                                  ? wearColor.withValues(alpha: 0.11)
                                  : RecTheme.surfaceInput),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? wearColor
                              : (active
                                    ? wearColor.withValues(alpha: 0.50)
                                    : RecTheme.borderSubtle),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active ? wearColor : RecTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${group.shortLabel} · ${sets}s',
                            style: TextStyle(
                              color: active
                                  ? RecTheme.textPrimary
                                  : RecTheme.textSecondary,
                              fontSize: 10.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
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
          if (selected != null) ...[
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final accentColor = MuscleBody3DWidget.statusWearColor(
                  selected,
                );
                return Container(
                  key: const Key('muscle_fiber_inspection_card'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RecTheme.surfaceInput,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${selected.group.label} (${selected.group.macroGroup} · ${selected.group.isFrontBody ? "Anterior" : "Posterior"})',
                              style: const TextStyle(
                                color: RecTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            '${selected.weeklySetsCompleted} séries · ${selected.wearPercent}% desgaste · ${selected.recoveryPercent}% rec.',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fibras trabalhadas: ${selected.group.fiberDirectionDescription}',
                        style: const TextStyle(
                          color: RecTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Último estímulo há ${selected.hoursSinceLastTrained}h · Constante fisiológica τ = ${selected.group.recoveryTauHours.toStringAsFixed(0)}h',
                        style: const TextStyle(
                          color: RecTheme.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Miniatura anatômica (ícone/logo) de um grupamento muscular específico,
/// inspirada no modelo de referência da seção "Recuperação muscular":
/// - Exibe o tronco superior (para músculos superiores) ou o quadril/membros
///   inferiores (para músculos de pernas e glúteos), na vista frontal ou dorsal;
/// - Corpo anatômico esculpido em prata/branco com sulcos escuros e APENAS
///   o grupamento muscular correspondente destacado em vermelho vibrante.
class MuscleGroupLogoWidget extends StatelessWidget {
  final MuscleGroup group;
  final List<MuscleGroup>? highlightedGroups;
  final double width;
  final double height;

  const MuscleGroupLogoWidget({
    super.key,
    required this.group,
    this.highlightedGroups,
    this.width = 66,
    this.height = 78,
  });

  static bool isLowerBodyGroup(MuscleGroup group) {
    return switch (group) {
      MuscleGroup.quadriceps ||
      MuscleGroup.adutores ||
      MuscleGroup.gluteoMaximo ||
      MuscleGroup.gluteoMedio ||
      MuscleGroup.posteriores ||
      MuscleGroup.panturrilhas => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          size: Size(width, height),
          painter: _MuscleGroupMiniLogoPainter(
            group: group,
            highlightedGroups: highlightedGroups,
          ),
        ),
      ),
    );
  }
}

class _MuscleGroupMiniLogoPainter extends CustomPainter {
  final MuscleGroup group;
  final List<MuscleGroup>? highlightedGroups;

  _MuscleGroupMiniLogoPainter({required this.group, this.highlightedGroups});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final lowerBody = MuscleGroupLogoWidget.isLowerBodyGroup(group);
    // Janela de enquadramento no espaço canônico (200 x 420) do modelo anatômico:
    // - Músculos superiores (y: 6..226, ny: 0.014..0.538): inclui cabeça inteira até a base dos punhos cerrados (ny=0.530) e pelve
    // - Músculos inferiores (y: 140..380, ny: 0.333..0.905): inclui cintura/antebraços/mãos laterais até o tornozelo (antes da projeção dos pés em ny=0.905)
    const cropLeft = 20.0;
    const cropWidth = 160.0;
    final cropTop = lowerBody ? 140.0 : 6.0;
    final cropHeight = lowerBody ? 240.0 : 220.0;

    final scale = math.min(
      size.width / cropWidth,
      size.height / cropHeight,
    );
    final dx = (size.width - cropWidth * scale) * 0.5 - cropLeft * scale;
    final dy = (size.height - cropHeight * scale) * 0.5 - cropTop * scale;

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final activeGroups = highlightedGroups != null && highlightedGroups!.isNotEmpty
        ? highlightedGroups!
        : [group];

    final delegate = _AnatomicalFiberPainter(
      isFront: group.isFrontBody,
      statuses: {
        for (final g in activeGroups)
          g: MuscleRecoveryStatus(
            group: g,
            recoveryPercent: 0,
            weeklySetsCompleted: 12,
            hoursSinceLastTrained: 1,
          ),
      },
      selectedMuscle: null,
      showFibers: false,
    );
    delegate.paint(canvas, const Size(200.0, 420.0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MuscleGroupMiniLogoPainter oldDelegate) {
    return oldDelegate.group != group ||
        oldDelegate.highlightedGroups != highlightedGroups;
  }
}

/// Gráfico de Radar (Teia Poligonal) de Volume Muscular (Semana / Mês)
/// conforme o modelo de referência da aba "You":
/// - Título dinâmico ("Esta semana" / "Este mês") e subtítulo "Identifique áreas que precisam de mais foco"
/// - Alternância entre SEMANA e MÊS analisando o VOLUME real (séries + kg levantados)
/// - 11 logos anatômicos posicionados ao redor dos vértices da teia poligonal
/// - Polígono azul translúcido proporcional ao volume trabalhado em cada grupamento
/// - Botão "Veja onde focar mais" abrindo a visão detalhada de distribuição de volume
class MuscleVolumeRadarChartWidget extends StatefulWidget {
  final List<CompletedWorkoutSession> sessions;
  final DateTime? referenceDate;

  const MuscleVolumeRadarChartWidget({
    super.key,
    required this.sessions,
    this.referenceDate,
  });

  @override
  State<MuscleVolumeRadarChartWidget> createState() =>
      _MuscleVolumeRadarChartWidgetState();
}

class _MuscleVolumeRadarChartWidgetState
    extends State<MuscleVolumeRadarChartWidget> {
  MuscleVolumePeriod _period = MuscleVolumePeriod.week;
  String? _selectedAxisId;

  @override
  Widget build(BuildContext context) {
    final axes = RecoveryCalculator.computeMuscleVolumeRadar(
      widget.sessions,
      period: _period,
      referenceDate: widget.referenceDate,
    );

    final selectedAxis = _selectedAxisId != null
        ? axes.cast<MuscleVolumeAxisMetric?>().firstWhere(
            (a) => a?.axisId == _selectedAxisId,
            orElse: () => null,
          )
        : null;

    final totalPeriodSets = axes.fold<int>(0, (s, a) => s + a.totalSets);
    final totalPeriodKg = axes.fold<int>(0, (s, a) => s + a.totalVolumeKg);

    return Container(
      key: const Key('muscle_volume_radar_card'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _period.heading,
                      key: const Key('volume_radar_title'),
                      style: const TextStyle(
                        color: RecTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Identifique áreas que precisam de mais foco',
                      style: TextStyle(
                        color: RecTheme.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: RecTheme.surfaceInput,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: RecTheme.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _periodButton(
                      key: const Key('volume_radar_period_week'),
                      label: MuscleVolumePeriod.week.shortLabel,
                      selected: _period == MuscleVolumePeriod.week,
                      onTap: () => setState(
                        () => _period = MuscleVolumePeriod.week,
                      ),
                    ),
                    _periodButton(
                      key: const Key('volume_radar_period_month'),
                      label: MuscleVolumePeriod.month.shortLabel,
                      selected: _period == MuscleVolumePeriod.month,
                      onTap: () => setState(
                        () => _period = MuscleVolumePeriod.month,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Palco com fundo nativo do aplicativo e os 11 logos anatômicos nos vértices
          Container(
            key: const Key('volume_radar_stage'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            color: Colors.transparent,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stageSize = math
                    .min(constraints.maxWidth, 340.0)
                    .clamp(250.0, 340.0);
                final center = Offset(stageSize * 0.5, stageSize * 0.5);
                final radarRadius = stageSize * 0.285;
                final iconOrbitRadius = stageSize * 0.405;
                const iconW = 42.0;
                const iconH = 50.0;

                return Center(
                  child: SizedBox(
                    width: stageSize,
                    height: stageSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: _MuscleRadarSpiderPainter(
                                axes: axes,
                                radarRadius: radarRadius,
                                selectedAxisId: _selectedAxisId,
                              ),
                            ),
                          ),
                        ),
                        for (int i = 0; i < axes.length; i++)
                          Builder(
                            builder: (context) {
                              final axis = axes[i];
                              final angle =
                                  -math.pi / 2 + (i * 2 * math.pi / axes.length);
                              final ix =
                                  center.dx +
                                  iconOrbitRadius * math.cos(angle) -
                                  iconW * 0.5;
                              final iy =
                                  center.dy +
                                  iconOrbitRadius * math.sin(angle) -
                                  iconH * 0.5;
                              final isSelected = _selectedAxisId == axis.axisId;

                              return Positioned(
                                left: ix,
                                top: iy,
                                child: GestureDetector(
                                  key: Key('volume_radar_vertex_${axis.axisId}'),
                                  onTap: () => setState(() {
                                    _selectedAxisId = isSelected
                                        ? null
                                        : axis.axisId;
                                  }),
                                  child: Tooltip(
                                    message:
                                        '${axis.label}: ${axis.totalSets} séries · ${axis.totalVolumeKg} kg',
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      width: iconW,
                                      height: iconH,
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF38BDF8)
                                                  .withValues(alpha: 0.16)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: isSelected
                                            ? Border.all(
                                                color: const Color(0xFF38BDF8),
                                                width: 1.2,
                                              )
                                            : null,
                                      ),
                                      child: MuscleGroupLogoWidget(
                                        group: axis.primaryLogoGroup,
                                        highlightedGroups: axis.groups,
                                        width: iconW - 4,
                                        height: iconH - 4,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedAxis != null) ...[
            const SizedBox(height: 10),
            Container(
              key: const Key('volume_radar_selected_axis_card'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RecTheme.surfaceInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  MuscleGroupLogoWidget(
                    group: selectedAxis.primaryLogoGroup,
                    highlightedGroups: selectedAxis.groups,
                    width: 40,
                    height: 48,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedAxis.label} (${_period.heading})',
                          style: const TextStyle(
                            color: RecTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${selectedAxis.totalSets} séries efetivas · ${selectedAxis.totalVolumeKg} kg de volume total',
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Volume acumulado (${_period.shortLabel}): $totalPeriodSets séries efetivas · $totalPeriodKg kg · Toque em um ícone para detalhar',
              style: const TextStyle(
                color: RecTheme.textMuted,
                fontSize: 10.5,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('volume_radar_focus_button'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MuscleVolumeFocusScreen(
                      sessions: widget.sessions,
                      initialPeriod: _period,
                      referenceDate: widget.referenceDate,
                    ),
                  ),
                );
              },
              child: const Text(
                'Veja onde focar mais',
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
  }

  Widget _periodButton({
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : RecTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MuscleRadarSpiderPainter extends CustomPainter {
  final List<MuscleVolumeAxisMetric> axes;
  final double radarRadius;
  final String? selectedAxisId;

  _MuscleRadarSpiderPainter({
    required this.axes,
    required this.radarRadius,
    required this.selectedAxisId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty || size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final n = axes.length;

    Offset vertexAt(int index, double r) {
      final angle = -math.pi / 2 + (index * 2 * math.pi / n);
      return Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
    }

    // 1. Anéis concêntricos da teia (4 níveis: 25%, 50%, 75%, 100%)
    final gridPaint = Paint()
      ..color = const Color(0xFF2E2E35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    for (final level in [0.25, 0.50, 0.75, 1.0]) {
      final ringPath = Path();
      final r = radarRadius * level;
      for (int i = 0; i < n; i++) {
        final p = vertexAt(i, r);
        if (i == 0) {
          ringPath.moveTo(p.dx, p.dy);
        } else {
          ringPath.lineTo(p.dx, p.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // 2. Raios do centro até os vértices externos
    for (int i = 0; i < n; i++) {
      final outer = vertexAt(i, radarRadius);
      final isHighlighted = axes[i].axisId == selectedAxisId;
      canvas.drawLine(
        center,
        outer,
        Paint()
          ..color = isHighlighted
              ? const Color(0xFF38BDF8).withValues(alpha: 0.75)
              : const Color(0xFF2E2E35)
          ..strokeWidth = isHighlighted ? 1.4 : 0.9,
      );
    }

    // 3. Polígono de Volume Muscular em Azul (Preenchimento translúcido + contorno celeste)
    final hasAnyVolume = axes.any((a) => a.normalizedVolume > 0);
    if (!hasAnyVolume) return;

    final dataPath = Path();
    final points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final p = vertexAt(i, radarRadius * axes[i].normalizedVolume);
      points.add(p);
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();

    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0EA5E9).withValues(alpha: 0.24),
          const Color(0xFF1D4ED8).withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radarRadius));
    canvas.drawPath(dataPath, fillPaint);

    final strokePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(dataPath, strokePaint);

    final dotPaint = Paint()..color = const Color(0xFF7DD3FC);
    for (int i = 0; i < n; i++) {
      if (axes[i].totalSets > 0) {
        canvas.drawCircle(points[i], 2.6, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MuscleRadarSpiderPainter oldDelegate) {
    return oldDelegate.axes != axes ||
        oldDelegate.radarRadius != radarRadius ||
        oldDelegate.selectedAxisId != selectedAxisId;
  }
}

/// Tela de detalhamento ao tocar em "Veja onde focar mais" no Gráfico de Radar.
class MuscleVolumeFocusScreen extends StatefulWidget {
  final List<CompletedWorkoutSession> sessions;
  final MuscleVolumePeriod initialPeriod;
  final DateTime? referenceDate;

  const MuscleVolumeFocusScreen({
    super.key,
    required this.sessions,
    this.initialPeriod = MuscleVolumePeriod.week,
    this.referenceDate,
  });

  @override
  State<MuscleVolumeFocusScreen> createState() =>
      _MuscleVolumeFocusScreenState();
}

class _MuscleVolumeFocusScreenState extends State<MuscleVolumeFocusScreen> {
  late MuscleVolumePeriod _period;

  @override
  void initState() {
    super.initState();
    _period = widget.initialPeriod;
  }

  @override
  Widget build(BuildContext context) {
    final axes = RecoveryCalculator.computeMuscleVolumeRadar(
      widget.sessions,
      period: _period,
      referenceDate: widget.referenceDate,
    );
    final sortedByLeastWorked = List<MuscleVolumeAxisMetric>.from(axes)
      ..sort((a, b) => a.totalSets.compareTo(b.totalSets));
    final maxSets = axes.fold<int>(
      1,
      (m, a) => a.totalSets > m ? a.totalSets : m,
    );
    final needFocusList = sortedByLeastWorked.take(4).toList();

    return Scaffold(
      key: const Key('muscle_volume_focus_screen'),
      backgroundColor: RecTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: RecTheme.cardBackground,
        foregroundColor: RecTheme.textPrimary,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição de Volume Muscular',
              style: TextStyle(
                color: RecTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Identifique áreas que precisam de mais foco',
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
          Row(
            children: MuscleVolumePeriod.values.map((p) {
              final selected = _period == p;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: Key('focus_screen_period_${p.name}'),
                  label: Text(p.heading),
                  selected: selected,
                  selectedColor: const Color(0xFF2563EB),
                  onSelected: (_) => setState(() => _period = p),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: RecTheme.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Áreas com Menor Volume (${_period.heading})',
                  style: const TextStyle(
                    color: RecTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Priorizar: ${needFocusList.map((e) => '${e.label} (${e.totalSets}s)').join(' · ')}',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...sortedByLeastWorked.reversed.map((axis) {
            final ratio = (axis.totalSets / maxSets).clamp(0.0, 1.0);
            return Container(
              key: Key('focus_axis_row_${axis.axisId}'),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RecTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RecTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  MuscleGroupLogoWidget(
                    group: axis.primaryLogoGroup,
                    highlightedGroups: axis.groups,
                    width: 46,
                    height: 56,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              axis.label,
                              style: const TextStyle(
                                color: RecTheme.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${axis.totalSets} séries · ${axis.totalVolumeKg} kg',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 7,
                            backgroundColor: RecTheme.surfaceInput,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF38BDF8),
                            ),
                          ),
                        ),
                      ],
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
}

class _MuscleShadingPalette {
  final Color highlight;
  final Color midLight;
  final Color base;
  final Color shadow;
  final Color deepGroove;
  final bool worked;

  const _MuscleShadingPalette({
    required this.highlight,
    required this.midLight,
    required this.base,
    required this.shadow,
    required this.deepGroove,
    required this.worked,
  });

  factory _MuscleShadingPalette.forStatus(MuscleRecoveryStatus? status) {
    final worked =
        status != null && (status.workedThisWeek || status.wearPercent > 0);
    if (!worked) {
      // Escala de cinza/prata 3D anatômica de alto contraste (idêntica à 1ª imagem)
      return const _MuscleShadingPalette(
        highlight: Color(0xFFE4E4E7),
        midLight: Color(0xFFB8B8C2),
        base: Color(0xFF8A8A96),
        shadow: Color(0xFF3F3F48),
        deepGroove: Color(0xFF141418),
        worked: false,
      );
    }

    final core = MuscleBody3DWidget.colorForWear(
      status.wearNormalized,
      isWorked: true,
    );
    return _MuscleShadingPalette(
      highlight: Color.lerp(core, Colors.white, 0.42)!,
      midLight: Color.lerp(core, Colors.white, 0.16)!,
      base: core,
      shadow: Color.lerp(core, Colors.black, 0.46)!,
      deepGroove: Color.lerp(core, Colors.black, 0.74)!,
      worked: true,
    );
  }
}

class _AnatomicalFiberPainter extends CustomPainter {
  final bool isFront;
  final Map<MuscleGroup, MuscleRecoveryStatus> statuses;
  final MuscleGroup? selectedMuscle;
  final bool showFibers;

  static const double _canonWidth = 200.0;
  static const double _canonHeight = 420.0;

  _AnatomicalFiberPainter({
    required this.isFront,
    required this.statuses,
    required this.selectedMuscle,
    required this.showFibers,
  });

  _MuscleShadingPalette _paletteFor(MuscleGroup group) {
    return _MuscleShadingPalette.forStatus(statuses[group]);
  }

  /// Constrói um contorno suave fechado passando pelos pontos de controle anatômicos.
  Path _smoothPoly(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    final n = pts.length;
    if (n < 3) {
      path.addPolygon(pts, true);
      return path;
    }
    final firstMid = Offset(
      (pts.last.dx + pts.first.dx) * 0.5,
      (pts.last.dy + pts.first.dy) * 0.5,
    );
    path.moveTo(firstMid.dx, firstMid.dy);
    for (int i = 0; i < n; i++) {
      final curr = pts[i];
      final next = pts[(i + 1) % n];
      final mid = Offset(
        (curr.dx + next.dx) * 0.5,
        (curr.dy + next.dy) * 0.5,
      );
      path.quadraticBezierTo(curr.dx, curr.dy, mid.dx, mid.dy);
    }
    path.close();
    return path;
  }

  /// Renderiza um ventre muscular esculpido em 3D com:
  /// 1. Sombra de base volumétrica;
  /// 2. Iluminação especular central cilíndrica/radial simulando o relevo 3D;
  /// 3. Feixes finos de estrias anatômicas orgânicas recortadas no contorno;
  /// 4. Sulco anatômico escuro entre os ventres musculares.
  void _drawSculptedMuscleBelly(
    Canvas canvas,
    Path path,
    MuscleGroup group, {
    required double fiberAngleRad,
    int fiberCount = 11,
    bool fanFibers = false,
    Offset? fanOrigin,
    Alignment highlightCenter = Alignment.center,
  }) {
    final bounds = path.getBounds();
    if (bounds.isEmpty) return;

    final palette = _paletteFor(group);
    final isSelected = selectedMuscle == group;

    if (isSelected) {
      final glowPaint = Paint()
        ..color = palette.base.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glowPaint);
    }

    // 1. Camada base 3D (bordas sombreadas -> centro iluminado)
    final basePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          palette.shadow,
          palette.base,
          palette.midLight,
          palette.base,
          palette.shadow,
        ],
        stops: const [0.0, 0.22, 0.52, 0.78, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds);
    canvas.drawPath(path, basePaint);

    // 2. Volume 3D e estrias anatômicas internas recortadas
    canvas.save();
    canvas.clipPath(path);

    final radialPaint = Paint()
      ..shader = RadialGradient(
        center: highlightCenter,
        radius: 0.72,
        colors: [
          palette.highlight.withValues(alpha: palette.worked ? 0.52 : 0.46),
          palette.midLight.withValues(alpha: 0.20),
          Colors.black.withValues(alpha: 0.28),
        ],
        stops: const [0.0, 0.56, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, radialPaint);

    if (showFibers) {
      final darkGroovePaint = Paint()
        ..color = palette.deepGroove.withValues(
          alpha: palette.worked ? 0.34 : 0.30,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.65
        ..strokeCap = StrokeCap.round;

      final lightSheenPaint = Paint()
        ..color = palette.highlight.withValues(
          alpha: palette.worked ? 0.24 : 0.18,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.50
        ..strokeCap = StrokeCap.round;

      final cx = bounds.center.dx;
      final cy = bounds.center.dy;
      final diag =
          math.sqrt(
            bounds.width * bounds.width + bounds.height * bounds.height,
          ) *
          0.78;

      if (fanFibers && fanOrigin != null) {
        for (int i = 0; i < fiberCount; i++) {
          final t = fiberCount <= 1 ? 0.5 : i / (fiberCount - 1);
          final targetY = bounds.top + bounds.height * (0.08 + 0.84 * t);
          final targetX = fanOrigin.dx < cx
              ? bounds.right - bounds.width * 0.04
              : bounds.left + bounds.width * 0.04;
          final ctrlX = (fanOrigin.dx + targetX) * 0.5;
          final ctrlY = (fanOrigin.dy + targetY) * 0.5 + (t - 0.5) * 3.5;

          final groovePath = Path()
            ..moveTo(fanOrigin.dx, fanOrigin.dy)
            ..quadraticBezierTo(ctrlX, ctrlY, targetX, targetY);
          canvas.drawPath(groovePath, darkGroovePaint);

          final sheenPath = Path()
            ..moveTo(fanOrigin.dx, fanOrigin.dy + 0.55)
            ..quadraticBezierTo(
              ctrlX,
              ctrlY + 0.55,
              targetX,
              targetY + 0.55,
            );
          canvas.drawPath(sheenPath, lightSheenPaint);
        }
      } else {
        final dirX = math.cos(fiberAngleRad);
        final dirY = math.sin(fiberAngleRad);
        final perpX = -dirY;
        final perpY = dirX;
        final span = math.max(bounds.width, bounds.height) * 0.92;

        for (int i = 0; i < fiberCount; i++) {
          final frac = fiberCount <= 1 ? 0.0 : (i / (fiberCount - 1)) - 0.5;
          final offsetDist = frac * span;
          final ox = cx + perpX * offsetDist;
          final oy = cy + perpY * offsetDist;

          final p1 = Offset(ox - dirX * diag, oy - dirY * diag);
          final p2 = Offset(ox + dirX * diag, oy + dirY * diag);
          final bow = math.sin(frac * math.pi) * 1.6;
          final ctrl = Offset(ox + perpX * bow, oy + perpY * bow);

          final groovePath = Path()
            ..moveTo(p1.dx, p1.dy)
            ..quadraticBezierTo(ctrl.dx, ctrl.dy, p2.dx, p2.dy);
          canvas.drawPath(groovePath, darkGroovePaint);

          final sheenPath = Path()
            ..moveTo(p1.dx + perpX * 0.5, p1.dy + perpY * 0.5)
            ..quadraticBezierTo(
              ctrl.dx + perpX * 0.5,
              ctrl.dy + perpY * 0.5,
              p2.dx + perpX * 0.5,
              p2.dy + perpY * 0.5,
            );
          canvas.drawPath(sheenPath, lightSheenPaint);
        }
      }
    }

    canvas.restore();

    // 3. Sulco anatômico (ou destaque branco caso selecionado)
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 1.45 : 0.78
      ..color = isSelected
          ? Colors.white
          : palette.deepGroove.withValues(alpha: 0.90);
    canvas.drawPath(path, borderPaint);
  }

  /// Desenha uma estrutura tendínea/aponeurótica ou anatômica neutra (cabeça, mãos,
  /// patela, fáscia toracolombar, tendão de Aquiles, pés) em escala de cinza 3D.
  void _drawTendonOrNeutralStructure(
    Canvas canvas,
    Path path, {
    Color light = const Color(0xFFDADAE2),
    Color mid = const Color(0xFF9494A0),
    Color dark = const Color(0xFF383842),
    Color border = const Color(0xFF18181D),
  }) {
    final bounds = path.getBounds();
    if (bounds.isEmpty) return;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [dark, mid, light, mid, dark],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds);
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = border.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;
    canvas.drawPath(path, borderPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final scale = math.min(
      size.width / _canonWidth,
      size.height / _canonHeight,
    );
    final figW = _canonWidth * scale;
    final figH = _canonHeight * scale;
    final left = (size.width - figW) * 0.5;
    final top = (size.height - figH) * 0.5;
    final cx = left + figW * 0.5;

    Offset pt(double sx, double ny) => Offset(cx + sx * figW, top + ny * figH);

    // Sombra elíptica sutil sob os pés no chão do estúdio escuro
    final floorShadow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(cx, top + figH * 0.968),
          width: figW * 0.72,
          height: figH * 0.04,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, top + figH * 0.968),
        width: figW * 0.72,
        height: figH * 0.032,
      ),
      floorShadow,
    );

    // 1. Silhueta contínua de fundo (conexões articulares, cabeça, pescoço, tronco, mãos, joelhos e pés)
    _drawContinuousAnatomicalBodyBase(canvas, pt, figW, figH);

    // 2. Ventres musculares das 19 subdivisões + aponeuroses
    if (isFront) {
      _paintAnteriorMuscles(canvas, pt);
    } else {
      _paintPosteriorMuscles(canvas, pt);
    }

    // 3. Detalhamento de cabeça/face, mãos, patelas, tendões e pés sobrepostos com acabamento 3D
    _drawAnatomicalExtremitiesAndLandmarks(canvas, pt, figW, figH);
  }

  void _drawContinuousAnatomicalBodyBase(
    Canvas canvas,
    Offset Function(double, double) pt,
    double figW,
    double figH,
  ) {
    // Tronco central contínuo + pelve para eliminar qualquer fresta preta entre ventres musculares
    final torsoCore = _smoothPoly([
      pt(-0.055, 0.112),
      pt(-0.185, 0.152),
      pt(-0.205, 0.235),
      pt(-0.165, 0.355),
      pt(-0.150, 0.440),
      pt(-0.185, 0.510),
      pt(-0.175, 0.720),
      pt(-0.145, 0.920),
      pt(-0.065, 0.920),
      pt(-0.045, 0.720),
      pt(-0.015, 0.535),
      pt(0.015, 0.535),
      pt(0.045, 0.720),
      pt(0.065, 0.920),
      pt(0.145, 0.920),
      pt(0.175, 0.720),
      pt(0.185, 0.510),
      pt(0.150, 0.440),
      pt(0.165, 0.355),
      pt(0.205, 0.235),
      pt(0.185, 0.152),
      pt(0.055, 0.112),
    ]);
    _drawTendonOrNeutralStructure(
      canvas,
      torsoCore,
      light: const Color(0xFFB4B4C0),
      mid: const Color(0xFF6E6E7A),
      dark: const Color(0xFF2B2B33),
    );

    // Braços contínuos (ombro -> cotovelo -> antebraço -> punho)
    for (final s in [-1.0, 1.0]) {
      final armCore = _smoothPoly([
        pt(s * 0.175, 0.158),
        pt(s * 0.275, 0.175),
        pt(s * 0.305, 0.265),
        pt(s * 0.325, 0.355),
        pt(s * 0.368, 0.475),
        pt(s * 0.312, 0.482),
        pt(s * 0.235, 0.365),
        pt(s * 0.200, 0.255),
      ]);
      _drawTendonOrNeutralStructure(
        canvas,
        armCore,
        light: const Color(0xFFAEAEB8),
        mid: const Color(0xFF686874),
        dark: const Color(0xFF27272F),
      );
    }
  }

  void _paintAnteriorMuscles(
    Canvas canvas,
    Offset Function(double, double) pt,
  ) {
    // Fáscia/Linha Alba central e bainha retal sob os gomos abdominais
    final lineaAlbaBg = _smoothPoly([
      pt(-0.088, 0.265),
      pt(0.088, 0.265),
      pt(0.072, 0.485),
      pt(0.0, 0.525),
      pt(-0.072, 0.485),
    ]);
    _drawTendonOrNeutralStructure(
      canvas,
      lineaAlbaBg,
      light: const Color(0xFFD4D4DC),
      mid: const Color(0xFF8C8C98),
      dark: const Color(0xFF3B3B45),
    );

    for (final s in [-1.0, 1.0]) {
      // 1. Trapézio Superior (porção cervical-acromial visível na frente)
      final trapFront = _smoothPoly([
        pt(s * 0.048, 0.114),
        pt(s * 0.175, 0.150),
        pt(s * 0.085, 0.158),
        pt(s * 0.045, 0.142),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        trapFront,
        MuscleGroup.trapezio,
        fiberAngleRad: s * 0.42,
        fiberCount: 7,
      );

      // 2. Oblíquos Externos & Serrátil Anterior (costelas laterais até crista ilíaca)
      for (int rib = 0; rib < 3; rib++) {
        final ry = 0.268 + rib * 0.024;
        final serratusSlip = _smoothPoly([
          pt(s * 0.115, ry),
          pt(s * 0.175, ry - 0.008),
          pt(s * 0.168, ry + 0.020),
          pt(s * 0.105, ry + 0.022),
        ]);
        _drawSculptedMuscleBelly(
          canvas,
          serratusSlip,
          MuscleGroup.obliquos,
          fiberAngleRad: s * -0.45,
          fiberCount: 5,
        );
      }

      final obliquesFlank = _smoothPoly([
        pt(s * 0.082, 0.315),
        pt(s * 0.164, 0.320),
        pt(s * 0.155, 0.442),
        pt(s * 0.112, 0.478),
        pt(s * 0.068, 0.458),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        obliquesFlank,
        MuscleGroup.obliquos,
        fiberAngleRad: math.pi / 2 - (s * 0.58),
        fiberCount: 10,
      );

      // 3. Peitoral Superior (Porção Clavicular)
      final upperChest = _smoothPoly([
        pt(s * 0.007, 0.156),
        pt(s * 0.152, 0.152),
        pt(s * 0.192, 0.198),
        pt(s * 0.095, 0.204),
        pt(s * 0.006, 0.196),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        upperChest,
        MuscleGroup.peitoralSuperior,
        fiberAngleRad: s * -0.26,
        fiberCount: 10,
        highlightCenter: Alignment(s * -0.15, -0.15),
      );

      // 4. Peitoral Maior (Porção Esternocostal em leque largo e volumoso)
      final mainChest = _smoothPoly([
        pt(s * 0.006, 0.194),
        pt(s * 0.192, 0.198),
        pt(s * 0.184, 0.262),
        pt(s * 0.125, 0.282),
        pt(s * 0.042, 0.278),
        pt(s * 0.006, 0.260),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        mainChest,
        MuscleGroup.peitoralMaior,
        fiberAngleRad: s * 0.08,
        fiberCount: 14,
        fanFibers: true,
        fanOrigin: pt(s * 0.195, 0.205),
        highlightCenter: Alignment(s * 0.1, -0.05),
      );

      // 5. Deltoide Anterior
      final frontDelt = _smoothPoly([
        pt(s * 0.148, 0.152),
        pt(s * 0.228, 0.162),
        pt(s * 0.226, 0.238),
        pt(s * 0.182, 0.222),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        frontDelt,
        MuscleGroup.deltoideAnterior,
        fiberAngleRad: math.pi / 2 - (s * 0.28),
        fiberCount: 9,
      );

      // 6. Deltoide Lateral (calota multipenada arredondada do ombro)
      final latDelt = _smoothPoly([
        pt(s * 0.208, 0.156),
        pt(s * 0.282, 0.178),
        pt(s * 0.288, 0.246),
        pt(s * 0.224, 0.238),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        latDelt,
        MuscleGroup.deltoideLateral,
        fiberAngleRad: math.pi / 2 + (s * 0.14),
        fiberCount: 10,
      );

      // 7. Bíceps Braquial (Cabeça curta medial + Cabeça longa lateral + Braquial)
      final bicepsMedial = _smoothPoly([
        pt(s * 0.192, 0.228),
        pt(s * 0.238, 0.235),
        pt(s * 0.252, 0.348),
        pt(s * 0.212, 0.346),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        bicepsMedial,
        MuscleGroup.biceps,
        fiberAngleRad: math.pi / 2 - (s * 0.12),
        fiberCount: 8,
      );

      final bicepsLateral = _smoothPoly([
        pt(s * 0.234, 0.235),
        pt(s * 0.286, 0.245),
        pt(s * 0.302, 0.348),
        pt(s * 0.250, 0.348),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        bicepsLateral,
        MuscleGroup.biceps,
        fiberAngleRad: math.pi / 2 - (s * 0.14),
        fiberCount: 8,
      );

      // 8. Antebraço Anterior (Braquiorradial lateral + Flexores mediais)
      final brachioradialis = _smoothPoly([
        pt(s * 0.258, 0.340),
        pt(s * 0.322, 0.352),
        pt(s * 0.365, 0.472),
        pt(s * 0.330, 0.476),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        brachioradialis,
        MuscleGroup.antebraco,
        fiberAngleRad: math.pi / 2 - (s * 0.26),
        fiberCount: 9,
      );

      final forearmFlexors = _smoothPoly([
        pt(s * 0.218, 0.346),
        pt(s * 0.264, 0.346),
        pt(s * 0.332, 0.476),
        pt(s * 0.304, 0.480),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        forearmFlexors,
        MuscleGroup.antebraco,
        fiberAngleRad: math.pi / 2 - (s * 0.28),
        fiberCount: 8,
      );

      // 9. Reto Abdominal (8-pack anatômico com intersecções tendíneas reais)
      final absRows = [
        (0.270, 0.312, 0.074),
        (0.317, 0.360, 0.078),
        (0.365, 0.410, 0.074),
        (0.415, 0.482, 0.062),
      ];
      for (final (topY, botY, widthX) in absRows) {
        final absBelly = _smoothPoly([
          pt(s * 0.008, topY),
          pt(s * widthX, topY + 0.004),
          pt(s * (widthX - 0.006), botY),
          pt(s * 0.008, botY),
        ]);
        _drawSculptedMuscleBelly(
          canvas,
          absBelly,
          MuscleGroup.retoAbdominal,
          fiberAngleRad: math.pi / 2,
          fiberCount: 7,
        );
      }

      // 10. Adutores da Coxa + Sartório (faixa diagonal interna da coxa)
      final adductorsInner = _smoothPoly([
        pt(s * 0.014, 0.485),
        pt(s * 0.088, 0.475),
        pt(s * 0.072, 0.635),
        pt(s * 0.032, 0.610),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        adductorsInner,
        MuscleGroup.adutores,
        fiberAngleRad: math.pi / 2 + (s * 0.34),
        fiberCount: 9,
      );

      final sartoriusRibbon = _smoothPoly([
        pt(s * 0.148, 0.448),
        pt(s * 0.165, 0.462),
        pt(s * 0.068, 0.695),
        pt(s * 0.048, 0.682),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        sartoriusRibbon,
        MuscleGroup.adutores,
        fiberAngleRad: math.pi / 2 + (s * 0.40),
        fiberCount: 6,
      );

      // 11. Quadríceps (Vasto Lateral, Reto Femoral bipenado e Vasto Medial em gota/VMO)
      final vastusLateralis = _smoothPoly([
        pt(s * 0.135, 0.462),
        pt(s * 0.198, 0.505),
        pt(s * 0.205, 0.605),
        pt(s * 0.172, 0.690),
        pt(s * 0.128, 0.675),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        vastusLateralis,
        MuscleGroup.quadriceps,
        fiberAngleRad: math.pi / 2 - (s * 0.34),
        fiberCount: 12,
      );

      final rectusFemoris = _smoothPoly([
        pt(s * 0.088, 0.462),
        pt(s * 0.145, 0.468),
        pt(s * 0.140, 0.682),
        pt(s * 0.095, 0.682),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        rectusFemoris,
        MuscleGroup.quadriceps,
        fiberAngleRad: math.pi / 2 + (s * 0.18),
        fiberCount: 12,
      );

      final vastusMedialisVmo = _smoothPoly([
        pt(s * 0.068, 0.585),
        pt(s * 0.105, 0.595),
        pt(s * 0.102, 0.695),
        pt(s * 0.052, 0.688),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        vastusMedialisVmo,
        MuscleGroup.quadriceps,
        fiberAngleRad: math.pi / 2 + (s * 0.46),
        fiberCount: 8,
      );

      // 12. Panturrilhas na Vista Anterior (Gastrocnêmio Medial, Tibial Anterior e Fibular)
      final calfMedialFront = _smoothPoly([
        pt(s * 0.055, 0.742),
        pt(s * 0.095, 0.745),
        pt(s * 0.088, 0.875),
        pt(s * 0.058, 0.855),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        calfMedialFront,
        MuscleGroup.panturrilhas,
        fiberAngleRad: math.pi / 2 + (s * 0.20),
        fiberCount: 8,
      );

      final tibialisAnterior = _smoothPoly([
        pt(s * 0.095, 0.738),
        pt(s * 0.142, 0.742),
        pt(s * 0.132, 0.905),
        pt(s * 0.092, 0.902),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        tibialisAnterior,
        MuscleGroup.panturrilhas,
        fiberAngleRad: math.pi / 2 - (s * 0.12),
        fiberCount: 9,
      );

      final calfLateralFront = _smoothPoly([
        pt(s * 0.138, 0.745),
        pt(s * 0.178, 0.768),
        pt(s * 0.155, 0.885),
        pt(s * 0.130, 0.885),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        calfLateralFront,
        MuscleGroup.panturrilhas,
        fiberAngleRad: math.pi / 2 - (s * 0.22),
        fiberCount: 7,
      );
    }
  }

  void _paintPosteriorMuscles(
    Canvas canvas,
    Offset Function(double, double) pt,
  ) {
    // Aponeurose / Fáscia Toracolombar prateada (diamante branco/prata característico da 1ª imagem)
    final thoracolumbarFascia = _smoothPoly([
      pt(0.0, 0.295),
      pt(-0.088, 0.378),
      pt(-0.055, 0.455),
      pt(0.0, 0.478),
      pt(0.055, 0.455),
      pt(0.088, 0.378),
    ]);
    _drawTendonOrNeutralStructure(
      canvas,
      thoracolumbarFascia,
      light: const Color(0xFFEAEAF0),
      mid: const Color(0xFFB4B4C0),
      dark: const Color(0xFF686874),
    );

    for (final s in [-1.0, 1.0]) {
      // 1. Lombar / Eretores da Espinha (colunas paravertebrais na base toracolombar)
      final lumbarColumn = _smoothPoly([
        pt(s * 0.008, 0.348),
        pt(s * 0.092, 0.365),
        pt(s * 0.086, 0.448),
        pt(s * 0.008, 0.455),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        lumbarColumn,
        MuscleGroup.lombar,
        fiberAngleRad: math.pi / 2,
        fiberCount: 8,
      );

      // 2. Dorsal / Latíssimo do Dorso + Redondo Maior/Infraespinhal
      final teresInfra = _smoothPoly([
        pt(s * 0.105, 0.195),
        pt(s * 0.195, 0.212),
        pt(s * 0.198, 0.252),
        pt(s * 0.105, 0.238),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        teresInfra,
        MuscleGroup.dorsal,
        fiberAngleRad: s * -0.25,
        fiberCount: 8,
      );

      final latsWing = _smoothPoly([
        pt(s * 0.012, 0.275),
        pt(s * 0.115, 0.232),
        pt(s * 0.202, 0.248),
        pt(s * 0.180, 0.348),
        pt(s * 0.145, 0.412),
        pt(s * 0.068, 0.388),
        pt(s * 0.012, 0.335),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        latsWing,
        MuscleGroup.dorsal,
        fiberAngleRad: s * -0.58,
        fiberCount: 15,
        fanFibers: true,
        fanOrigin: pt(s * 0.198, 0.242),
        highlightCenter: Alignment(s * 0.2, -0.1),
      );

      // 3. Trapézio (Porções Superior, Média e Inferior formando o capuz/diamante dorsal)
      final trapHood = _smoothPoly([
        pt(s * 0.005, 0.112),
        pt(s * 0.065, 0.132),
        pt(s * 0.178, 0.152),
        pt(s * 0.132, 0.198),
        pt(s * 0.108, 0.242),
        pt(s * 0.005, 0.312),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        trapHood,
        MuscleGroup.trapezio,
        fiberAngleRad: s * 0.32,
        fiberCount: 14,
        fanFibers: true,
        fanOrigin: pt(s * 0.165, 0.158),
      );

      // 4. Deltoide Posterior
      final rearDelt = _smoothPoly([
        pt(s * 0.132, 0.154),
        pt(s * 0.276, 0.176),
        pt(s * 0.278, 0.238),
        pt(s * 0.182, 0.222),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        rearDelt,
        MuscleGroup.deltoidePosterior,
        fiberAngleRad: s * 0.45,
        fiberCount: 10,
      );

      // 5. Tríceps Braquial (Cabeça Longa medial e Cabeça Lateral em ferradura)
      final tricepsLongHead = _smoothPoly([
        pt(s * 0.195, 0.228),
        pt(s * 0.242, 0.235),
        pt(s * 0.252, 0.345),
        pt(s * 0.210, 0.342),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        tricepsLongHead,
        MuscleGroup.triceps,
        fiberAngleRad: math.pi / 2 + (s * 0.14),
        fiberCount: 9,
      );

      final tricepsLateralHead = _smoothPoly([
        pt(s * 0.240, 0.232),
        pt(s * 0.288, 0.242),
        pt(s * 0.304, 0.338),
        pt(s * 0.254, 0.342),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        tricepsLateralHead,
        MuscleGroup.triceps,
        fiberAngleRad: math.pi / 2 - (s * 0.24),
        fiberCount: 9,
      );

      // 6. Antebraço Posterior (Extensores + Braquiorradial)
      final forearmExtensors = _smoothPoly([
        pt(s * 0.222, 0.345),
        pt(s * 0.320, 0.348),
        pt(s * 0.365, 0.474),
        pt(s * 0.305, 0.480),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        forearmExtensors,
        MuscleGroup.antebraco,
        fiberAngleRad: math.pi / 2 - (s * 0.24),
        fiberCount: 10,
      );

      // 7. Glúteo Médio (leque superior lateral do quadril)
      final gluteMed = _smoothPoly([
        pt(s * 0.072, 0.435),
        pt(s * 0.168, 0.442),
        pt(s * 0.184, 0.495),
        pt(s * 0.088, 0.476),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        gluteMed,
        MuscleGroup.gluteoMedio,
        fiberAngleRad: s * 0.35,
        fiberCount: 8,
      );

      // 8. Glúteo Máximo (ventre volumoso arredondado sacro-femoral)
      final gluteMax = _smoothPoly([
        pt(s * 0.006, 0.458),
        pt(s * 0.095, 0.468),
        pt(s * 0.184, 0.492),
        pt(s * 0.188, 0.568),
        pt(s * 0.095, 0.582),
        pt(s * 0.006, 0.558),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        gluteMax,
        MuscleGroup.gluteoMaximo,
        fiberAngleRad: s * 0.50,
        fiberCount: 13,
        highlightCenter: Alignment(s * 0.1, 0.05),
      );

      // 9. Posteriores de Coxa (Bíceps Femoral lateral e Semitendíneo/Semimembranoso medial)
      final semitendinosus = _smoothPoly([
        pt(s * 0.042, 0.576),
        pt(s * 0.112, 0.578),
        pt(s * 0.105, 0.715),
        pt(s * 0.048, 0.710),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        semitendinosus,
        MuscleGroup.posteriores,
        fiberAngleRad: math.pi / 2 + (s * 0.14),
        fiberCount: 10,
      );

      final bicepsFemoris = _smoothPoly([
        pt(s * 0.110, 0.574),
        pt(s * 0.185, 0.568),
        pt(s * 0.172, 0.715),
        pt(s * 0.104, 0.715),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        bicepsFemoris,
        MuscleGroup.posteriores,
        fiberAngleRad: math.pi / 2 - (s * 0.18),
        fiberCount: 10,
      );

      // 10. Panturrilhas Posteriores (Gastrocnêmio Medial, Lateral e Sóleo)
      final gastrocMedial = _smoothPoly([
        pt(s * 0.045, 0.728),
        pt(s * 0.108, 0.728),
        pt(s * 0.104, 0.848),
        pt(s * 0.052, 0.838),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        gastrocMedial,
        MuscleGroup.panturrilhas,
        fiberAngleRad: math.pi / 2 + (s * 0.24),
        fiberCount: 9,
      );

      final gastrocLateral = _smoothPoly([
        pt(s * 0.106, 0.728),
        pt(s * 0.172, 0.735),
        pt(s * 0.158, 0.842),
        pt(s * 0.104, 0.845),
      ]);
      _drawSculptedMuscleBelly(
        canvas,
        gastrocLateral,
        MuscleGroup.panturrilhas,
        fiberAngleRad: math.pi / 2 - (s * 0.24),
        fiberCount: 9,
      );

      // Tendão de Aquiles prateado descendo até o calcâneo
      final achillesTendon = _smoothPoly([
        pt(s * 0.072, 0.838),
        pt(s * 0.135, 0.838),
        pt(s * 0.118, 0.945),
        pt(s * 0.085, 0.945),
      ]);
      _drawTendonOrNeutralStructure(
        canvas,
        achillesTendon,
        light: const Color(0xFFE4E4EC),
        mid: const Color(0xFFA0A0AC),
        dark: const Color(0xFF484852),
      );
    }

    // Sulco vertebral central percorrendo o trapézio e a coluna torácica/lombar
    final spineGroovePaint = Paint()
      ..color = const Color(0xFF18181F).withValues(alpha: 0.75)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pt(0.0, 0.115), pt(0.0, 0.475), spineGroovePaint);
  }

  void _drawAnatomicalExtremitiesAndLandmarks(
    Canvas canvas,
    Offset Function(double, double) pt,
    double figW,
    double figH,
  ) {
    // 1. Pescoço com Esternocleidomastoideo (Frente) ou Nuca (Costas)
    final neckPath = _smoothPoly([
      pt(-0.048, 0.102),
      pt(0.048, 0.102),
      pt(0.056, 0.152),
      pt(-0.056, 0.152),
    ]);
    _drawTendonOrNeutralStructure(
      canvas,
      neckPath,
      light: const Color(0xFFD4D4DC),
      mid: const Color(0xFF8E8E9A),
      dark: const Color(0xFF3A3A44),
    );

    if (isFront) {
      // Feixes do Esternocleidomastoideo convergindo para a fúrcula esternal
      final scmPaint = Paint()
        ..color = const Color(0xFF272730).withValues(alpha: 0.75)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(pt(-0.042, 0.108), pt(-0.008, 0.152), scmPaint);
      canvas.drawLine(pt(0.042, 0.108), pt(0.008, 0.152), scmPaint);
    }

    // 2. Cabeça anatômica esculpida em 3D (crânio, mandíbula, orelhas e feições)
    for (final s in [-1.0, 1.0]) {
      final earRect = Rect.fromCenter(
        center: pt(s * 0.068, 0.072),
        width: figW * 0.022,
        height: figH * 0.026,
      );
      canvas.drawOval(
        earRect,
        Paint()..color = const Color(0xFF787884),
      );
    }

    final headPath = _smoothPoly([
      pt(0.0, 0.020),
      pt(-0.058, 0.028),
      pt(-0.066, 0.062),
      pt(-0.056, 0.095),
      pt(-0.032, 0.114),
      pt(0.0, 0.118),
      pt(0.032, 0.114),
      pt(0.056, 0.095),
      pt(0.066, 0.062),
      pt(0.058, 0.028),
    ]);
    final headBounds = headPath.getBounds();
    final headFill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.15, -0.25),
        radius: 0.85,
        colors: const [
          Color(0xFFE4E4EC),
          Color(0xFFA8A8B4),
          Color(0xFF4C4C56),
          Color(0xFF222228),
        ],
        stops: const [0.0, 0.45, 0.82, 1.0],
      ).createShader(headBounds);
    canvas.drawPath(headPath, headFill);
    canvas.drawPath(
      headPath,
      Paint()
        ..color = const Color(0xFF18181D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    if (isFront) {
      // Feições faciais anatômicas sutis em escala de cinza 3D (como na 1ª imagem)
      final featureDark = Paint()
        ..color = const Color(0xFF2D2D35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round;

      // Linha capilar / têmporas sutis
      final hairline = _smoothPoly([
        pt(0.0, 0.020),
        pt(-0.056, 0.028),
        pt(-0.062, 0.048),
        pt(-0.038, 0.036),
        pt(0.0, 0.034),
        pt(0.038, 0.036),
        pt(0.062, 0.048),
        pt(0.056, 0.028),
      ]);
      canvas.drawPath(
        hairline,
        Paint()..color = const Color(0xFF32323A).withValues(alpha: 0.72),
      );

      // Sobrancelhas e olhos
      for (final s in [-1.0, 1.0]) {
        canvas.drawLine(
          pt(s * 0.012, 0.058),
          pt(s * 0.040, 0.056),
          featureDark,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: pt(s * 0.026, 0.064),
            width: figW * 0.018,
            height: figH * 0.006,
          ),
          Paint()..color = const Color(0xFF27272F),
        );
      }
      // Dorso do nariz e lábios
      canvas.drawLine(pt(0.0, 0.058), pt(0.0, 0.078), featureDark);
      canvas.drawLine(pt(-0.010, 0.080), pt(0.010, 0.080), featureDark);
      canvas.drawLine(pt(-0.018, 0.092), pt(0.018, 0.092), featureDark);
    } else {
      // Nuca e cabelo curto sombreado na vista posterior
      final backHair = _smoothPoly([
        pt(0.0, 0.020),
        pt(-0.058, 0.028),
        pt(-0.065, 0.065),
        pt(-0.045, 0.088),
        pt(0.0, 0.092),
        pt(0.045, 0.088),
        pt(0.065, 0.065),
        pt(0.058, 0.028),
      ]);
      canvas.drawPath(
        backHair,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0.0, -0.3),
            radius: 0.85,
            colors: const [
              Color(0xFF686874),
              Color(0xFF34343C),
              Color(0xFF1A1A20),
            ],
          ).createShader(backHair.getBounds()),
      );
    }

    // 3. Punhos cerrados anatômicos, Patelas/Joelhos e Pés plantados
    for (final s in [-1.0, 1.0]) {
      // Mão / Punho cerrado
      final fistPath = _smoothPoly([
        pt(s * 0.305, 0.476),
        pt(s * 0.368, 0.472),
        pt(s * 0.382, 0.508),
        pt(s * 0.355, 0.530),
        pt(s * 0.308, 0.522),
        pt(s * 0.292, 0.496),
      ]);
      _drawTendonOrNeutralStructure(
        canvas,
        fistPath,
        light: const Color(0xFFDCDCE4),
        mid: const Color(0xFF8E8E9A),
        dark: const Color(0xFF383842),
      );

      // Joelho / Patela / Fossa poplítea
      final kneePath = _smoothPoly([
        pt(s * 0.065, 0.686),
        pt(s * 0.162, 0.688),
        pt(s * 0.158, 0.742),
        pt(s * 0.068, 0.742),
      ]);
      _drawTendonOrNeutralStructure(
        canvas,
        kneePath,
        light: const Color(0xFFD4D4DC),
        mid: const Color(0xFF8A8A96),
        dark: const Color(0xFF383842),
      );

      // Tornozelo e Pé anatômico
      final footPath = _smoothPoly([
        pt(s * 0.072, 0.905),
        pt(s * 0.135, 0.905),
        pt(s * 0.172, 0.955),
        pt(s * 0.155, 0.968),
        pt(s * 0.065, 0.968),
        pt(s * 0.060, 0.942),
      ]);
      _drawTendonOrNeutralStructure(
        canvas,
        footPath,
        light: const Color(0xFFDCDCE4),
        mid: const Color(0xFF90909C),
        dark: const Color(0xFF3A3A44),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnatomicalFiberPainter oldDelegate) {
    return oldDelegate.statuses != statuses ||
        oldDelegate.selectedMuscle != selectedMuscle ||
        oldDelegate.showFibers != showFibers ||
        oldDelegate.isFront != isFront;
  }
}
