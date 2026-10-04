import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/pricing_result.dart';

class ProfitResultCard extends StatelessWidget {
  const ProfitResultCard({
    super.key,
    required this.result,
    required this.currencySuffix,
  });

  final PricingResult result;
  final String currencySuffix;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      glow: true,
      gradient: AppColors.profitGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'سعر البيع المقترح',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const Icon(Icons.auto_graph_rounded, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedMoney(
            value: result.suggestedPrice,
            currencySuffix: currencySuffix,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'ربحك',
                  value: result.profit,
                  currencySuffix: currencySuffix,
                  color: AppColors.profit,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'هامش الربح',
                  value: result.profitMarginPercent,
                  asPercent: true,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms)
        .scale(begin: const Offset(0.96, 0.96));
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.currencySuffix,
    this.asPercent = false,
    required this.color,
  });

  final String label;
  final double value;
  final String? currencySuffix;
  final bool asPercent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        AnimatedMoney(
          value: value,
          currencySuffix: currencySuffix,
          withCurrency: !asPercent,
          asPercent: asPercent,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
