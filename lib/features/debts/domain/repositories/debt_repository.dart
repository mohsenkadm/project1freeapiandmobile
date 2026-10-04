import '../entities/debt.dart';

abstract class DebtRepository {
  Future<Debt> addDebt({
    required String customerId,
    required int amount,
    required String description,
    DateTime? dueDate,
    String? notes,
    DateTime? createdAt,
  });

  Future<List<Debt>> getByCustomer(String customerId);

  Stream<List<Debt>> watchRecent({int limit = 10});

  Future<Debt?> getById(String id);

  Future<void> deleteDebt(String id);
}
