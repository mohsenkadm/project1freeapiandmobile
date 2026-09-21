import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getByDate(DateTime date);

  Future<List<Transaction>> getAll();

  Future<List<Transaction>> search({
    required DateTime date,
    String query = '',
    TransactionType? type,
  });

  Future<void> add(Transaction transaction);

  Future<void> update(Transaction transaction);

  Future<void> delete(String id);

  Future<void> clearAll();

  Stream<List<Transaction>> watchByDate(DateTime date);
}
