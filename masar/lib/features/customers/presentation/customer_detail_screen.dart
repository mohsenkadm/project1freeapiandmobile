import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../../orders/domain/entities/order.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerByIdProvider(customerId));
    final ordersAsync = ref.watch(ordersProvider);
    final compute = ref.watch(computeCustomerTotalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الزبون'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: customerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (customer) {
          if (customer == null) {
            return const EmptyState(
              title: 'الزبون غير موجود',
              subtitle: 'ربما تم حذفه.',
            );
          }
          final orders = ordersAsync.asData?.value ?? <Order>[];
          final totals = compute(orders, customer.id);
          final customerOrders = orders
              .where((o) => o.customerId == customer.id)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(customer.phone),
                    if (customer.address.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(customer.address,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    if (customer.notes.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(customer.notes,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            label: 'الطلبات',
                            value: '${totals.orderCount}',
                          ),
                        ),
                        Expanded(
                          child: _Stat(
                            label: 'إجمالي المشتريات',
                            value: MoneyFormatter.format(totals.totalValue),
                          ),
                        ),
                      ],
                    ),
                    if (totals.lastOrder != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'آخر طلب: ${totals.lastOrder!.displayNumber} · ${DateFormatter.dayLabel(totals.lastOrder!.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri(scheme: 'tel', path: customer.phone);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const Icon(Icons.call_rounded),
                      label: const Text('اتصال'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('طلباته', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              if (customerOrders.isEmpty)
                const Text('لا توجد طلبات لهذا الزبون بعد.')
              else
                ...customerOrders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AppCard(
                      onTap: () => context.push('/orders/${order.id}'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.displayNumber,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text(MoneyFormatter.format(order.total)),
                                Text(
                                  DateFormatter.dayLabel(order.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          StatusChip(status: order.status),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
