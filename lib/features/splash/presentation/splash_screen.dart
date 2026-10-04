import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _boot();
  }

  Future<void> _boot() async {
    // Let the entrance animations play, then wait for settings.
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted || _navigated) return;

    final settings = await ref.read(settingsRepositoryProvider).getSettings();
    if (!mounted || _navigated) return;
    _navigated = true;

    if (settings.onboardingDone) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_pulse.value);
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.lerp(
                        const Color(0xFF0F766E),
                        const Color(0xFF134E4A),
                        t,
                      ) ??
                      AppColors.primaryDark,
                  Color.lerp(
                        const Color(0xFF0D9488),
                        const Color(0xFF115E59),
                        1 - t,
                      ) ??
                      AppColors.primary,
                  Color.lerp(
                        const Color(0xFF14B8A6),
                        const Color(0xFF0F766E),
                        t,
                      ) ??
                      AppColors.primaryLight,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -size.height * 0.12,
                  left: -size.width * 0.2,
                  child: _GlowOrb(
                    diameter: size.width * 0.7,
                    opacity: 0.18 + (t * 0.08),
                  ),
                ),
                Positioned(
                  bottom: -size.height * 0.1,
                  right: -size.width * 0.15,
                  child: _GlowOrb(
                    diameter: size.width * 0.65,
                    opacity: 0.14 + ((1 - t) * 0.08),
                  ),
                ),
                ...List.generate(8, (i) {
                  final angle = (i / 8) * math.pi * 2;
                  final radius = 110.0 + (t * 18);
                  return Positioned(
                    top: size.height * 0.42 + math.sin(angle) * radius,
                    left: size.width * 0.5 + math.cos(angle) * radius - 4,
                    child: Opacity(
                      opacity: 0.25 + (t * 0.35),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: 0.96 + (t * 0.08),
                        child: Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 54,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1, 1),
                            curve: Curves.easeOutBack,
                            duration: 700.ms,
                          ),
                      const SizedBox(height: 28),
                      Text(
                        'دَيني',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                      )
                          .animate()
                          .fadeIn(delay: 250.ms, duration: 500.ms)
                          .slideY(begin: 0.25, end: 0, delay: 250.ms),
                      const SizedBox(height: 10),
                      Text(
                        'ديون زبائنك… ببساطة',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontWeight: FontWeight.w500,
                            ),
                      )
                          .animate()
                          .fadeIn(delay: 450.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0, delay: 450.ms),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 36,
                  left: 0,
                  right: 0,
                  child: Text(
                    'مجاني · Offline · للعراق',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.opacity});

  final double diameter;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
