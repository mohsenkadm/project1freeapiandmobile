import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Formats money amounts for Arabic display: `12,500 د.ع`
abstract final class MoneyFormatter {
  static final NumberFormat _number = NumberFormat('#,##0.##', 'en_US');

  static String format(
    num amount, {
    String? currencySuffix,
    bool withCurrency = true,
  }) {
    final formatted = _number.format(amount);
    if (!withCurrency) return formatted;
    final suffix = currencySuffix ?? AppConstants.currencySuffix;
    return '$formatted $suffix';
  }

  static String percent(num value, {int decimals = 0}) {
    if (decimals <= 0) return '${value.round()}%';
    return '${value.toStringAsFixed(decimals)}%';
  }
}
