import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static bool _ready = false;

  static Future<void> ensureInitialized() async {
    if (_ready) return;
    await initializeDateFormatting('ar');
    _ready = true;
  }

  static String dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) {
      return 'اليوم ${DateFormat('HH:mm').format(date)}';
    }
    if (target == today.subtract(const Duration(days: 1))) {
      return 'أمس ${DateFormat('HH:mm').format(date)}';
    }
    return DateFormat('d/M/yyyy HH:mm').format(date);
  }

  static String fullDate(DateTime date) {
    return DateFormat('EEEE d MMMM yyyy', 'ar').format(date);
  }

  static String timeOnly(DateTime date) => DateFormat('HH:mm').format(date);

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
