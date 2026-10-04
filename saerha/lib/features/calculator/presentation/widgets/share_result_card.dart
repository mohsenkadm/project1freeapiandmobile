import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/pricing_result.dart';

/// Off-screen-friendly shareable summary card.
class ShareResultCard extends StatelessWidget {
  const ShareResultCard({
    super.key,
    required this.result,
    required this.currencySuffix,
    this.productName,
  });

  final PricingResult result;
  final String currencySuffix;
  final String? productName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Cairo'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              productName?.isNotEmpty == true ? productName! : 'نتيجة التسعير',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.lg),
            _row('التكلفة', result.totalCost),
            _row('المصاريف', result.totalAdditionalCosts),
            _row('سعر البيع', result.suggestedPrice, highlight: true),
            _row('الربح', result.profit, profit: true),
            _row(
              'هامش الربح',
              result.profitMarginPercent,
              isPercent: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppConstants.tagline,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    double value, {
    bool highlight = false,
    bool profit = false,
    bool isPercent = false,
  }) {
    final text = isPercent
        ? MoneyFormatter.percent(value)
        : MoneyFormatter.format(value, currencySuffix: currencySuffix);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: highlight ? 20 : 16,
              color: profit
                  ? AppColors.profit
                  : (highlight ? AppColors.accent : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
