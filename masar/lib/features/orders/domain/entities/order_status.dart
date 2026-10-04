/// Lifecycle statuses for an order.
enum OrderStatus {
  /// Stored as `new` in JSON (`new` is a Dart reserved word).
  neu,
  processing,
  ready,
  outForDelivery,
  delivered,
  cancelled;

  /// Wire-friendly value used in storage/JSON.
  String get storageValue {
    switch (this) {
      case OrderStatus.neu:
        return 'new';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.outForDelivery:
        return 'outForDelivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String get labelAr {
    switch (this) {
      case OrderStatus.neu:
        return 'جديد';
      case OrderStatus.processing:
        return 'قيد التجهيز';
      case OrderStatus.ready:
        return 'جاهز';
      case OrderStatus.outForDelivery:
        return 'قيد التوصيل';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  String get timelineLabel {
    switch (this) {
      case OrderStatus.neu:
        return 'تم إنشاء الطلب';
      case OrderStatus.processing:
        return 'بدأ التجهيز';
      case OrderStatus.ready:
        return 'أصبح جاهزاً';
      case OrderStatus.outForDelivery:
        return 'قيد التوصيل';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'تم إلغاء الطلب';
    }
  }

  static OrderStatus fromStorage(String value) {
    switch (value) {
      case 'new':
        return OrderStatus.neu;
      case 'processing':
        return OrderStatus.processing;
      case 'ready':
        return OrderStatus.ready;
      case 'outForDelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.neu;
    }
  }

  OrderStatus? get nextActive {
    switch (this) {
      case OrderStatus.neu:
        return OrderStatus.processing;
      case OrderStatus.processing:
        return OrderStatus.ready;
      case OrderStatus.ready:
        return OrderStatus.outForDelivery;
      case OrderStatus.outForDelivery:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }

  static const List<OrderStatus> activeFlow = [
    OrderStatus.neu,
    OrderStatus.processing,
    OrderStatus.ready,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];
}
