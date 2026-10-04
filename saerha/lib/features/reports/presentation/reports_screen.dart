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
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/qayd_promo_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(productInsightsProvider);
    final settings = ref.watch(settingsProvider).asData?.value;
    final currency = settings?.currencySuffix ?? AppConstants.currencySuffix;
    final showQayd = !(settings?.qaydPromoDismissed ?? false);

    if (insights.count == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('نظرة على منتجاتك')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            100,
          ),
          children: [
            EmptyState(
              title: 'لسه ماكو رؤى للعرض 👋',
              subtitle: 'احفظ بعض المنتجات حتى نشوف متوسط أرباحك.',
              actionLabel: 'ابدأ التسعير',
              onAction: () => context.go('/calculator'),
            ),
            if (showQayd) ...[
              const SizedBox(height: AppSpacing.xl),
              QaydPromoCard(
                onDismiss: () async {
                  final repo = ref.read(settingsRepositoryProvider);
                  final current = await repo.get();
                  await repo.save(current.copyWith(qaydPromoDismissed: true));
                },
              ),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظرة على منتجاتك'),
        actions: [
          IconButton(
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
          AppCard(
            glow: true,
            gradient: AppColors.heroGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متوسط هامش الربح',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  MoneyFormatter.percent(insights.averageMarginPercent,
                      decimals: 1),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.96, 0.96)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'عدد المنتجات',
                  value: '${insights.count}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  label: 'أعلى ربح',
                  value: insights.highestProfit == null
                      ? '-'
                      : MoneyFormatter.format(
                          insights.highestProfit!.profit,
                          currencySuffix: currency,
                        ),
                  subtitle: insights.highestProfit?.name,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 60.ms),
          const SizedBox(height: AppSpacing.sm),
          _StatCard(
            label: 'أقل منتج ربحاً',
            value: insights.lowestProfit == null
                ? '-'
                : MoneyFormatter.format(
                    insights.lowestProfit!.profit,
                    currencySuffix: currency,
                  ),
            subtitle: insights.lowestProfit?.name,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'هذه نظرة سريعة فقط — مو نظام محاسبي.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (showQayd) ...[
            const SizedBox(height: AppSpacing.xl),
            QaydPromoCard(
              onDismiss: () async {
                final repo = ref.read(settingsRepositoryProvider);
                final current = await repo.get();
                await repo.save(current.copyWith(qaydPromoDismissed: true));
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
