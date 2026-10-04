import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.index = 0});

  final Order order;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/orders/${order.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.displayNumber,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const Spacer(),
              StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(order.customerName,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                MoneyFormatter.format(order.total),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              if (order.status == OrderStatus.outForDelivery ||
                  order.address.isNotEmpty)
                const Icon(Icons.local_shipping_outlined,
                    size: 18, color: AppColors.primary),
              if (order.status == OrderStatus.outForDelivery ||
                  order.address.isNotEmpty)
                const SizedBox(width: 6),
              Text(
                DateFormatter.dayLabel(order.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: (35 * index).ms)
        .fadeIn()
        .slideY(begin: 0.08);
  }
}
