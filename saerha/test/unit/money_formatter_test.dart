import 'package:flutter_test/flutter_test.dart';
import 'package:saerha/core/utils/money_formatter.dart';

void main() {
  test('formats with thousands separator and currency', () {
    expect(MoneyFormatter.format(12500), '12,500 د.ع');
  });

  test('formats decimals', () {
    expect(MoneyFormatter.format(12500.5, withCurrency: false), '12,500.5');
  });

  test('formats percent', () {
    expect(MoneyFormatter.percent(20), '20%');
    expect(MoneyFormatter.percent(20.5, decimals: 1), '20.5%');
  });
}
