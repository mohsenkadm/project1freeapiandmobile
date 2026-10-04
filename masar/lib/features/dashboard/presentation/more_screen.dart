import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'الزبائن',
        subtitle: 'إدارة زبائنك بسرعة',
        icon: Icons.people_alt_outlined,
        path: '/customers',
        color: AppColors.info,
      ),
      (
        title: 'المنتجات',
        subtitle: 'قائمة المنتجات والأسعار',
        icon: Icons.inventory_2_outlined,
        path: '/products',
        color: AppColors.accent,
      ),
      (
        title: 'التقارير',
        subtitle: 'قيمة الطلبات والأداء',
        icon: Icons.bar_chart_rounded,
        path: '/reports',
        color: AppColors.primary,
      ),
      (
        title: 'الإعدادات',
        subtitle: 'النشاط والإشعارات والبيانات',
        icon: Icons.settings_outlined,
        path: '/settings',
        color: AppColors.textSecondary,
      ),
      (
        title: 'اكتشف قيد',
        subtitle: 'مسار يدير طلباتك. قيد يدير تجارتك.',
        icon: Icons.auto_awesome_rounded,
        path: '/qayd',
        color: AppColors.warning,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('المزيد')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          120,
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];
          return AppCard(
            onTap: () => context.push(item.path),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: item.color.withValues(alpha: 0.16),
                  child: Icon(item.icon, color: item.color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(item.subtitle,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left_rounded),
              ],
            ),
          )
              .animate(delay: (40 * index).ms)
              .fadeIn()
              .slideY(begin: 0.06);
        },
      ),
    );
  }
}
