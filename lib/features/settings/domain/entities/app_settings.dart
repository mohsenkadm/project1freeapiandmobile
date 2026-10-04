import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.currency = 'IQD',
    this.localeCode = 'ar',
    this.remindersEnabled = false,
    this.onboardingDone = false,
    this.dismissedQaidBanner = false,
  });

  final ThemeMode themeMode;
  final String currency;
  final String localeCode;
  final bool remindersEnabled;
  final bool onboardingDone;
  final bool dismissedQaidBanner;

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? localeCode,
    bool? remindersEnabled,
    bool? onboardingDone,
    bool? dismissedQaidBanner,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      localeCode: localeCode ?? this.localeCode,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      dismissedQaidBanner: dismissedQaidBanner ?? this.dismissedQaidBanner,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        currency,
        localeCode,
        remindersEnabled,
        onboardingDone,
        dismissedQaidBanner,
      ];
}
