import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _ready = true;
    } catch (e, st) {
      debugPrint('Notification init failed: $e\n$st');
      _ready = false;
    }
  }

  Future<void> scheduleOrderReminder({
    required bool enabled,
    int pendingProcessing = 0,
    int pendingDelivery = 0,
  }) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    if (!enabled) return;

    String body;
    if (pendingProcessing > 0 && pendingDelivery > 0) {
      body =
          'لديك $pendingProcessing طلبات تحتاج تجهيز و$pendingDelivery بانتظار التسليم.';
    } else if (pendingProcessing > 0) {
      body = 'لديك $pendingProcessing طلبات تحتاج تجهيز.';
    } else if (pendingDelivery > 0) {
      body = 'لديك $pendingDelivery طلبات بانتظار التسليم.';
    } else {
      body = 'راجع طلباتك اليوم في مسار.';
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      AppConstants.notificationHour,
      AppConstants.notificationMinute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      1,
      'تذكير مسار',
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
