import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/providers.dart';
import 'core/services/notification_service.dart';
import 'core/storage/hive_storage.dart';
import 'core/utils/date_formatter.dart';
import 'features/settings/data/repositories/hive_settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };

  await DateFormatter.ensureInitialized();

  final storage = HiveStorage();
  await storage.init();

  final notifications = NotificationService();
  await notifications.init();

  final settings = await HiveSettingsRepository(storage).get();
  if (settings.notificationsEnabled) {
    await notifications.scheduleDailyReminder(enabled: true);
  }

  runApp(
    ProviderScope(
      overrides: [
        hiveStorageProvider.overrideWithValue(storage),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const SandookiApp(),
    ),
  );
}
