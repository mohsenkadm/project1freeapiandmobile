import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/money_formatter.dart';
import 'animated_amount.dart';
import 'app_card.dart';

class AmountCard extends StatelessWidget {
  const AmountCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.gradient,
    this.trailing,
    this.large = false,
  });

  final String title;
  final double amount;
  final String? subtitle;
  final Gradient? gradient;
  final Widget? trailing;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedAmount(
            amount: amount,
            style: (large
                    ? Theme.of(context).textTheme.headlineLarge
                    : Theme.of(context).textTheme.headlineMedium)
                ?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.amount,
    this.color,
    this.icon,
  });

  final String label;
  final double amount;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            MoneyFormatter.format(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
