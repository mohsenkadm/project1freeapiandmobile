import '../../../customers/domain/entities/customer_balance.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';
import '../../../../core/errors/failures.dart';

class RecordPayment {
  RecordPayment(this._payments, this._getBalance);

  final PaymentRepository _payments;
  final Future<CustomerBalance> Function(String customerId) _getBalance;

  Future<Payment> call({
    required String customerId,
    required int amount,
    required PaymentMethod paymentMethod,
    String? debtId,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw const ValidationFailure('المبلغ يجب أن يكون أكبر من صفر');
    }

    final balance = await _getBalance(customerId);
    if (amount > balance.remaining) {
      throw const ValidationFailure('الدفعة أكبر من الدين المتبقي');
    }

    return _payments.addPayment(
      customerId: customerId,
      amount: amount,
      paymentMethod: paymentMethod,
      debtId: debtId,
      notes: notes,
    );
  }
}
