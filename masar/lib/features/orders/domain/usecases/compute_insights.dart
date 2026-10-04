import '../entities/order.dart';
import '../entities/order_status.dart';

class CustomerTotals {
  const CustomerTotals({
    required this.orderCount,
    required this.totalValue,
    this.lastOrder,
  });

  final int orderCount;
  final double totalValue;
  final Order? lastOrder;
}

class ComputeCustomerTotals {
  const ComputeCustomerTotals();

  CustomerTotals call(List<Order> orders, String customerId) {
    final customerOrders = orders
        .where((o) => o.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final total = customerOrders.fold<double>(0, (s, o) => s + o.total);
    return CustomerTotals(
      orderCount: customerOrders.length,
      totalValue: total,
      lastOrder: customerOrders.isEmpty ? null : customerOrders.first,
    );
  }
}

class ProductOrderCount {
  const ProductOrderCount(this.productId, this.count);

  final String productId;
  final int count;
}

class ComputeProductOrderCounts {
  const ComputeProductOrderCounts();

  Map<String, int> call(List<Order> orders) {
    final map = <String, int>{};
    for (final order in orders) {
      if (order.status == OrderStatus.cancelled) continue;
      for (final item in order.items) {
        map[item.productId] = (map[item.productId] ?? 0) + item.quantity;
      }
    }
    return map;
  }
}
