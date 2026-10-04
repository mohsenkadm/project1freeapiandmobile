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
    required this.onDismiss,
  });

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF0F3D3A), Color(0xFF132A34)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'عرفت ربح المنتج… بس تعرف ربح محلك؟',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                tooltip: 'إغلاق',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'سعّرها يساعدك بتحديد سعر البيع،\nأما قيد فيساعدك تعرف أرباح نشاطك بالكامل.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'اكتشف قيد',
            onPressed: () => context.push('/qayd'),
            icon: Icons.rocket_launch_rounded,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.08);
  }
}
