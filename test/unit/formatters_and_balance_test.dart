import 'package:flutter_test/flutter_test.dart';

import 'package:dayni/core/utils/money_formatter.dart';
import 'package:dayni/core/utils/date_formatter.dart';
import 'package:dayni/features/statements/domain/customer_statement.dart';
import 'package:dayni/features/customers/domain/entities/customer_balance.dart';

void main() {
  group('MoneyFormatter', () {
    test('formats Iraqi amounts with thousands separators', () {
      expect(MoneyFormatter.format(750000), '750,000 د.ع');
      expect(MoneyFormatter.format(1000000), '1,000,000 د.ع');
      expect(MoneyFormatter.format(0), '0 د.ع');
    });

    test('parses formatted and plain input', () {
      expect(MoneyFormatter.parse('750,000'), 750000);
      expect(MoneyFormatter.parse('250000'), 250000);
      expect(MoneyFormatter.parse(''), null);
      expect(MoneyFormatter.parse('abc'), null);
    });
  });

  group('DateFormatter', () {
    final now = DateTime(2026, 9, 16);

    test('relativeArabic today and days ago', () {
      expect(DateFormatter.relativeArabic(now, now: now), 'اليوم');
      expect(
        DateFormatter.relativeArabic(now.subtract(const Duration(days: 1)), now: now),
        'منذ يوم',
      );
      expect(
        DateFormatter.relativeArabic(now.subtract(const Duration(days: 3)), now: now),
        'منذ 3 أيام',
      );
    });

    test('due labels', () {
      expect(DateFormatter.dueLabel(now, now: now), 'مستحق اليوم');
      expect(
        DateFormatter.dueLabel(now.subtract(const Duration(days: 2)), now: now),
        'متأخر',
      );
      expect(
        DateFormatter.dueLabel(now.add(const Duration(days: 2)), now: now),
        'متبقي 2 يوم',
      );
    });
  });

  group('CustomerBalance', () {
    test('remaining is debts minus payments', () {
      const balance = CustomerBalance(
        customerId: '1',
        totalDebts: 1000000,
        totalPayments: 250000,
      );
      expect(balance.remaining, 750000);
      expect(balance.hasDebt, isTrue);
      expect(balance.isSettled, isFalse);
    });

    test('settled when remaining is zero with history', () {
      const balance = CustomerBalance(
        customerId: '1',
        totalDebts: 500000,
        totalPayments: 500000,
      );
      expect(balance.isSettled, isTrue);
      expect(balance.hasDebt, isFalse);
    });
  });

  group('CustomerStatement', () {
    test('builds shareable Arabic text', () {
      const statement = CustomerStatement(
        customerName: 'أحمد محمد',
        totalDebt: 1000000,
        paid: 250000,
        remaining: 750000,
        lastPaymentAmount: 250000,
      );
      final text = statement.toShareText();
      expect(text, contains('كشف حساب الزبون'));
      expect(text, contains('أحمد محمد'));
      expect(text, contains('1,000,000 د.ع'));
      expect(text, contains('750,000 د.ع'));
      expect(text, contains('شكراً لتعاملك معنا.'));
    });
  });
}
