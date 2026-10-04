import 'package:flutter/material.dart';

import '../../features/orders/domain/entities/order_status.dart';
import '../../features/orders/presentation/order_status_ui.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.labelAr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
