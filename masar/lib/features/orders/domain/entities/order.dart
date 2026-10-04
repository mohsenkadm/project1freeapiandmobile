import 'package:equatable/equatable.dart';

import 'order_item.dart';
import 'order_status.dart';
import 'order_status_history.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedCost,
    this.estimatedProfit,
    this.address = '',
    this.notes = '',
    this.history = const [],
  });

  final String id;
  final int orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final double paidAmount;
  final double remainingAmount;
  final double? estimatedCost;
  final double? estimatedProfit;
  final OrderStatus status;
  final String address;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderStatusHistory> history;

  String get displayNumber => '#$orderNumber';

  bool get hasEstimatedProfit => estimatedProfit != null;

  bool get isDelivery =>
      status == OrderStatus.outForDelivery || address.trim().isNotEmpty;

  Order copyWith({
    String? id,
    int? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    double? deliveryFee,
    double? total,
    double? paidAmount,
    double? remainingAmount,
    double? estimatedCost,
    double? estimatedProfit,
    OrderStatus? status,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderStatusHistory>? history,
    bool clearEstimated = false,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      estimatedCost:
          clearEstimated ? null : (estimatedCost ?? this.estimatedCost),
      estimatedProfit:
          clearEstimated ? null : (estimatedProfit ?? this.estimatedProfit),
      status: status ?? this.status,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'deliveryFee': deliveryFee,
        'total': total,
        'paidAmount': paidAmount,
        'remainingAmount': remainingAmount,
        'estimatedCost': estimatedCost,
        'estimatedProfit': estimatedProfit,
        'status': status.storageValue,
        'address': address,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'history': history.map((e) => e.toJson()).toList(),
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: (json['orderNumber'] as num).toInt(),
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      estimatedProfit: (json['estimatedProfit'] as num?)?.toDouble(),
      status: OrderStatus.fromStorage(json['status'] as String? ?? 'new'),
      address: json['address'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      history: (json['history'] as List<dynamic>? ?? [])
          .map(
            (e) => OrderStatusHistory.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        customerName,
        customerPhone,
        items,
        subtotal,
        discount,
        deliveryFee,
        total,
        paidAmount,
        remainingAmount,
        estimatedCost,
        estimatedProfit,
        status,
        address,
        notes,
        createdAt,
        updatedAt,
        history,
      ];
}
