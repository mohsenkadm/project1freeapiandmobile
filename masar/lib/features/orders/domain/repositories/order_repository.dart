import '../entities/order.dart';
import '../entities/order_status.dart';

abstract class OrderRepository {
  Future<List<Order>> getAll();
  Future<Order?> getById(String id);
  Future<void> save(Order order);
  Future<void> delete(String id);
  Future<void> clear();
  Stream<List<Order>> watchAll();
}

extension OrderListX on List<Order> {
  List<Order> forDay(DateTime day) {
    return where(
      (o) =>
          o.createdAt.year == day.year &&
          o.createdAt.month == day.month &&
          o.createdAt.day == day.day,
    ).toList();
  }

  int countByStatus(OrderStatus status) =>
      where((o) => o.status == status).length;

  double get totalValue => fold<double>(0, (s, o) => s + o.total);
}
