import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cash_count/data/repositories/hive_cash_repository.dart';
import '../../features/cash_count/domain/repositories/cash_repository.dart';
import '../../features/cash_count/domain/usecases/calculate_difference.dart';
import '../../features/reports/domain/entities/daily_cash_summary.dart';
import '../../features/reports/domain/usecases/build_daily_cash_summary.dart';
import '../../features/settings/data/repositories/hive_settings_repository.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/transactions/data/repositories/hive_transaction_repository.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/calculate_expected_balance.dart';
import '../services/notification_service.dart';
import '../storage/hive_storage.dart';
import '../utils/date_formatter.dart';

final hiveStorageProvider = Provider<HiveStorage>((ref) {
  throw UnimplementedError('HiveStorage must be overridden in main');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService must be overridden in main');
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return HiveTransactionRepository(ref.watch(hiveStorageProvider));
});

final cashRepositoryProvider = Provider<CashRepository>((ref) {
  return HiveCashRepository(ref.watch(hiveStorageProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return HiveSettingsRepository(ref.watch(hiveStorageProvider));
});

final calculateExpectedBalanceProvider =
    Provider((ref) => const CalculateExpectedBalance());

final calculateDifferenceProvider =
    Provider((ref) => const CalculateDifference());

final buildDailyCashSummaryProvider = Provider((ref) {
  return BuildDailyCashSummary(
    expectedBalance: ref.watch(calculateExpectedBalanceProvider),
    difference: ref.watch(calculateDifferenceProvider),
  );
});

final settingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final transactionsForSelectedDateProvider =
    StreamProvider<List<Transaction>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(transactionRepositoryProvider).watchByDate(date);
});

final cashCountForSelectedDateProvider = StreamProvider((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(cashRepositoryProvider).watchByDate(date);
});

final dailySummaryProvider = Provider<AsyncValue<DailyCashSummary>>((ref) {
  final settings = ref.watch(settingsProvider);
  final transactions = ref.watch(transactionsForSelectedDateProvider);
  final cashCount = ref.watch(cashCountForSelectedDateProvider);
  final date = ref.watch(selectedDateProvider);
  final builder = ref.watch(buildDailyCashSummaryProvider);

  if (settings.isLoading || transactions.isLoading || cashCount.isLoading) {
    return const AsyncValue.loading();
  }

  if (settings.hasError) {
    return AsyncValue.error(settings.error!, settings.stackTrace!);
  }
  if (transactions.hasError) {
    return AsyncValue.error(transactions.error!, transactions.stackTrace!);
  }
  if (cashCount.hasError) {
    return AsyncValue.error(cashCount.error!, cashCount.stackTrace!);
  }

  final summary = builder(
    date: date,
    openingBalance: settings.requireValue.openingBalance,
    transactions: transactions.requireValue,
    cashCount: cashCount.requireValue,
  );
  return AsyncValue.data(summary);
});

final historySummariesProvider =
    FutureProvider<List<DailyCashSummary>>((ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).get();
  final txs = await ref.watch(transactionRepositoryProvider).getAll();
  final counts = await ref.watch(cashRepositoryProvider).getAll();
  final builder = ref.watch(buildDailyCashSummaryProvider);

  final dates = <String, DateTime>{};
  for (final tx in txs) {
    final d = DateFormatter.dateOnly(tx.createdAt);
    dates[DateFormatter.dayKey(d)] = d;
  }
  for (final c in counts) {
    final d = DateFormatter.dateOnly(c.date);
    dates[DateFormatter.dayKey(d)] = d;
  }

  // Always include today.
  final today = DateFormatter.dateOnly(DateTime.now());
  dates[DateFormatter.dayKey(today)] = today;

  final sorted = dates.values.toList()..sort((a, b) => b.compareTo(a));
  final countByDay = {
    for (final c in counts) DateFormatter.dayKey(c.date): c,
  };

  return [
    for (final date in sorted)
      builder(
        date: date,
        openingBalance: settings.openingBalance,
        transactions: txs.where(
          (tx) =>
              DateFormatter.dayKey(tx.createdAt) == DateFormatter.dayKey(date),
        ),
        cashCount: countByDay[DateFormatter.dayKey(date)],
      ),
  ];
});
