import 'package:flutter_test/flutter_test.dart';
import 'package:dayni/core/database/app_database.dart';
import 'package:dayni/core/errors/failures.dart';
import 'package:dayni/features/customers/data/customer_repository_impl.dart';
import 'package:dayni/features/customers/domain/usecases/add_customer.dart';
import 'package:dayni/features/debts/data/debt_repository_impl.dart';
import 'package:dayni/features/debts/domain/usecases/add_debt.dart';
import 'package:dayni/features/payments/data/payment_repository_impl.dart';
import 'package:dayni/features/payments/domain/entities/payment.dart';
import 'package:dayni/features/payments/domain/usecases/record_payment.dart';
import 'package:dayni/features/statements/domain/build_statement.dart';

import '../helpers/sqlite_setup.dart';

void main() {
  late AppDatabase db;
  late CustomerRepositoryImpl customers;
  late DebtRepositoryImpl debts;
  late PaymentRepositoryImpl payments;

  setUpAll(ensureSqliteLoaded);

  setUp(() {
    db = AppDatabase.memory();
    customers = CustomerRepositoryImpl(db);
    debts = DebtRepositoryImpl(db);
    payments = PaymentRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('full debt lifecycle: Ahmed 1,000,000 then pay 250,000 => 750,000', () async {
    final addCustomer = AddCustomer(customers);
    final addDebt = AddDebt(debts);
    final recordPayment = RecordPayment(payments, customers.getBalance);
    final buildStatement = BuildStatement(customers, payments);

    final customer = await addCustomer(name: 'أحمد');
    await addDebt(
      customerId: customer.id,
      amount: 1000000,
      description: 'شراء بضاعة',
    );

    var balance = await customers.getBalance(customer.id);
    expect(balance.remaining, 1000000);

    await recordPayment(
      customerId: customer.id,
      amount: 250000,
      paymentMethod: PaymentMethod.cash,
    );

    balance = await customers.getBalance(customer.id);
    expect(balance.totalDebts, 1000000);
    expect(balance.totalPayments, 250000);
    expect(balance.remaining, 750000);

    await recordPayment(
      customerId: customer.id,
      amount: 250000,
      paymentMethod: PaymentMethod.transfer,
    );

    balance = await customers.getBalance(customer.id);
    expect(balance.remaining, 500000);

    final statement = await buildStatement(customer.id);
    expect(statement.customerName, 'أحمد');
    expect(statement.remaining, 500000);
    expect(statement.toShareText(), contains('أحمد'));
  });

  test('rejects payment greater than remaining', () async {
    final customer = await AddCustomer(customers)(name: 'سعد');
    await AddDebt(debts)(
      customerId: customer.id,
      amount: 100000,
      description: 'دين',
    );

    final recordPayment = RecordPayment(payments, customers.getBalance);
    expect(
      () => recordPayment(
        customerId: customer.id,
        amount: 150000,
        paymentMethod: PaymentMethod.cash,
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('rejects zero and requires customer name', () async {
    expect(
      () => AddCustomer(customers)(name: '  '),
      throwsA(isA<ValidationFailure>()),
    );

    final customer = await AddCustomer(customers)(name: 'محمد');
    expect(
      () => AddDebt(debts)(
        customerId: customer.id,
        amount: 0,
        description: 'x',
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('search finds customers by name and phone', () async {
    await AddCustomer(customers)(name: 'أحمد محمد', phone: '07701234567');
    await AddCustomer(customers)(name: 'سعد علي', phone: '07801112233');

    final byName = await customers.watchCustomers(query: 'أحمد').first;
    expect(byName.length, 1);
    expect(byName.first.customer.name, 'أحمد محمد');

    final byPhone = await customers.watchCustomers(query: '0780').first;
    expect(byPhone.length, 1);
    expect(byPhone.first.customer.name, 'سعد علي');
  });

  test('data persists across database reopen for in-memory same instance', () async {
    final customer = await AddCustomer(customers)(name: 'كريم');
    await AddDebt(debts)(
      customerId: customer.id,
      amount: 300000,
      description: 'دين',
    );
    final balance = await customers.getBalance(customer.id);
    expect(balance.remaining, 300000);
    expect(await customers.count(), 1);
  });
}
