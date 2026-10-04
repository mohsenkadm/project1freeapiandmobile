import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';

class QaydLandingScreen extends StatelessWidget {
  const QaydLandingScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const features = [
      'المبيعات',
      'المشتريات',
      'المخزون',
      'الديون',
      'المصاريف',
      'الصناديق',
      'الأرباح',
      'التقارير',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('قيد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          AppCard(
            glow: true,
            gradient: AppColors.primaryGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قيد المحاسبي',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'من تسعير المنتج... إلى إدارة نشاطك بالكامل.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.background,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'نظام محاسبي متكامل لأصحاب الأعمال.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.background.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.06),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < features.length; i++)
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 52) / 2,
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            features[i],
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: (40 * i).ms)
                      .fadeIn()
                      .scale(begin: const Offset(0.96, 0.96)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'جرّب قيد',
            icon: Icons.rocket_launch_rounded,
            onPressed: () => _open(AppConstants.qaidUrl),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () => _open(AppConstants.qaidContactUrl),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            child: const Text('تواصل معنا'),
          ),
        ],
      ),
    );
  }
}
