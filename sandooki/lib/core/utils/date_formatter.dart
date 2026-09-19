import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Arabic date helpers tailored for Iraqi shopkeepers.
abstract final class DateFormatter {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await initializeDateFormatting('ar');
    _initialized = true;
  }

  static String weekdayLong(DateTime date) {
    return DateFormat('EEEE', 'ar').format(date);
  }

  static String dayMonth(DateTime date) {
    return DateFormat('d MMMM', 'ar').format(date);
  }

  static String fullFriendly(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final label = target == today
        ? 'اليوم'
        : target == today.subtract(const Duration(days: 1))
            ? 'أمس'
            : weekdayLong(date);
    return '$label • ${weekdayLong(date)} ${dayMonth(date)}';
  }

  static String timeOfDay(DateTime date) {
    return DateFormat('HH:mm', 'en').format(date);
  }

  static String dayKey(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return DateFormat('yyyy-MM-dd').format(d);
  }

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'صباح الخير 👋';
    if (hour < 18) return 'مساء الخير 👋';
    return 'مساء الخير 👋';
  }
}
