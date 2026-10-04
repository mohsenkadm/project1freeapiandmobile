import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Money formatting helpers for Iraqi Dinar display.
abstract final class MoneyFormatter {
  static final NumberFormat _iqd = NumberFormat('#,###', 'en');

  /// Formats amounts for Iraqi users: `750,000 د.ع`
  static String format(
    num amount, {
    String suffix = AppConstants.currencySuffix,
    bool showSign = false,
  }) {
    final value = amount.round();
    final absFormatted = _iqd.format(value.abs());
    if (!showSign) {
      return '$absFormatted $suffix';
    }
    if (value > 0) return '+$absFormatted $suffix';
    if (value < 0) return '-$absFormatted $suffix';
    return '$absFormatted $suffix';
  }

  static double? parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d.]'), '').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
}
