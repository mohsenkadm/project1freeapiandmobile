import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class HiveProductRepository implements ProductRepository {
  HiveProductRepository(this._storage);

  final HiveStorage _storage;

  @override
  Future<List<Product>> getAll() async {
    final list = <Product>[];
    for (final raw in _storage.products.values) {
      final json = _storage.decode(raw);
      if (json != null) list.add(Product.fromJson(json));
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Future<Product?> getById(String id) async {
    final json = _storage.decode(_storage.products.get(id));
    if (json == null) return null;
    return Product.fromJson(json);
  }

  @override
  Future<void> save(Product product) async {
    await _storage.products.put(product.id, _storage.encode(product.toJson()));
  }

  @override
  Future<void> delete(String id) async {
    await _storage.products.delete(id);
  }

  @override
  Future<void> clear() async {
    await _storage.products.clear();
  }

  @override
  Stream<List<Product>> watchAll() async* {
    yield await getAll();
    yield* _storage.products.watch().asyncMap((_) => getAll());
  }
}
