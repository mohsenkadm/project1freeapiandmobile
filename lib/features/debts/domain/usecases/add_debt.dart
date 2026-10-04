import '../entities/debt.dart';
import '../repositories/debt_repository.dart';
import '../../../../core/errors/failures.dart';

class AddDebt {
  AddDebt(this._repository);

  final DebtRepository _repository;

  Future<Debt> call({
    required String customerId,
    required int amount,
    required String description,
    DateTime? dueDate,
    String? notes,
    DateTime? createdAt,
  }) async {
    if (customerId.isEmpty) {
      throw const ValidationFailure('يجب اختيار زبون');
    }
    if (amount <= 0) {
      throw const ValidationFailure('المبلغ يجب أن يكون أكبر من صفر');
    }
    final desc = description.trim().isEmpty ? 'دين' : description.trim();
    return _repository.addDebt(
      customerId: customerId,
      amount: amount,
      description: desc,
      dueDate: dueDate,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: createdAt,
    );
  }
}
