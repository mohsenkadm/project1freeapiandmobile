import '../../../transactions/domain/entities/transaction.dart';

/// Pure calculation of expected cash drawer balance.
class CalculateExpectedBalance {
  const CalculateExpectedBalance();

  double call({
    required double openingBalance,
    required Iterable<Transaction> transactions,
  }) {
    var sales = 0.0;
    var expenses = 0.0;
    var payments = 0.0;
    var withdrawals = 0.0;

    for (final tx in transactions) {
      final amount = tx.amount.abs();
      switch (tx.type) {
        case TransactionType.sale:
          sales += amount;
        case TransactionType.expense:
          expenses += amount;
        case TransactionType.payment:
          payments += amount;
        case TransactionType.withdrawal:
          withdrawals += amount;
      }
    }

    return openingBalance + sales - expenses - payments - withdrawals;
  }
}
