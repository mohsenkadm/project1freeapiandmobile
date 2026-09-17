import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/add_customer.dart';
import '../../features/debts/domain/usecases/add_debt.dart';
import '../../features/payments/domain/entities/payment.dart';
import '../../features/payments/domain/usecases/record_payment.dart';

/// Seeds a realistic demo dataset for first-run / testing.
class DemoDataSeeder {
  DemoDataSeeder({
    required AddCustomer addCustomer,
    required AddDebt addDebt,
    required RecordPayment recordPayment,
    required CustomerRepository customers,
  })  : _addCustomer = addCustomer,
        _addDebt = addDebt,
        _recordPayment = recordPayment,
        _customers = customers;

  final AddCustomer _addCustomer;
  final AddDebt _addDebt;
  final RecordPayment _recordPayment;
  final CustomerRepository _customers;

  Future<void> seedIfEmpty() async {
    final count = await _customers.count();
    if (count > 0) return;
    await seed();
  }

  Future<void> seed() async {
    final ahmed = await _addCustomer(
      name: 'أحمد محمد',
      phone: '07701234567',
      notes: 'زبون دائم',
    );
    final saad = await _addCustomer(
      name: 'سعد علي',
      phone: '07801112233',
    );
    final karim = await _addCustomer(
      name: 'محمد كريم',
      phone: '07505556677',
    );

    await _addDebt(
      customerId: ahmed.id,
      amount: 1000000,
      description: 'شراء بضاعة',
    );
    await _recordPayment(
      customerId: ahmed.id,
      amount: 250000,
      paymentMethod: PaymentMethod.cash,
    );

    await _addDebt(
      customerId: saad.id,
      amount: 500000,
      description: 'مواد غذائية',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
    );
    await _recordPayment(
      customerId: saad.id,
      amount: 100000,
      paymentMethod: PaymentMethod.transfer,
    );

    await _addDebt(
      customerId: karim.id,
      amount: 750000,
      description: 'أجهزة',
    );
  }
}
