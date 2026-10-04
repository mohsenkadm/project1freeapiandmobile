import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/entities/order_status.dart';

extension OrderStatusUi on OrderStatus {
  Color get color => AppColors.statusColor(storageValue);

  IconData get icon {
    switch (this) {
      case OrderStatus.neu:
        return Icons.fiber_new_rounded;
      case OrderStatus.processing:
        return Icons.autorenew_rounded;
      case OrderStatus.ready:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.verified_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
