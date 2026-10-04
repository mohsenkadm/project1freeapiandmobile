import '../entities/order.dart';
import '../entities/order_status.dart';

enum OrderSort {
  newest,
  oldest,
  highestValue,
  lowestValue,
}

class FilterOrders {
  const FilterOrders();

  List<Order> call({
    required List<Order> orders,
    String query = '',
    OrderStatus? status,
    DateTime? from,
    DateTime? to,
    double? minTotal,
    double? maxTotal,
    String? customerId,
    OrderSort sort = OrderSort.newest,
  }) {
    final q = query.trim().toLowerCase();
    var result = orders.where((order) {
      if (status != null && order.status != status) return false;
      if (customerId != null && order.customerId != customerId) return false;
      if (minTotal != null && order.total < minTotal) return false;
      if (maxTotal != null && order.total > maxTotal) return false;
      if (from != null && order.createdAt.isBefore(from)) return false;
      if (to != null && order.createdAt.isAfter(to)) return false;
      if (q.isEmpty) return true;
      return order.displayNumber.toLowerCase().contains(q) ||
          order.orderNumber.toString().contains(q) ||
          order.customerName.toLowerCase().contains(q) ||
          order.customerPhone.contains(q) ||
          order.items.any((i) => i.productName.toLowerCase().contains(q));
    }).toList();

    switch (sort) {
      case OrderSort.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case OrderSort.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case OrderSort.highestValue:
        result.sort((a, b) => b.total.compareTo(a.total));
      case OrderSort.lowestValue:
        result.sort((a, b) => a.total.compareTo(b.total));
    }
    return result;
  }
}
