import 'dart:async';

import '../../../../core/storage/hive_storage.dart';
import '../../../calculator/domain/entities/pricing_calculation.dart';
import '../../domain/repositories/history_repository.dart';

class HiveHistoryRepository implements HistoryRepository {
  HiveHistoryRepository(this._storage);

  final HiveStorage _storage;
  final _controller = StreamController<List<PricingCalculation>>.broadcast();

  List<PricingCalculation> _readAll() {
    final items = <PricingCalculation>[];
    for (final raw in _storage.history.values) {
      final map = _storage.decode(raw);
      if (map == null) continue;
      items.add(PricingCalculation.fromJson(map));
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  void _emit() => _controller.add(_readAll());

  @override
  Future<void> add(PricingCalculation calculation) async {
    await _storage.history
        .put(calculation.id, _storage.encode(calculation.toJson()));
    _emit();
  }

  @override
  Future<void> clear() async {
    await _storage.history.clear();
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    await _storage.history.delete(id);
    _emit();
  }

  @override
  Future<List<PricingCalculation>> getAll() async => _readAll();

  @override
  Stream<List<PricingCalculation>> watchAll() async* {
    yield _readAll();
    yield* _controller.stream;
  }
}
