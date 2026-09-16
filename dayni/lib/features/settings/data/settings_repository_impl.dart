import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/app_settings.dart';
import '../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  AppSettings _map(AppSettingsRow row) => AppSettings(
        themeMode: _parseTheme(row.themeMode),
        currency: row.currency,
        localeCode: row.localeCode,
        remindersEnabled: row.remindersEnabled,
        onboardingDone: row.onboardingDone,
        dismissedQaidBanner: row.dismissedQaidBanner,
      );

  ThemeMode _parseTheme(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  String _themeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  @override
  Future<AppSettings> getSettings() async {
    final row = await (_db.select(_db.appSettingsRows)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (row == null) {
      await _db.into(_db.appSettingsRows).insert(
            AppSettingsRowsCompanion.insert(),
          );
      return const AppSettings();
    }
    return _map(row);
  }

  @override
  Stream<AppSettings> watchSettings() {
    return (_db.select(_db.appSettingsRows)..where((t) => t.id.equals(1)))
        .watchSingleOrNull()
        .asyncMap((row) async {
      if (row == null) return getSettings();
      return _map(row);
    });
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    await _db.into(_db.appSettingsRows).insertOnConflictUpdate(
          AppSettingsRowsCompanion(
            id: const Value(1),
            themeMode: Value(_themeToString(settings.themeMode)),
            currency: Value(settings.currency),
            localeCode: Value(settings.localeCode),
            remindersEnabled: Value(settings.remindersEnabled),
            onboardingDone: Value(settings.onboardingDone),
            dismissedQaidBanner: Value(settings.dismissedQaidBanner),
          ),
        );
  }
}
