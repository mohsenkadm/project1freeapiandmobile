import 'package:equatable/equatable.dart';

import 'order_status.dart';

class OrderStatusHistory extends Equatable {
  const OrderStatusHistory({
    required this.id,
    required this.orderId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final OrderStatus status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'status': status.storageValue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      status: OrderStatus.fromStorage(json['status'] as String? ?? 'new'),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, orderId, status, createdAt];
}
