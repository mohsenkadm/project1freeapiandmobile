import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/phone_validator.dart';
import '../entities/order.dart';
import '../entities/order_item.dart';
import '../entities/order_status.dart';
import '../entities/order_status_history.dart';
import '../repositories/order_repository.dart';
import 'calculate_order_totals.dart';

class CreateOrderInput {
  const CreateOrderInput({
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    this.discount = 0,
    this.deliveryFee = 0,
    this.paidAmount = 0,
    this.address = '',
    this.notes = '',
  });

  final int orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double discount;
  final double deliveryFee;
  final double paidAmount;
  final String address;
  final String notes;
}

class CreateOrder {
  CreateOrder(this._repository, {CalculateOrderTotals? calculator})
      : _calculator = calculator ?? const CalculateOrderTotals();

  final OrderRepository _repository;
  final CalculateOrderTotals _calculator;
  final _uuid = const Uuid();

  Future<Order> call(CreateOrderInput input) async {
    if (input.customerId.trim().isEmpty || input.customerName.trim().isEmpty) {
      throw const ValidationException('اختيار الزبون مطلوب.');
    }
    if (!PhoneValidator.isValid(input.customerPhone)) {
      throw const ValidationException('رقم الهاتف غير صالح.');
    }

    final totals = _calculator(
      items: input.items,
      discount: input.discount,
      deliveryFee: input.deliveryFee,
      paidAmount: input.paidAmount,
    );

    final now = DateTime.now();
    final id = _uuid.v4();
    final order = Order(
      id: id,
      orderNumber: input.orderNumber,
      customerId: input.customerId,
      customerName: input.customerName.trim(),
      customerPhone: PhoneValidator.normalize(input.customerPhone),
      items: List.unmodifiable(input.items),
      subtotal: totals.subtotal,
      discount: totals.discount,
      deliveryFee: totals.deliveryFee,
      total: totals.total,
      paidAmount: totals.paidAmount,
      remainingAmount: totals.remainingAmount,
      estimatedCost: totals.estimatedCost,
      estimatedProfit: totals.estimatedProfit,
      status: OrderStatus.neu,
      address: input.address.trim(),
      notes: input.notes.trim(),
      createdAt: now,
      updatedAt: now,
      history: [
        OrderStatusHistory(
          id: _uuid.v4(),
          orderId: id,
          status: OrderStatus.neu,
          createdAt: now,
        ),
      ],
    );

    await _repository.save(order);
    return order;
  }
}
