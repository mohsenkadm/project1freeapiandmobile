import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbit;
  late final AnimationController _exit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.splash,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    _start();
  }

  Future<void> _start() async {
    await Future<void>.delayed(AppConstants.splashDuration);
    if (!mounted) return;
    await _exit.forward();
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _orbit.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _exit, curve: Curves.easeInCubic),
      ),
      child: Scaffold(
        backgroundColor: AppColors.splash,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _AmbientBackground(),
            Center(
              child: _LogoMark(orbit: _orbit),
            ),
            Align(
              alignment: const Alignment(0, 0.28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.35,
                        end: 0,
                        delay: 700.ms,
                        duration: 700.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.splashTagline,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w500,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: 950.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.4,
                        end: 0,
                        delay: 950.ms,
                        duration: 700.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.orbit});

  final Animation<double> orbit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: orbit,
            builder: (context, _) {
              return CustomPaint(
                size: const Size.square(260),
                painter: _OrbitPainter(progress: orbit.value),
              );
            },
          ),
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.splashGlow.withValues(alpha: 0.42),
                  blurRadius: 48,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: AppColors.splashGold.withValues(alpha: 0.16),
                  blurRadius: 28,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.94, 0.94),
                end: const Offset(1.08, 1.08),
                duration: 1800.ms,
                curve: Curves.easeInOut,
              ),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.32),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(44),
              child: Image.asset(
                AppConstants.splashLogoAsset,
                fit: BoxFit.cover,
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.04, 1.04),
                duration: 900.ms,
                curve: Curves.easeOutCubic,
              )
              .then(delay: 120.ms)
              .shimmer(
                duration: 1200.ms,
                color: Colors.white.withValues(alpha: 0.26),
              ),
        ],
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B2A63),
                AppColors.splash,
                Color(0xFF040D22),
              ],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(-0.85, -0.75),
          child: const _GlowBlob(
            color: Color(0x663B82F6),
            size: 280,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(
                begin: Offset.zero,
                end: const Offset(18, 24),
                duration: 4200.ms,
                curve: Curves.easeInOut,
              ),
        ),
        Align(
          alignment: const Alignment(0.9, 0.85),
          child: const _GlowBlob(
            color: Color(0x29F5B942),
            size: 240,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(
                begin: Offset.zero,
                end: const Offset(-22, -16),
                duration: 5000.ms,
                curve: Curves.easeInOut,
              ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.save();
    canvas.translate(center.dx, center.dy);

    _drawArc(
      canvas,
      radius: 108,
      start: progress * math.pi * 2,
      sweep: math.pi * 1.2,
      color: const Color(0xFF38BDF8),
      width: 2.8,
    );
    _drawArc(
      canvas,
      radius: 122,
      start: -progress * math.pi * 2.35,
      sweep: math.pi * 0.9,
      color: AppColors.splashGold,
      width: 2.1,
    );

    canvas.restore();
  }

  void _drawArc(
    Canvas canvas, {
    required double radius,
    required double start,
    required double sweep,
    required Color color,
    required double width,
  }) {
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.95),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.55, 1],
        transform: GradientRotation(start),
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
