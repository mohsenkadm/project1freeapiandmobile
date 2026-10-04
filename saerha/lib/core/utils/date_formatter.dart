import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static bool _ready = false;

  static Future<void> ensureInitialized() async {
    if (_ready) return;
    await initializeDateFormatting('ar');
    _ready = true;
  }

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String dayKey(DateTime value) {
    final d = dateOnly(value);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String relativeDayLabel(DateTime value) {
    final today = dateOnly(DateTime.now());
    final day = dateOnly(value);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'قبل يوم';
    if (diff == 2) return 'قبل يومين';
    if (diff < 7) return 'قبل $diff أيام';
    return DateFormat('d MMMM yyyy', 'ar').format(day);
  }

  static String shortDate(DateTime value) =>
      DateFormat('d/M/yyyy', 'ar').format(value);
}
