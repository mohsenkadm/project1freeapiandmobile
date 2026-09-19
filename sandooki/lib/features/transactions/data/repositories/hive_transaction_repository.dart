import 'dart:async';

import '../../../../core/storage/hive_storage.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class HiveTransactionRepository implements TransactionRepository {
  HiveTransactionRepository(this._storage);

  final HiveStorage _storage;
  final _controller = StreamController<void>.broadcast();

  void _notify() => _controller.add(null);

  @override
  Future<void> add(Transaction transaction) async {
    await _storage.transactions.put(
      transaction.id,
      _storage.encode(transaction.toJson()),
    );
    _notify();
  }

  @override
  Future<void> clearAll() async {
    await _storage.transactions.clear();
    _notify();
  }

  @override
  Future<void> delete(String id) async {
    await _storage.transactions.delete(id);
    _notify();
  }

  @override
  Future<List<Transaction>> getAll() async {
    final items = <Transaction>[];
    for (final raw in _storage.transactions.values) {
      final map = _storage.decode(raw);
      if (map == null) continue;
      items.add(Transaction.fromJson(map));
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<List<Transaction>> getByDate(DateTime date) async {
    final key = DateFormatter.dayKey(date);
    final all = await getAll();
    return all
        .where((tx) => DateFormatter.dayKey(tx.createdAt) == key)
        .toList();
  }

  @override
  Future<List<Transaction>> search({
    required DateTime date,
    String query = '',
    TransactionType? type,
  }) async {
    final items = await getByDate(date);
    final needle = query.trim().toLowerCase();
    return items.where((tx) {
      if (type != null && tx.type != type) return false;
      if (needle.isEmpty) return true;
      return tx.description.toLowerCase().contains(needle) ||
          tx.type.arabicLabel.contains(needle);
    }).toList();
  }

  @override
  Future<void> update(Transaction transaction) async {
    await _storage.transactions.put(
      transaction.id,
      _storage.encode(transaction.toJson()),
    );
    _notify();
  }

  @override
  Stream<List<Transaction>> watchByDate(DateTime date) async* {
    yield await getByDate(date);
    await for (final _ in _controller.stream) {
      yield await getByDate(date);
    }
  }
}
