import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';
import 'primary_button.dart';

class QaydPromoCard extends StatelessWidget {
  const QaydPromoCard({
    super.key,
    this.onDismiss,
  });

  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      glow: true,
      gradient: AppColors.heroGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'تعرف قيمة طلباتك؟',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: AppColors.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'تعرف شكد ربحت فعلياً؟',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.accent,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'مسار يتابع طلباتك من البداية إلى التسليم.\nقيد يتابع تجارتك بالكامل.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'اكتشف قيد',
            icon: Icons.auto_awesome_rounded,
            onPressed: () => context.push('/qayd'),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.08);
  }
}
