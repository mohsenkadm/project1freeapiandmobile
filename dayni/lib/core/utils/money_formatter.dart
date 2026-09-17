import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

abstract final class MoneyFormatter {
  static final NumberFormat _iqd = NumberFormat('#,###', 'en');

  /// Formats amounts for Iraqi users: `750,000 د.ع`
  static String format(num amount, {String suffix = AppConstants.currencySuffix}) {
    final value = amount.round();
    return '${_iqd.format(value)} $suffix';
  }

  static int? parse(String input) {
    final cleaned = input
        .replaceAll(RegExp(r'[^\d]'), '')
        .trim();
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }
}
