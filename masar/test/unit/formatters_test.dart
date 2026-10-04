import 'package:flutter_test/flutter_test.dart';
import 'package:masar/core/utils/money_formatter.dart';
import 'package:masar/core/utils/phone_validator.dart';

void main() {
  test('MoneyFormatter formats IQD', () {
    expect(MoneyFormatter.format(1250000), '1,250,000 د.ع');
    expect(MoneyFormatter.format(0), '0 د.ع');
    expect(MoneyFormatter.parse('75,000'), 75000);
  });

  test('PhoneValidator accepts Iraqi mobiles', () {
    expect(PhoneValidator.isValid('07701234567'), isTrue);
    expect(PhoneValidator.isValid('+9647701234567'), isTrue);
    expect(PhoneValidator.isValid('123'), isFalse);
    expect(PhoneValidator.normalize('0770 123 4567'), '07701234567');
  });
}
