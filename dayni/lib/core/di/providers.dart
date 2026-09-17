import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/backup_service.dart';
import '../services/reminder_service.dart';
import '../../features/ads/data/local_qaid_ad_service.dart';
import '../../features/ads/domain/services/ad_service.dart';
import '../../features/customers/data/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/add_customer.dart';
import '../../features/dashboard/data/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/debts/data/debt_repository_impl.dart';
import '../../features/debts/domain/repositories/debt_repository.dart';
import '../../features/debts/domain/usecases/add_debt.dart';
import '../../features/payments/data/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/payments/domain/usecases/record_payment.dart';
import '../../features/reports/data/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/settings/data/settings_repository_impl.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/statements/domain/build_statement.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(appDatabaseProvider));
});

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepositoryImpl(ref.watch(appDatabaseProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(appDatabaseProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(appDatabaseProvider));
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(appDatabaseProvider));
});

final adServiceProvider = Provider<AdService>((ref) {
  return LocalQaidAdService(
    ref.watch(appDatabaseProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return NoOpReminderService();
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return ComingSoonBackupService();
});

final addCustomerProvider = Provider<AddCustomer>((ref) {
  return AddCustomer(ref.watch(customerRepositoryProvider));
});

final addDebtProvider = Provider<AddDebt>((ref) {
  return AddDebt(ref.watch(debtRepositoryProvider));
});

final recordPaymentProvider = Provider<RecordPayment>((ref) {
  final customers = ref.watch(customerRepositoryProvider);
  return RecordPayment(
    ref.watch(paymentRepositoryProvider),
    customers.getBalance,
  );
});

final buildStatementProvider = Provider<BuildStatement>((ref) {
  return BuildStatement(
    ref.watch(customerRepositoryProvider),
    ref.watch(paymentRepositoryProvider),
  );
});

final settingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});
