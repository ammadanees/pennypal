import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

Future<void> showMilestoneCelebrationDialog(
  BuildContext context, {
  required String goalName,
  required int milestone,
  required bool isCompleted,
}) {
  HapticFeedback.heavyImpact();
  return showDialog<void>(
    context: context,
    builder: (ctx) => _MilestoneCelebrationDialog(
      goalName: goalName,
      milestone: milestone,
      isCompleted: isCompleted,
    ),
  );
}

class _MilestoneCelebrationDialog extends StatefulWidget {
  const _MilestoneCelebrationDialog({
    required this.goalName,
    required this.milestone,
    required this.isCompleted,
  });

  final String goalName;
  final int milestone;
  final bool isCompleted;

  @override
  State<_MilestoneCelebrationDialog> createState() =>
      _MilestoneCelebrationDialogState();
}

class _MilestoneCelebrationDialogState extends State<_MilestoneCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;

    final title = widget.isCompleted
        ? '🎉 Goal Completed!'
        : '🚀 ${widget.milestone}% Milestone Reached!';

    final message = widget.isCompleted
        ? 'Congratulations! You fully funded "${widget.goalName}". Fantastic student budgeting discipline!'
        : 'You just hit ${widget.milestone}% on "${widget.goalName}". Keep up the momentum!';

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      backgroundColor: c.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Animated Confetti Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(progress: _controller.value),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
                  ),
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: widget.isCompleted
                            ? const [Color(0xFFFFD700), Color(0xFFFFA500)]
                            : const [Color(0xFF2EE6A6), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isCompleted
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF2EE6A6))
                              .withOpacity(0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isCompleted
                          ? Icons.workspace_premium_rounded
                          : Icons.trending_up_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
                AppSpacing.vLg,
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: t.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vSm,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                AppSpacing.vLg,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.pillAll,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Keep it up!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static final List<_Particle> _particles = List.generate(40, (i) {
    final random = math.Random(i * 17);
    final angle = random.nextDouble() * 2 * math.pi;
    final speed = 80.0 + random.nextDouble() * 120.0;
    final size = 4.0 + random.nextDouble() * 5.0;
    final color = [
      const Color(0xFFFFD700),
      const Color(0xFF2EE6A6),
      const Color(0xFFFF6B6B),
      const Color(0xFF818CF8),
      const Color(0xFF38BDF8),
      const Color(0xFFF43F5E),
    ][i % 6];
    return _Particle(angle: angle, speed: speed, size: size, color: color);
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;
    final center = Offset(size.width / 2, size.height * 0.35);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in _particles) {
      final distance = p.speed * progress;
      final dx = center.dx + math.cos(p.angle) * distance;
      final dy = center.dy + math.sin(p.angle) * distance + (progress * 40.0);

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), p.size * (1.0 - (progress * 0.4)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  final double angle;
  final double speed;
  final double size;
  final Color color;
}
