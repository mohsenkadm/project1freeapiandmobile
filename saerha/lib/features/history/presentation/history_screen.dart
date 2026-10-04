import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../calculator/domain/entities/pricing_calculation.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final currency = ref.watch(settingsProvider).asData?.value.currencySuffix ??
        AppConstants.currencySuffix;

    return Scaffold(
      appBar: AppBar(title: const Text('آخر التسعيرات')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('حدث خطأ: $e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              title: 'لسه ماكو تسعيرات 👋',
              subtitle: 'كل عملية تسعير تحفظ هنا.',
              actionLabel: 'ابدأ التسعير',
              onAction: () => context.go('/calculator'),
            );
          }

          final grouped = <String, List<PricingCalculation>>{};
          for (final item in list) {
            final label = DateFormatter.relativeDayLabel(item.createdAt);
            grouped.putIfAbsent(label, () => []).add(item);
          }

          final sections = grouped.entries.toList();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            itemCount: sections.length,
            itemBuilder: (context, sectionIndex) {
              final section = sections[sectionIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text(
                      section.key,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...section.value.asMap().entries.map((entry) {
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              color: AppColors.danger),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(historyRepositoryProvider)
                              .delete(item.id);
                        },
                        child: AppCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName?.isNotEmpty == true
                                          ? item.productName!
                                          : 'تسعير سريع',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      MoneyFormatter.format(
                                        item.suggestedPrice,
                                        currencySuffix: currency,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'ربح ${MoneyFormatter.format(item.profit, currencySuffix: currency)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.profit,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        )
                            .animate(delay: (40 * entry.key).ms)
                            .fadeIn()
                            .slideY(begin: 0.05),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
