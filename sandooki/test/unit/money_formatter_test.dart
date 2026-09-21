import 'package:flutter_test/flutter_test.dart';
import 'package:sandooki/core/utils/money_formatter.dart';

void main() {
  group('MoneyFormatter', () {
    test('formats iraqi dinar with separators', () {
      expect(MoneyFormatter.format(400000), '400,000 د.ع');
      expect(MoneyFormatter.format(1850000), '1,850,000 د.ع');
    });

    test('parses formatted input', () {
      expect(MoneyFormatter.parse('150,000'), 150000);
      expect(MoneyFormatter.parse(''), isNull);
    });

    test('showSign', () {
      expect(MoneyFormatter.format(150000, showSign: true), '+150,000 د.ع');
      expect(MoneyFormatter.format(-150000, showSign: true), '-150,000 د.ع');
    });
  });
}
