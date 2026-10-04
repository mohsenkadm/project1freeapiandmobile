import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

class HiveCustomerRepository implements CustomerRepository {
  HiveCustomerRepository(this._storage);

  final HiveStorage _storage;

  @override
  Future<List<Customer>> getAll() async {
    final list = <Customer>[];
    for (final raw in _storage.customers.values) {
      final json = _storage.decode(raw);
      if (json != null) list.add(Customer.fromJson(json));
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Future<Customer?> getById(String id) async {
    final json = _storage.decode(_storage.customers.get(id));
    if (json == null) return null;
    return Customer.fromJson(json);
  }

  @override
  Future<void> save(Customer customer) async {
    await _storage.customers.put(customer.id, _storage.encode(customer.toJson()));
  }

  @override
  Future<void> delete(String id) async {
    await _storage.customers.delete(id);
  }

  @override
  Future<void> clear() async {
    await _storage.customers.clear();
  }

  @override
  Stream<List<Customer>> watchAll() async* {
    yield await getAll();
    yield* _storage.customers.watch().asyncMap((_) => getAll());
  }
}
