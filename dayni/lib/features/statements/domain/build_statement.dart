import 'customer_statement.dart';
import '../../customers/domain/repositories/customer_repository.dart';
import '../../payments/domain/repositories/payment_repository.dart';
import '../../../core/errors/failures.dart';

class BuildStatement {
  BuildStatement(this._customers, this._payments);

  final CustomerRepository _customers;
  final PaymentRepository _payments;

  Future<CustomerStatement> call(String customerId) async {
    final customer = await _customers.getById(customerId);
    if (customer == null) {
      throw const NotFoundFailure('الزبون غير موجود');
    }
    final balance = await _customers.getBalance(customerId);
    final lastPayment = await _payments.getLastPayment(customerId);

    return CustomerStatement(
      customerName: customer.name,
      totalDebt: balance.totalDebts,
      paid: balance.totalPayments,
      remaining: balance.remaining,
      lastPaymentAmount: lastPayment?.amount,
    );
  }
}
