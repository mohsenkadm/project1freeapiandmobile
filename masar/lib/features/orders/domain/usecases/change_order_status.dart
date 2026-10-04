import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_exception.dart';
import '../entities/order.dart';
import '../entities/order_status.dart';
import '../entities/order_status_history.dart';
import '../repositories/order_repository.dart';

class ChangeOrderStatus {
  ChangeOrderStatus(this._repository);

  final OrderRepository _repository;
  final _uuid = const Uuid();

  Future<Order> call({
    required String orderId,
    required OrderStatus status,
  }) async {
    final order = await _repository.getById(orderId);
    if (order == null) {
      throw const ValidationException('الطلب غير موجود.');
    }
    if (order.status == OrderStatus.cancelled) {
      throw const ValidationException('لا يمكن تعديل طلب ملغي.');
    }
    if (order.status == OrderStatus.delivered &&
        status != OrderStatus.cancelled) {
      throw const ValidationException('الطلب تم تسليمه مسبقاً.');
    }

    final now = DateTime.now();
    final updated = order.copyWith(
      status: status,
      updatedAt: now,
      history: [
        ...order.history,
        OrderStatusHistory(
          id: _uuid.v4(),
          orderId: order.id,
          status: status,
          createdAt: now,
        ),
      ],
    );
    await _repository.save(updated);
    return updated;
  }

  Future<Order> advance(String orderId) async {
    final order = await _repository.getById(orderId);
    if (order == null) {
      throw const ValidationException('الطلب غير موجود.');
    }
    final next = order.status.nextActive;
    if (next == null) {
      throw const ValidationException('لا توجد حالة تالية لهذا الطلب.');
    }
    return call(orderId: orderId, status: next);
  }

  Future<Order> cancel(String orderId) {
    return call(orderId: orderId, status: OrderStatus.cancelled);
  }

  Future<Order> deliver(String orderId) {
    return call(orderId: orderId, status: OrderStatus.delivered);
  }
}
