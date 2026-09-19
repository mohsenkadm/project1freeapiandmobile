import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    (
      title: 'فلوسك تحت السيطرة',
      body: 'سجّل حركة الصندوق اليومية واعرف رصيدك الحقيقي.',
      icon: Icons.account_balance_wallet_rounded,
    ),
    (
      title: 'اكتشف الفرق بسرعة',
      body: 'قارن بين المبلغ المتوقع والمبلغ الموجود فعلياً.',
      icon: Icons.balance_rounded,
    ),
    (
      title: 'اعرف وين راحت فلوسك',
      body: 'تابع المبيعات والمصاريف والسحوبات والدفعات بسهولة.',
      icon: Icons.insights_rounded,
    ),
  ];

  Future<void> _finish() async {
    final repo = ref.read(settingsRepositoryProvider);
    final current = await repo.get();
    await repo.save(current.copyWith(onboardingDone: true));
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _finish,
                child: const Text('تخطي'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.expectedGradient,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Icon(
                            page.icon,
                            size: 72,
                            color: AppColors.primary,
                          ),
                        )
                            .animate(key: ValueKey('icon-$i'))
                            .fadeIn(duration: 400.ms)
                            .scale(begin: const Offset(0.9, 0.9))
                            .slideY(begin: 0.08),
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ).animate().fadeIn().slideY(begin: 0.1),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.7,
                              ),
                        ).animate().fadeIn(delay: 80.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              child: PrimaryButton(
                label: _index == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                onPressed: () {
                  if (_index == _pages.length - 1) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
