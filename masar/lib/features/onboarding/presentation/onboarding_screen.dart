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
      title: 'كل طلب بمسار واضح',
      body: 'سجل طلباتك وتابعها من أول لحظة حتى التسليم.',
      icon: Icons.receipt_long_rounded,
    ),
    (
      title: 'اعرف طلباتك وين وصلت',
      body: 'جديد، تجهيز، جاهز، توصيل، أو تم التسليم.',
      icon: Icons.timeline_rounded,
    ),
    (
      title: 'اعرف شكد ربحت',
      body: 'تابع قيمة طلباتك، وعندما تحتاج الصورة الكاملة انتقل إلى قيد.',
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
    final isLast = _index == _pages.length - 1;

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 168,
                          height: 168,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            gradient: AppColors.heroGradient,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.18),
                                blurRadius: 28,
                              ),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 76,
                            color: AppColors.primary,
                          ),
                        )
                            .animate(key: ValueKey('icon-$i'))
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: i.isOdd ? 0.12 : -0.12)
                            .scale(begin: const Offset(0.9, 0.9)),
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
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.7,
                                  ),
                        ).animate().fadeIn(delay: 80.ms),
                        if (i == 1) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          _StatusProgressPreview(),
                        ],
                        if (i == 2) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          _RevenuePreview(),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final selected = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: PrimaryButton(
                label: isLast ? 'ابدأ الآن' : 'التالي',
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 320),
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

class _StatusProgressPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const labels = ['جديد', 'تجهيز', 'جاهز', 'توصيل', 'تسليم'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: i <= 2
                      ? AppColors.primary
                      : AppColors.surface,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: i <= 2
                          ? AppColors.background
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          if (i < labels.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: i < 2
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.25),
              ),
            ),
        ],
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class _RevenuePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('قيمة الطلبات',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 6),
                Text(
                  '1,250,000',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('ربح تقديري',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 6),
                Text(
                  '320,000',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.success,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
