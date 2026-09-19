import '../entities/cash_count.dart';

abstract class CashRepository {
  Future<CashCount?> getByDate(DateTime date);

  Future<List<CashCount>> getAll();

  Future<void> save(CashCount cashCount);

  Future<void> deleteByDate(DateTime date);

  Future<void> clearAll();

  Stream<CashCount?> watchByDate(DateTime date);
}
