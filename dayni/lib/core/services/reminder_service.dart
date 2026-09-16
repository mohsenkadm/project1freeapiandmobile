/// Abstraction for future local notifications.
abstract class ReminderService {
  Future<void> initialize();
  Future<void> scheduleDueReminders();
  Future<void> cancelAll();
}

class NoOpReminderService implements ReminderService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleDueReminders() async {}

  @override
  Future<void> cancelAll() async {}
}
