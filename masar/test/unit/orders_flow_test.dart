import 'package:flutter_test/flutter_test.dart';
import 'package:masar/features/orders/domain/entities/order.dart';
import 'package:masar/features/orders/domain/entities/order_item.dart';
import 'package:masar/features/orders/domain/entities/order_status.dart';
import 'package:masar/features/orders/domain/entities/order_status_history.dart';
import 'package:masar/features/orders/domain/usecases/change_order_status.dart';
import 'package:masar/features/orders/domain/usecases/compute_insights.dart';
import 'package:masar/features/orders/domain/usecases/create_order.dart';
import 'package:masar/features/orders/domain/usecases/filter_orders.dart';
import 'package:masar/features/orders/domain/repositories/order_repository.dart';
import 'package:masar/core/errors/app_exception.dart';

class _MemoryOrderRepository implements OrderRepository {
  final map = <String, Order>{};

  @override
  Future<void> clear() async => map.clear();

  @override
  Future<void> delete(String id) async => map.remove(id);

  @override
  Future<List<Order>> getAll() async => map.values.toList();

  @override
  Future<Order?> getById(String id) async => map[id];

  @override
  Future<void> save(Order order) async => map[order.id] = order;

  @override
  Stream<List<Order>> watchAll() async* {
    yield await getAll();
  }
}

Order _sample({
  String id = 'o1',
  int number = 1024,
  OrderStatus status = OrderStatus.neu,
  double total = 75000,
  String customerId = 'c1',
  String customerName = 'أحمد محمد',
  String phone = '07701234567',
  DateTime? createdAt,
}) {
  final now = createdAt ?? DateTime(2026, 10, 4, 15, 32);
  return Order(
    id: id,
    orderNumber: number,
    customerId: customerId,
    customerName: customerName,
    customerPhone: phone,
    items: const [
      OrderItem(
        productId: 'p1',
        productName: 'عطر X',
        quantity: 1,
        unitPrice: 75000,
        costPrice: 50000,
      ),
    ],
    subtotal: total,
    discount: 0,
    deliveryFee: 0,
    total: total,
    paidAmount: 0,
    remainingAmount: total,
    estimatedCost: 50000,
    estimatedProfit: 25000,
    status: status,
    createdAt: now,
    updatedAt: now,
    history: [
      OrderStatusHistory(
        id: 'h1',
        orderId: id,
        status: status,
        createdAt: now,
      ),
    ],
  );
}

void main() {
  test('CreateOrder builds order with NEW status and history', () async {
    final repo = _MemoryOrderRepository();
    final create = CreateOrder(repo);
    final order = await create(
      const CreateOrderInput(
        orderNumber: 1024,
        customerId: 'c1',
        customerName: 'أحمد محمد',
        customerPhone: '07701234567',
        items: [
          OrderItem(
            productId: 'p1',
            productName: 'عطر X',
            quantity: 1,
            unitPrice: 70000,
            costPrice: 50000,
          ),
        ],
        deliveryFee: 5000,
      ),
    );

    expect(order.displayNumber, '#1024');
    expect(order.status, OrderStatus.neu);
    expect(order.total, 75000);
    expect(order.history, hasLength(1));
    expect(order.estimatedProfit, 20000);
    expect(repo.map, hasLength(1));
  });

  test('ChangeOrderStatus advances and records history', () async {
    final repo = _MemoryOrderRepository();
    final order = _sample();
    await repo.save(order);
    final change = ChangeOrderStatus(repo);

    final processing = await change.advance(order.id);
    expect(processing.status, OrderStatus.processing);
    expect(processing.history, hasLength(2));

    final ready = await change.advance(order.id);
    expect(ready.status, OrderStatus.ready);

    final out = await change.advance(order.id);
    expect(out.status, OrderStatus.outForDelivery);

    final delivered = await change.deliver(order.id);
    expect(delivered.status, OrderStatus.delivered);
    expect(delivered.history.last.status, OrderStatus.delivered);
  });

  test('Cancel order works and blocks further changes', () async {
    final repo = _MemoryOrderRepository();
    await repo.save(_sample());
    final change = ChangeOrderStatus(repo);
    final cancelled = await change.cancel('o1');
    expect(cancelled.status, OrderStatus.cancelled);
    expect(
      () => change.advance('o1'),
      throwsA(isA<ValidationException>()),
    );
  });

  test('Filter and search orders', () {
    const filter = FilterOrders();
    final orders = [
      _sample(id: '1', number: 1024, total: 75000),
      _sample(
        id: '2',
        number: 1025,
        total: 120000,
        customerName: 'سارة',
        phone: '07709876543',
        status: OrderStatus.delivered,
        createdAt: DateTime(2026, 10, 3),
      ),
    ];

    final byName = filter(orders: orders, query: 'سارة');
    expect(byName, hasLength(1));
    expect(byName.first.orderNumber, 1025);

    final byNumber = filter(orders: orders, query: '1024');
    expect(byNumber, hasLength(1));

    final byStatus = filter(orders: orders, status: OrderStatus.delivered);
    expect(byStatus, hasLength(1));

    final highest =
        filter(orders: orders, sort: OrderSort.highestValue);
    expect(highest.first.total, 120000);
  });

  test('Customer totals and product counts', () {
    const customerTotals = ComputeCustomerTotals();
    const productCounts = ComputeProductOrderCounts();
    final orders = [
      _sample(id: '1', createdAt: DateTime(2026, 10, 1)),
      _sample(id: '2', number: 1025, total: 50000, createdAt: DateTime(2026, 10, 4)),
      _sample(
        id: '3',
        number: 1026,
        customerId: 'c2',
        status: OrderStatus.cancelled,
      ),
    ];

    final totals = customerTotals(orders, 'c1');
    expect(totals.orderCount, 2);
    expect(totals.totalValue, 125000);
    expect(totals.lastOrder?.id, '2');

    final counts = productCounts(orders);
    expect(counts['p1'], 2);
  });

  test('OrderStatus labels and next transitions', () {
    expect(OrderStatus.neu.labelAr, 'جديد');
    expect(OrderStatus.processing.labelAr, 'قيد التجهيز');
    expect(OrderStatus.ready.labelAr, 'جاهز');
    expect(OrderStatus.outForDelivery.labelAr, 'قيد التوصيل');
    expect(OrderStatus.delivered.labelAr, 'تم التسليم');
    expect(OrderStatus.cancelled.labelAr, 'ملغي');
    expect(OrderStatus.neu.nextActive, OrderStatus.processing);
    expect(OrderStatus.delivered.nextActive, isNull);
    expect(OrderStatus.fromStorage('new'), OrderStatus.neu);
  });
}
