import '../../../cash_count/domain/entities/cash_count.dart';
import '../../../cash_count/domain/usecases/calculate_difference.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/usecases/calculate_expected_balance.dart';
import '../entities/daily_cash_summary.dart';

/// Builds a daily cash summary from transactions and optional cash count.
class BuildDailyCashSummary {
  BuildDailyCashSummary({
    CalculateExpectedBalance? expectedBalance,
    CalculateDifference? difference,
  })  : _expectedBalance = expectedBalance ?? const CalculateExpectedBalance(),
        _difference = difference ?? const CalculateDifference();

  final CalculateExpectedBalance _expectedBalance;
  final CalculateDifference _difference;

  DailyCashSummary call({
    required DateTime date,
    required double openingBalance,
    required Iterable<Transaction> transactions,
    CashCount? cashCount,
  }) {
    var totalSales = 0.0;
    var totalExpenses = 0.0;
    var totalPayments = 0.0;
    var totalWithdrawals = 0.0;

    for (final tx in transactions) {
      final amount = tx.amount.abs();
      switch (tx.type) {
        case TransactionType.sale:
          totalSales += amount;
        case TransactionType.expense:
          totalExpenses += amount;
        case TransactionType.payment:
          totalPayments += amount;
        case TransactionType.withdrawal:
          totalWithdrawals += amount;
      }
    }

    final expected = _expectedBalance(
      openingBalance: openingBalance,
      transactions: transactions,
    );

    final actual = cashCount?.actualBalance;
    final diff = actual == null
        ? null
        : _difference(actualBalance: actual, expectedBalance: expected);

    return DailyCashSummary(
      date: DateTime(date.year, date.month, date.day),
      openingBalance: openingBalance,
      totalSales: totalSales,
      totalExpenses: totalExpenses,
      totalPayments: totalPayments,
      totalWithdrawals: totalWithdrawals,
      expectedBalance: expected,
      actualBalance: actual,
      difference: diff,
    );
  }
}
