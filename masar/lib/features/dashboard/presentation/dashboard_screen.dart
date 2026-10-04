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
import '../../../core/widgets/count_up_text.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/qayd_promo_card.dart';
import '../../orders/domain/entities/order_status.dart';
import '../../orders/domain/repositories/order_repository.dart';
import '../../orders/presentation/order_status_ui.dart';
import '../../orders/presentation/widgets/order_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (orders) {
            final today = DateTime.now();
            final todayOrders = orders.forDay(today);
            final todayValue = todayOrders.totalValue;
            final settings = settingsAsync.asData?.value;
            final deliveredCount =
                orders.where((o) => o.status == OrderStatus.delivered).length;
            final showQayd = !(settings?.qaydPromoDismissed ?? false) &&
                (orders.length >= AppConstants.qaydPromoMinOrders ||
                    deliveredCount >= AppConstants.qaydPromoMinDelivered);

            if (orders.isEmpty) {
              return EmptyState(
                title: 'ما عندك طلبات اليوم 👋',
                subtitle: 'أول طلب ينتظرك.',
                actionLabel: 'إضافة طلب',
                onAction: () => context.push('/orders/new'),
              );
            }

            final recent = orders.take(5).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                120,
              ),
              children: [
                Text(
                  'أهلاً بك 👋',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn().slideY(begin: 0.08),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'هذه نظرة سريعة على طلباتك اليوم',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateFormatter.fullDate(today),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  glow: true,
                  gradient: AppColors.heroGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلبات اليوم',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CountUpText(
                        value: todayOrders.length,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'قيمة الطلبات: ${MoneyFormatter.format(todayValue)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.96, 0.96)),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final status in [
                      OrderStatus.neu,
                      OrderStatus.processing,
                      OrderStatus.ready,
                      OrderStatus.outForDelivery,
                      OrderStatus.delivered,
                    ])
                      SizedBox(
                        width: (MediaQuery.sizeOf(context).width - 52) / 2,
                        child: AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    status.color.withValues(alpha: 0.16),
                                child: Icon(status.icon,
                                    color: status.color, size: 18),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(status.labelAr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    CountUpText(
                                      value: todayOrders.countByStatus(status),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate(
                              delay: (40 *
                                      OrderStatus.activeFlow
                                          .indexOf(status))
                                  .ms,
                            )
                            .fadeIn()
                            .slideY(begin: 0.08),
                      ),
                  ],
                ),
                if (showQayd) ...[
                  const SizedBox(height: AppSpacing.xl),
                  QaydPromoCard(
                    onDismiss: () async {
                      final current =
                          await ref.read(settingsRepositoryProvider).get();
                      await ref.read(settingsRepositoryProvider).save(
                            current.copyWith(qaydPromoDismissed: true),
                          );
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Text('آخر الطلبات',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/orders'),
                      child: const Text('الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...recent.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: OrderCard(order: e.value, index: e.key),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
