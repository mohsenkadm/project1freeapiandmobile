import '../entities/customer.dart';
import '../repositories/customer_repository.dart';
import '../../../../core/errors/failures.dart';

class AddCustomer {
  AddCustomer(this._repository);

  final CustomerRepository _repository;

  Future<Customer> call({
    required String name,
    String? phone,
    String? notes,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('اسم الزبون مطلوب');
    }
    return _repository.addCustomer(
      name: trimmed,
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );
  }
}
