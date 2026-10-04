import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/qayd_promo_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).asData?.value;
    final products = ref.watch(productsProvider).asData?.value ?? const [];
    final currency = settings?.currencySuffix ?? AppConstants.currencySuffix;
    final showQayd = products.length >= AppConstants.qaydPromoProductThreshold &&
        !(settings?.qaydPromoDismissed ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'آخر التسعيرات',
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          100,
        ),
        children: [
          Text(
            'أهلاً بك 👋',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn().slideY(begin: 0.08),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'خلّينا نعرف السعر الصح.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ).animate().fadeIn(delay: 60.ms),
          const SizedBox(height: AppSpacing.xxl),
          Hero(
            tag: 'pricing-hero',
            child: Material(
              color: Colors.transparent,
              child: AppCard(
                glow: true,
                gradient: AppColors.heroGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'احسب سعر البيع',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.calculate_rounded,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'أدخل التكلفة ونسبة الربح وشوف السعر المقترح فوراً.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: 'ابدأ التسعير',
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => context.go('/calculator'),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
          const SizedBox(height: AppSpacing.xxl),
          if (products.isNotEmpty) ...[
            Text(
              'أحدث المنتجات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ...products.take(3).toList().asMap().entries.map((entry) {
              final p = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  onTap: () => context.go('/calculator?productId=${p.id}'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              'بيع: ${MoneyFormatter.format(p.suggestedPrice, currencySuffix: currency)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        MoneyFormatter.format(p.profit,
                            currencySuffix: currency),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.profit,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: (80 * entry.key).ms)
                    .fadeIn()
                    .slideX(begin: 0.05),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (showQayd)
            QaydPromoCard(
              onDismiss: () async {
                final repo = ref.read(settingsRepositoryProvider);
                final current = await repo.get();
                await repo.save(current.copyWith(qaydPromoDismissed: true));
              },
            ),
        ],
      ),
    );
  }
}
