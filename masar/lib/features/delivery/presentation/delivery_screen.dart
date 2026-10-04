import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../orders/domain/entities/order_status.dart';

class DeliveryScreen extends ConsumerWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('التوصيل')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (orders) {
          final delivery = orders
              .where((o) => o.status == OrderStatus.outForDelivery)
              .toList();

          if (delivery.isEmpty) {
            return const EmptyState(
              title: 'ماكو طلبات قيد التوصيل حالياً',
              subtitle: 'عندما يصبح الطلب قيد التوصيل سيظهر هنا.',
              icon: Icons.local_shipping_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              120,
            ),
            itemCount: delivery.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final order = delivery[index];
              return AppCard(
                onTap: () => context.push('/orders/${order.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.displayNumber,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                        ),
                        const Spacer(),
                        Text(MoneyFormatter.format(order.total)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(order.customerName,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(order.customerPhone),
                    if (order.address.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(child: Text(order.address)),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final uri =
                                  Uri(scheme: 'tel', path: order.customerPhone);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            icon: const Icon(Icons.call_rounded),
                            label: const Text('اتصال'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: order.address.isEmpty
                                ? null
                                : () {
                                    context.showMessage(
                                      'العنوان: ${order.address}',
                                    );
                                  },
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('العنوان'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PrimaryButton(
                      label: 'تم التسليم',
                      icon: Icons.verified_rounded,
                      onPressed: () async {
                        try {
                          await ref.read(changeOrderStatusProvider).deliver(
                                order.id,
                              );
                          HapticFeedback.mediumImpact();
                          await refreshNotifications(ref);
                          if (context.mounted) {
                            context.showMessage('تم تسليم الطلب');
                          }
                        } on AppException catch (e) {
                          if (context.mounted) {
                            context.showMessage(e.message, isError: true);
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
