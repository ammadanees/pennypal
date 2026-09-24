import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/hex_pattern.dart';
import '../../auth/data/auth_providers.dart';

/// One orchestrated moment: a honey coin drops in, spins to reveal the P,
/// a honeycomb hexagon draws around it, then the wordmark rises letter by
/// letter. The honeycomb grid blooms outward behind it all.
///
/// The splash always uses the light brand colours so the first impression
/// is identical in light and dark mode.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 3400);
  static const _holdAfter = Duration(milliseconds: 400);
  static const _authTimeout = Duration(seconds: 4);

  // Timeline, as fractions of the whole animation.
  static const _grid = Interval(0.0, 0.6, curve: Curves.easeOutCubic);
  static const _drop = Interval(0.05, 0.34, curve: Curves.bounceOut);
  static const _spin = Interval(0.34, 0.62, curve: Curves.easeInOutCubic);
  static const _outline = Interval(0.40, 0.68, curve: Curves.easeInOut);
  static const _dots = Interval(0.66, 0.78, curve: Curves.easeOutBack);
  static const _wordStart = 0.62;
  static const _letterStagger = 0.018;
  static const _letterSpan = 0.09;
  static const _taglineStart = 0.80;
  static const _taglineSpan = 0.16;

  static const _stageSize = 220.0;
  static const _coinSize = 112.0;
  static const _hexRadius = 92.0;
  static const _wordSize = 44.0;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _duration);

  AppColors get _brand => AppColors.light;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final authReady = _authReady();

    if (reduceMotion) {
      _controller.value = 1;
      await Future.wait<Object?>([
        authReady,
        Future<void>.delayed(const Duration(milliseconds: 600)),
      ]);
    } else {
      await Future.wait<Object?>([_controller.forward(), authReady]);
      await Future<void>.delayed(_holdAfter);
    }
    if (!mounted) return;
    // The router's redirect decides where this really goes: welcome on the
    // first launch, sign in when signed out, or the right home when signed in.
    context.go(AppRoutes.welcome);
  }

  Future<Object?> _authReady() async {
    try {
      return await ref
          .read(authStateProvider.future)
          .timeout(_authTimeout, onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = _brand;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: brand.primary,
        body: Semantics(
          label: '${AppStrings.appName}. ${AppStrings.tagline}.',
          excludeSemantics: true,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final v = _controller.value;
              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: HexPatternPainter(
                      color: brand.onPrimary,
                      opacity: 0.10,
                      reveal: _grid.transform(v),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _stage(v, MediaQuery.sizeOf(context).height),
                        const SizedBox(height: 28),
                        _wordmark(v, context),
                        const SizedBox(height: 10),
                        _tagline(v, context),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Opacity(
                          opacity: _fade(v, _taglineStart + 0.04, 0.16),
                          child: Text(
                            AppStrings.splashFootnote,
                            style: context.text.bodySmall
                                ?.copyWith(color: brand.onPrimary.withOpacity(0.65)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _fade(double v, double start, double span) =>
      Curves.easeOut.transform(((v - start) / span).clamp(0.0, 1.0));

  Widget _stage(double v, double screenHeight) {
    final brand = _brand;
    final dropT = _drop.transform(v);
    final spinT = _spin.transform(v);
    final flip = math.cos(spinT * math.pi * 4).abs().clamp(0.04, 1.0);

    return SizedBox(
      width: _stageSize,
      height: _stageSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ground shadow grows as the coin lands.
          Align(
            alignment: const Alignment(0, 0.78),
            child: Opacity(
              opacity: 0.22 * dropT,
              child: Container(
                width: _coinSize * 0.8 * (0.4 + 0.6 * dropT),
                height: 12,
                decoration: BoxDecoration(
                  color: brand.textPrimary,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
          ),
          CustomPaint(
            size: const Size.square(_stageSize),
            painter: _HexOutlinePainter(
              progress: _outline.transform(v),
              dots: _dots.transform(v).clamp(0.0, 1.4),
              stroke: brand.onPrimary,
              dotColor: brand.secondary,
              radius: _hexRadius,
            ),
          ),
          Transform.translate(
            offset: Offset(0, -(1 - dropT) * (screenHeight / 2 + _coinSize)),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(flip, 1, 1),
              child: _Coin(brand: brand, size: _coinSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordmark(double v, BuildContext context) {
    final brand = _brand;
    const word = AppStrings.appName;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < word.length; i++)
          () {
            final t = Curves.easeOutCubic.transform(
              ((v - (_wordStart + i * _letterStagger)) / _letterSpan)
                  .clamp(0.0, 1.0),
            );
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 18),
                child: Text(
                  word[i],
                  // "Penny" in white, "Pal" in honey.
                  style: AppTextStyles.brand(
                    _wordSize,
                    i >= 5 ? brand.secondary : brand.onPrimary,
                  ),
                ),
              ),
            );
          }(),
      ],
    );
  }

  Widget _tagline(double v, BuildContext context) {
    final brand = _brand;
    final t = _fade(v, _taglineStart, _taglineSpan);
    return Opacity(
      opacity: t,
      child: Text(
        AppStrings.tagline,
        style: context.text.titleMedium?.copyWith(
          color: brand.onPrimary.withOpacity(0.9),
          letterSpacing: 8 - 6.5 * t,
        ),
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.brand, required this.size});

  final AppColors brand;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: brand.secondary,
        border: Border.all(color: brand.savings, width: 5),
      ),
      child: Container(
        width: size * 0.75,
        height: size * 0.75,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: brand.savings.withOpacity(0.55), width: 2),
        ),
        child: Text(
          AppStrings.appName.substring(0, 1),
          style: AppTextStyles.brand(size * 0.42, brand.onSecondary),
        ),
      ),
    );
  }
}

/// A hexagon that draws itself, then pops a dot on each corner.
class _HexOutlinePainter extends CustomPainter {
  const _HexOutlinePainter({
    required this.progress,
    required this.dots,
    required this.stroke,
    required this.dotColor,
    required this.radius,
  });

  final double progress;
  final double dots;
  final Color stroke;
  final Color dotColor;
  final double radius;

  static const double _dotRadius = 5;
  static const double _lineWidth = 2.5;

  List<Offset> _corners(Offset center) => [
        for (var i = 0; i < 6; i++)
          center +
              Offset(
                radius * math.cos(math.pi / 3 * i - math.pi / 2),
                radius * math.sin(math.pi / 3 * i - math.pi / 2),
              ),
      ];

  @override
  void paint(Canvas canvas, Size size) {
    final corners = _corners(size.center(Offset.zero));

    if (progress > 0) {
      final path = Path()..moveTo(corners.first.dx, corners.first.dy);
      for (final corner in corners.skip(1)) {
        path.lineTo(corner.dx, corner.dy);
      }
      path.close();

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = stroke.withOpacity(0.9);
      for (final metric in path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
      }
    }

    if (dots > 0) {
      final dotPaint = Paint()..color = dotColor;
      for (final corner in corners) {
        canvas.drawCircle(corner, _dotRadius * dots, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_HexOutlinePainter old) =>
      old.progress != progress || old.dots != dots;
}
