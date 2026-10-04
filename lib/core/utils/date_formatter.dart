abstract final class DateFormatter {
  static String relativeArabic(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'منذ يوم';
    if (diff > 1) return 'منذ $diff أيام';
    if (diff == -1) return 'غداً';
    return 'خلال ${-diff} أيام';
  }

  static String shortDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  static String dueLabel(DateTime? dueDate, {DateTime? now}) {
    if (dueDate == null) return '';
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;

    if (diff == 0) return 'مستحق اليوم';
    if (diff < 0) return 'متأخر';
    if (diff == 1) return 'متبقي يوم';
    return 'متبقي $diff يوم';
  }

  static bool isOverdue(DateTime? dueDate, {DateTime? now}) {
    if (dueDate == null) return false;
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  static bool isDueToday(DateTime? dueDate, {DateTime? now}) {
    if (dueDate == null) return false;
    final current = now ?? DateTime.now();
    return dueDate.year == current.year &&
        dueDate.month == current.month &&
        dueDate.day == current.day;
  }
}
