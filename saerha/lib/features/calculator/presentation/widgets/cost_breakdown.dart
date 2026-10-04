import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/pricing_result.dart';

class CostBreakdown extends StatelessWidget {
  const CostBreakdown({
    super.key,
    required this.result,
    required this.currencySuffix,
  });

  final PricingResult result;
  final String currencySuffix;

  @override
  Widget build(BuildContext context) {
    final total = result.suggestedPrice <= 0 ? 1.0 : result.suggestedPrice;
    final rows = [
      ('سعر الشراء', result.purchasePrice, AppColors.textSecondary),
      ('المصاريف', result.totalAdditionalCosts, AppColors.warning),
      ('التكلفة الحقيقية', result.totalCost, AppColors.primary),
      ('الربح', result.profit, AppColors.profit),
      ('سعر البيع', result.suggestedPrice, AppColors.accent),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفصيل التكلفة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...rows.map((row) {
            final ratio = (row.$2 / total).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(row.$1)),
                      AnimatedMoney(
                        value: row.$2,
                        currencySuffix: currencySuffix,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: ratio),
                      duration: const Duration(milliseconds: 450),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 7,
                          backgroundColor:
                              AppColors.textSecondary.withValues(alpha: 0.12),
                          color: row.$3,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
