import 'dart:async';

import '../../../../core/storage/hive_storage.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/cash_count.dart';
import '../../domain/repositories/cash_repository.dart';

class HiveCashRepository implements CashRepository {
  HiveCashRepository(this._storage);

  final HiveStorage _storage;
  final _controller = StreamController<void>.broadcast();

  void _notify() => _controller.add(null);

  String _key(DateTime date) => DateFormatter.dayKey(date);

  @override
  Future<void> clearAll() async {
    await _storage.cashCounts.clear();
    _notify();
  }

  @override
  Future<void> deleteByDate(DateTime date) async {
    await _storage.cashCounts.delete(_key(date));
    _notify();
  }

  @override
  Future<List<CashCount>> getAll() async {
    final items = <CashCount>[];
    for (final raw in _storage.cashCounts.values) {
      final map = _storage.decode(raw);
      if (map == null) continue;
      items.add(CashCount.fromJson(map));
    }
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<CashCount?> getByDate(DateTime date) async {
    final raw = _storage.cashCounts.get(_key(date));
    final map = _storage.decode(raw);
    if (map == null) return null;
    return CashCount.fromJson(map);
  }

  @override
  Future<void> save(CashCount cashCount) async {
    await _storage.cashCounts.put(
      _key(cashCount.date),
      _storage.encode(cashCount.toJson()),
    );
    _notify();
  }

  @override
  Stream<CashCount?> watchByDate(DateTime date) async* {
    yield await getByDate(date);
    await for (final _ in _controller.stream) {
      yield await getByDate(date);
    }
  }
}
