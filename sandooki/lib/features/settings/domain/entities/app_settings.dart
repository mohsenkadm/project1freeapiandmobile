import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default('محلي') String shopName,
    @Default('د.ع') String currencySuffix,
    @Default(0.0) double openingBalance,
    @Default(AppThemeMode.dark) AppThemeMode themeMode,
    @Default(false) bool notificationsEnabled,
    @Default(false) bool onboardingDone,
    @Default(false) bool qaydPromoDismissed,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
