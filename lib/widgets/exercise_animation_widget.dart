import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/profile_evolution_models.dart';
import '../theme/rec_theme.dart';

/// Widget de animação vetorial biomecânica que demonstra a execução
/// cinemática do exercício e destaca os grupamentos musculares recrutados
/// (inspirado nos GIFs anatômicos de exercícios da internet).
class ExerciseAnimationWidget extends StatefulWidget {
  final String animationKey;
  final String exerciseName;
  final double width;
  final double height;
  final bool showPhaseLabel;

  const ExerciseAnimationWidget({
    super.key,
    required this.animationKey,
    required this.exerciseName,
    this.width = 58,
    this.height = 58,
    this.showPhaseLabel = false,
  });

  @override
  State<ExerciseAnimationWidget> createState() =>
      _ExerciseAnimationWidgetState();
}

class _ExerciseAnimationWidgetState extends State<ExerciseAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _cyclesCompleted = 0;
  bool _settled = false;
  static const int _maxAutoCycles = 2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _controller.addStatusListener(_onStatusChanged);
    _controller.forward();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (!mounted || _settled) return;
    if (status == AnimationStatus.completed) {
      _controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _cyclesCompleted += 1;
      if (_cyclesCompleted < _maxAutoCycles) {
        _controller.forward();
      } else {
        // Estabiliza em pose de pico de contração (0.65) após os ciclos iniciais,
        // permitindo que animações rodem ao abrir e também compatibilizando com pumpAndSettle.
        _settled = true;
        _controller.value = 0.65;
      }
    }
  }

  void replayAnimation() {
    _settled = false;
    _cyclesCompleted = 0;
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: RecTheme.primaryRed.withValues(alpha: 0.45),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeInOutSine.transform(_controller.value);
                return CustomPaint(
                  painter: _BiomechanicalExercisePainter(
                    animationKey: widget.animationKey,
                    progress: t,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 3,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: RecTheme.primaryRed.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'GIF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          if (widget.showPhaseLabel)
            Positioned(
              bottom: 6,
              left: 8,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final concentric = _controller.value >= 0.5;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: RecTheme.borderSubtle),
                    ),
                    child: Text(
                      concentric
                          ? 'Fase Concêntrica · Contração das Fibras'
                          : 'Fase Excêntrica · Alongamento Controlado',
                      style: const TextStyle(
                        color: RecTheme.primaryRedLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Abre um modal com a demonstração biomecânica ampliada do exercício,
/// músculos recrutados, direção das fibras e histórico do Recorde Pessoal (PR).
void showExerciseBiomechanicalModal(
  BuildContext context,
  PersonalRecord pr,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: RecTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RecTheme.borderSubtle),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.slow_motion_video_rounded,
              color: RecTheme.primaryRed,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                pr.exerciseName,
                style: const TextStyle(
                  color: RecTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExerciseAnimationWidget(
                key: const Key('modal_exercise_animation_player'),
                animationKey: pr.animationKey,
                exerciseName: pr.exerciseName,
                width: 280,
                height: 185,
                showPhaseLabel: true,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: RecTheme.surfaceInput,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: RecTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'NOVO RECORDE PESSOAL',
                          style: TextStyle(
                            color: RecTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          pr.dateLabel,
                          style: const TextStyle(
                            color: RecTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pr.integerWeightKg} kg x ${pr.reps} reps (+${pr.integerImprovementKg}kg vs anterior: ${pr.integerPreviousBestKg} kg)',
                      style: const TextStyle(
                        color: RecTheme.emerald,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Músculo Alvo Principal: ${pr.primaryMuscle.label}',
                      style: const TextStyle(
                        color: RecTheme.primaryRedLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Direção das Fibras: ${pr.primaryMuscle.fiberDirectionDescription}',
                      style: const TextStyle(
                        color: RecTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    if (pr.secondaryMuscles.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Sinergistas: ${pr.secondaryMuscles.map((m) => m.label).join(", ")}',
                        style: const TextStyle(
                          color: RecTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            key: const Key('close_pr_animation_modal_button'),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar Demonstração'),
          ),
        ],
      );
    },
  );
}

class _BiomechanicalExercisePainter extends CustomPainter {
  final String animationKey;
  final double progress; // 0.0 (início) a 1.0 (pico de contração/extensão)

  _BiomechanicalExercisePainter({
    required this.animationKey,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Piso / Plataforma de referência
    final floorPaint = Paint()
      ..color = const Color(0xFF2E2E36)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(w * 0.12, h * 0.86),
      Offset(w * 0.88, h * 0.86),
      floorPaint,
    );

    final bonePaint = Paint()
      ..color = const Color(0xFFA1A1AA)
      ..strokeWidth = math.max(2.2, w * 0.038)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final activeMusclePaint = Paint()
      ..color = RecTheme.primaryRed.withValues(alpha: 0.45 + 0.45 * progress)
      ..strokeWidth = math.max(3.6, w * 0.062)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final barPaint = Paint()
      ..color = const Color(0xFFE4E4E7)
      ..strokeWidth = math.max(2.0, w * 0.032)
      ..strokeCap = StrokeCap.round;

    final platePaint = Paint()
      ..color = RecTheme.amber
      ..style = PaintingStyle.fill;

    switch (animationKey) {
      case 'squat':
        _paintSquat(
          canvas,
          w,
          h,
          bonePaint,
          activeMusclePaint,
          barPaint,
          platePaint,
        );
        break;
      case 'hip_thrust':
        _paintHipThrust(
          canvas,
          w,
          h,
          bonePaint,
          activeMusclePaint,
          barPaint,
          platePaint,
        );
        break;
      case 'bench_press':
      case 'chest_fly':
        _paintBenchPress(
          canvas,
          w,
          h,
          bonePaint,
          activeMusclePaint,
          barPaint,
          platePaint,
        );
        break;
      case 'romanian_deadlift':
        _paintRdl(
          canvas,
          w,
          h,
          bonePaint,
          activeMusclePaint,
          barPaint,
          platePaint,
        );
        break;
      case 'lat_pulldown':
        _paintLatPulldown(
          canvas,
          w,
          h,
          bonePaint,
          activeMusclePaint,
          barPaint,
        );
        break;
      default:
        _paintOverheadOrCurl(
          canvas,
          w,
          h,
          bonePaint,
          activeMusclePaint,
          barPaint,
          platePaint,
        );
    }
  }

  void _paintSquat(
    Canvas canvas,
    double w,
    double h,
    Paint bone,
    Paint muscle,
    Paint bar,
    Paint plate,
  ) {
    final depth = progress;
    final ankle = Offset(w * 0.46, h * 0.84);
    final knee = Offset(w * (0.52 + 0.10 * depth), h * (0.62 + 0.08 * depth));
    final hip = Offset(
      w * (0.44 - 0.10 * depth),
      h * (0.46 + 0.22 * depth),
    );
    final shoulder = Offset(
      w * (0.47 - 0.04 * depth),
      h * (0.24 + 0.19 * depth),
    );
    final head = Offset(shoulder.dx + w * 0.02, shoulder.dy - h * 0.09);

    canvas.drawLine(ankle, knee, bone);
    canvas.drawLine(knee, hip, muscle);
    canvas.drawLine(hip, shoulder, bone);
    canvas.drawCircle(head, w * 0.055, Paint()..color = const Color(0xFFD4D4D8));

    final barLeft = Offset(shoulder.dx - w * 0.20, shoulder.dy + h * 0.01);
    final barRight = Offset(shoulder.dx + w * 0.20, shoulder.dy + h * 0.01);
    canvas.drawLine(barLeft, barRight, bar);
    canvas.drawRect(
      Rect.fromCenter(
        center: barLeft,
        width: w * 0.045,
        height: h * 0.13,
      ),
      plate,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: barRight,
        width: w * 0.045,
        height: h * 0.13,
      ),
      plate,
    );
  }

  void _paintHipThrust(
    Canvas canvas,
    double w,
    double h,
    Paint bone,
    Paint muscle,
    Paint bar,
    Paint plate,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.56, w * 0.22, h * 0.28),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF27272A),
    );

    final lift = progress;
    final shoulder = Offset(w * 0.28, h * 0.54);
    final head = Offset(w * 0.20, h * 0.49);
    final hip = Offset(w * 0.52, h * (0.74 - 0.20 * lift));
    final knee = Offset(w * 0.74, h * 0.55);
    final ankle = Offset(w * 0.76, h * 0.84);

    canvas.drawLine(shoulder, hip, bone);
    canvas.drawLine(hip, knee, muscle);
    canvas.drawLine(knee, ankle, bone);
    canvas.drawCircle(head, w * 0.05, Paint()..color = const Color(0xFFD4D4D8));
    canvas.drawCircle(hip, w * 0.065, plate);
  }

  void _paintBenchPress(
    Canvas canvas,
    double w,
    double h,
    Paint bone,
    Paint muscle,
    Paint bar,
    Paint plate,
  ) {
    canvas.drawLine(
      Offset(w * 0.18, h * 0.68),
      Offset(w * 0.76, h * 0.68),
      Paint()
        ..color = const Color(0xFF3F3F46)
        ..strokeWidth = math.max(3.0, h * 0.05),
    );

    final push = progress;
    final head = Offset(w * 0.24, h * 0.60);
    final shoulder = Offset(w * 0.36, h * 0.61);
    final hip = Offset(w * 0.62, h * 0.62);
    final knee = Offset(w * 0.78, h * 0.64);
    final ankle = Offset(w * 0.80, h * 0.84);

    final elbow = Offset(
      w * (0.38 + 0.03 * push),
      h * (0.66 - 0.14 * push),
    );
    final hand = Offset(w * 0.42, h * (0.52 - 0.24 * push));

    canvas.drawCircle(head, w * 0.05, Paint()..color = const Color(0xFFD4D4D8));
    canvas.drawLine(shoulder, hip, muscle);
    canvas.drawLine(hip, knee, bone);
    canvas.drawLine(knee, ankle, bone);
    canvas.drawLine(shoulder, elbow, muscle);
    canvas.drawLine(elbow, hand, muscle);

    canvas.drawLine(
      Offset(hand.dx - w * 0.14, hand.dy),
      Offset(hand.dx + w * 0.14, hand.dy),
      bar,
    );
    canvas.drawCircle(hand, w * 0.055, plate);
  }

  void _paintRdl(
    Canvas canvas,
    double w,
    double h,
    Paint bone,
    Paint muscle,
    Paint bar,
    Paint plate,
  ) {
    final hinge = progress;
    final ankle = Offset(w * 0.48, h * 0.84);
    final knee = Offset(w * (0.48 - 0.03 * hinge), h * 0.64);
    final hip = Offset(w * (0.45 - 0.12 * hinge), h * (0.46 + 0.04 * hinge));
    final shoulder = Offset(
      w * (0.48 + 0.18 * hinge),
      h * (0.24 + 0.24 * hinge),
    );
    final head = Offset(
      shoulder.dx + w * 0.06,
      shoulder.dy - h * (0.07 - 0.04 * hinge),
    );
    final hand = Offset(shoulder.dx - w * 0.03, shoulder.dy + h * 0.24);

    canvas.drawLine(ankle, knee, bone);
    canvas.drawLine(knee, hip, muscle);
    canvas.drawLine(hip, shoulder, muscle);
    canvas.drawLine(shoulder, hand, bone);
    canvas.drawCircle(head, w * 0.05, Paint()..color = const Color(0xFFD4D4D8));
    canvas.drawCircle(hand, w * 0.06, plate);
  }

  void _paintLatPulldown(
    Canvas canvas,
    double w,
    double h,
    Paint bone,
    Paint muscle,
    Paint bar,
  ) {
    final pull = progress;
    final hip = Offset(w * 0.50, h * 0.72);
    final shoulder = Offset(w * 0.50, h * 0.44);
    final head = Offset(w * 0.50, h * 0.33);
    final barY = h * (0.16 + 0.24 * pull);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.05),
      Offset(w * 0.50, barY),
      Paint()
        ..color = RecTheme.textMuted
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(Offset(w * 0.24, barY), Offset(w * 0.76, barY), bar);

    for (final s in [-1.0, 1.0]) {
      final hand = Offset(w * (0.50 + s * 0.22), barY);
      final elbow = Offset(
        w * (0.50 + s * (0.18 + 0.05 * pull)),
        h * (0.28 + 0.20 * pull),
      );
      canvas.drawLine(shoulder, elbow, muscle);
      canvas.drawLine(elbow, hand, bone);
    }
    canvas.drawLine(shoulder, hip, muscle);
    canvas.drawCircle(head, w * 0.05, Paint()..color = const Color(0xFFD4D4D8));
  }

  void _paintOverheadOrCurl(
    Canvas canvas,
    double w,
    double h,
    Paint bone,
    Paint muscle,
    Paint bar,
    Paint plate,
  ) {
    final lift = progress;
    final ankle = Offset(w * 0.50, h * 0.84);
    final hip = Offset(w * 0.50, h * 0.55);
    final shoulder = Offset(w * 0.50, h * 0.32);
    final head = Offset(w * 0.50, h * 0.21);

    canvas.drawLine(ankle, hip, bone);
    canvas.drawLine(hip, shoulder, bone);
    canvas.drawCircle(head, w * 0.05, Paint()..color = const Color(0xFFD4D4D8));

    for (final s in [-1.0, 1.0]) {
      final sh = Offset(w * (0.50 + s * 0.10), h * 0.32);
      final elbow = Offset(w * (0.50 + s * 0.16), h * (0.44 - 0.10 * lift));
      final hand = Offset(w * (0.50 + s * 0.18), h * (0.52 - 0.34 * lift));
      canvas.drawLine(sh, elbow, muscle);
      canvas.drawLine(elbow, hand, muscle);
      canvas.drawCircle(hand, w * 0.035, plate);
    }
  }

  @override
  bool shouldRepaint(covariant _BiomechanicalExercisePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationKey != animationKey;
  }
}
