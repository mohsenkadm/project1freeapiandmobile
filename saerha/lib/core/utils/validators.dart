import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

abstract final class Validators {
  static void requirePositiveAmount(num? value, {String field = 'المبلغ'}) {
    if (value == null || value <= 0) {
      throw ValidationException('أدخل $field صحيح.');
    }
  }

  static void requireNonNegative(num? value, {String field = 'المبلغ'}) {
    if (value == null || value < 0) {
      throw ValidationException('$field لا يمكن أن يكون سالباً.');
    }
  }

  static void requireValidMarginPercent(num? percent) {
    if (percent == null || percent < 0) {
      throw ValidationException('نسبة الربح غير صحيحة.');
    }
    if (percent >= 100) {
      throw ValidationException('نسبة الربح يجب أن تكون أقل من 100%.');
    }
    if (percent > AppConstants.maxMarginPercent) {
      throw ValidationException(
        'نسبة الربح يجب أن تكون ${AppConstants.maxMarginPercent.toInt()}% أو أقل.',
      );
    }
  }

  static String? amountError(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'أدخل سعر شراء صحيح.';
    final value = double.tryParse(raw.replaceAll(',', ''));
    if (value == null || value <= 0) return 'أدخل سعر شراء صحيح.';
    return null;
  }
}
