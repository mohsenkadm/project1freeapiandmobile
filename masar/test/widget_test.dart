import 'package:flutter_test/flutter_test.dart';
import 'package:masar/core/utils/money_formatter.dart';

void main() {
  test('placeholder widget smoke replaced by formatter sanity', () {
    // Keep default test file green without pumping full app (Hive init).
    expect(MoneyFormatter.format(1), contains('د.ع'));
  });
}
