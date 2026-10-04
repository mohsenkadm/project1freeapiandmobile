import 'package:flutter_test/flutter_test.dart';
import 'package:dayni/core/database/app_database.dart';
import 'package:dayni/core/demo/demo_data_seeder.dart';
import 'package:dayni/features/customers/data/customer_repository_impl.dart';
import 'package:dayni/features/customers/domain/usecases/add_customer.dart';
import 'package:dayni/features/debts/data/debt_repository_impl.dart';
import 'package:dayni/features/debts/domain/usecases/add_debt.dart';
import 'package:dayni/features/payments/data/payment_repository_impl.dart';
import 'package:dayni/features/payments/domain/usecases/record_payment.dart';

import '../helpers/sqlite_setup.dart';

void main() {
  setUpAll(ensureSqliteLoaded);

  test('demo seeder creates Ahmed with remaining 750000', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final customers = CustomerRepositoryImpl(db);
    final debts = DebtRepositoryImpl(db);
    final payments = PaymentRepositoryImpl(db);
    final seeder = DemoDataSeeder(
      addCustomer: AddCustomer(customers),
      addDebt: AddDebt(debts),
      recordPayment: RecordPayment(payments, customers.getBalance),
      customers: customers,
    );

    await seeder.seed();
    expect(await customers.count(), 3);
    final items = await customers.watchCustomers(query: 'أحمد').first;
    expect(items, isNotEmpty);
    expect(items.first.balance.remaining, 750000);

    await seeder.seedIfEmpty();
    expect(await customers.count(), 3);
  });
}
