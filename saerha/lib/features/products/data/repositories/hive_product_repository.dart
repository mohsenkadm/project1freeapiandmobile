import 'dart:async';

import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class HiveProductRepository implements ProductRepository {
  HiveProductRepository(this._storage);

  final HiveStorage _storage;
  final _controller = StreamController<List<Product>>.broadcast();

  List<Product> _readAll() {
    final items = <Product>[];
    for (final raw in _storage.products.values) {
      final map = _storage.decode(raw);
      if (map == null) continue;
      items.add(Product.fromJson(map));
    }
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  void _emit() => _controller.add(_readAll());

  @override
  Future<void> clear() async {
    await _storage.products.clear();
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    await _storage.products.delete(id);
    _emit();
  }

  @override
  Future<List<Product>> getAll() async => _readAll();

  @override
  Future<Product?> getById(String id) async {
    final raw = _storage.products.get(id);
    final map = _storage.decode(raw);
    if (map == null) return null;
    return Product.fromJson(map);
  }

  @override
  Future<void> save(Product product) async {
    await _storage.products.put(product.id, _storage.encode(product.toJson()));
    _emit();
  }

  @override
  Stream<List<Product>> watchAll() async* {
    yield _readAll();
    yield* _controller.stream;
  }
}
