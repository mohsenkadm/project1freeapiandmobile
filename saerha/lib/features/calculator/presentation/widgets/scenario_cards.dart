import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/pricing_result.dart';

class ScenarioCards extends StatelessWidget {
  const ScenarioCards({
    super.key,
    required this.result,
    required this.currencySuffix,
  });

  final PricingResult result;
  final String currencySuffix;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'سعر منخفض',
        price: result.lowScenarioPrice,
        profit: result.lowScenarioProfit,
        featured: false,
      ),
      (
        title: 'السعر المقترح',
        price: result.suggestedPrice,
        profit: result.profit,
        featured: true,
      ),
      (
        title: 'سعر أعلى',
        price: result.highScenarioPrice,
        profit: result.highScenarioProfit,
        featured: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ماذا لو بعت بسعر مختلف؟',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ...items.asMap().entries.map((entry) {
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              glow: item.featured,
              borderColor: item.featured
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : null,
              gradient: item.featured ? AppColors.heroGradient : null,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: item.featured
                                        ? AppColors.accent
                                        : null,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedMoney(
                          value: item.price,
                          currencySuffix: currencySuffix,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'الربح',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      AnimatedMoney(
                        value: item.profit,
                        currencySuffix: currencySuffix,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: item.profit >= 0
                                      ? AppColors.profit
                                      : AppColors.danger,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate(delay: (50 * entry.key).ms)
                .fadeIn()
                .slideY(begin: 0.04),
          );
        }),
      ],
    );
  }
}
