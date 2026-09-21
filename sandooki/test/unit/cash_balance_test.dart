import 'package:flutter_test/flutter_test.dart';

import 'package:sandooki/features/cash_count/domain/usecases/calculate_difference.dart';
import 'package:sandooki/features/reports/domain/usecases/build_daily_cash_summary.dart';
import 'package:sandooki/features/transactions/domain/entities/transaction.dart';
import 'package:sandooki/features/transactions/domain/usecases/calculate_expected_balance.dart';

void main() {
  const expectedCalc = CalculateExpectedBalance();
  const differenceCalc = CalculateDifference();
  final builder = BuildDailyCashSummary(
    expectedBalance: expectedCalc,
    difference: differenceCalc,
  );

  Transaction tx({
    required TransactionType type,
    required double amount,
    DateTime? at,
  }) {
    final now = at ?? DateTime(2026, 9, 19, 10);
    return Transaction(
      id: '$type-$amount-${now.millisecondsSinceEpoch}',
      type: type,
      amount: amount,
      description: type.arabicLabel,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CalculateExpectedBalance', () {
    test('zero transactions returns opening balance', () {
      expect(
        expectedCalc(openingBalance: 100000, transactions: const []),
        100000,
      );
    });

    test('sales only', () {
      expect(
        expectedCalc(
          openingBalance: 0,
          transactions: [tx(type: TransactionType.sale, amount: 500000)],
        ),
        500000,
      );
    });

    test('expenses only', () {
      expect(
        expectedCalc(
          openingBalance: 200000,
          transactions: [tx(type: TransactionType.expense, amount: 50000)],
        ),
        150000,
      );
    });

    test('mixed transactions', () {
      final result = expectedCalc(
        openingBalance: 500000,
        transactions: [
          tx(type: TransactionType.sale, amount: 2000000),
          tx(type: TransactionType.expense, amount: 150000),
          tx(type: TransactionType.withdrawal, amount: 200000),
          tx(type: TransactionType.payment, amount: 300000),
        ],
      );
      expect(result, 1850000);
    });

    test('negative amounts are treated as absolute values', () {
      expect(
        expectedCalc(
          openingBalance: 0,
          transactions: [tx(type: TransactionType.sale, amount: -100)],
        ),
        100,
      );
    });

    test('large amounts', () {
      expect(
        expectedCalc(
          openingBalance: 100000000,
          transactions: [
            tx(type: TransactionType.sale, amount: 999999999),
          ],
        ),
        1099999999,
      );
    });
  });

  group('CalculateDifference', () {
    test('exact match', () {
      expect(
        differenceCalc(actualBalance: 1850000, expectedBalance: 1850000),
        0,
      );
    });

    test('shortage', () {
      expect(
        differenceCalc(actualBalance: 1700000, expectedBalance: 1850000),
        -150000,
      );
    });

    test('surplus', () {
      expect(
        differenceCalc(actualBalance: 2000000, expectedBalance: 1850000),
        150000,
      );
    });
  });

  group('BuildDailyCashSummary', () {
    test('builds summary with cash count shortage', () {
      final date = DateTime(2026, 9, 19);
      final summary = builder(
        date: date,
        openingBalance: 500000,
        transactions: [
          tx(type: TransactionType.sale, amount: 2000000),
          tx(type: TransactionType.expense, amount: 150000),
          tx(type: TransactionType.withdrawal, amount: 200000),
          tx(type: TransactionType.payment, amount: 300000),
        ],
        cashCount: null,
      );

      expect(summary.expectedBalance, 1850000);
      expect(summary.totalSales, 2000000);
      expect(summary.actualBalance, isNull);
      expect(summary.difference, isNull);
    });
  });
}
