import 'dart:async';

import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class HiveOrderRepository implements OrderRepository {
  HiveOrderRepository(this._storage);

  final HiveStorage _storage;

  @override
  Future<List<Order>> getAll() async {
    final list = <Order>[];
    for (final raw in _storage.orders.values) {
      final json = _storage.decode(raw);
      if (json != null) list.add(Order.fromJson(json));
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Order?> getById(String id) async {
    final json = _storage.decode(_storage.orders.get(id));
    if (json == null) return null;
    return Order.fromJson(json);
  }

  @override
  Future<void> save(Order order) async {
    await _storage.orders.put(order.id, _storage.encode(order.toJson()));
  }

  @override
  Future<void> delete(String id) async {
    await _storage.orders.delete(id);
  }

  @override
  Future<void> clear() async {
    await _storage.orders.clear();
  }

  @override
  Stream<List<Order>> watchAll() async* {
    yield await getAll();
    yield* _storage.orders.watch().asyncMap((_) => getAll());
  }
}
