import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class AppSettings extends Equatable {
  const AppSettings({
    this.shopName = 'نشاطي',
    this.phone = '',
    this.currencySuffix = AppConstants.currencySuffix,
    this.themeMode = AppThemeMode.dark,
    this.notificationsEnabled = false,
    this.onboardingDone = false,
    this.qaydPromoDismissed = false,
    this.nextOrderNumber = AppConstants.firstOrderNumber,
  });

  final String shopName;
  final String phone;
  final String currencySuffix;
  final AppThemeMode themeMode;
  final bool notificationsEnabled;
  final bool onboardingDone;
  final bool qaydPromoDismissed;
  final int nextOrderNumber;

  AppSettings copyWith({
    String? shopName,
    String? phone,
    String? currencySuffix,
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? onboardingDone,
    bool? qaydPromoDismissed,
    int? nextOrderNumber,
  }) {
    return AppSettings(
      shopName: shopName ?? this.shopName,
      phone: phone ?? this.phone,
      currencySuffix: currencySuffix ?? this.currencySuffix,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      qaydPromoDismissed: qaydPromoDismissed ?? this.qaydPromoDismissed,
      nextOrderNumber: nextOrderNumber ?? this.nextOrderNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'shopName': shopName,
        'phone': phone,
        'currencySuffix': currencySuffix,
        'themeMode': themeMode.name,
        'notificationsEnabled': notificationsEnabled,
        'onboardingDone': onboardingDone,
        'qaydPromoDismissed': qaydPromoDismissed,
        'nextOrderNumber': nextOrderNumber,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      shopName: json['shopName'] as String? ?? 'نشاطي',
      phone: json['phone'] as String? ?? '',
      currencySuffix:
          json['currencySuffix'] as String? ?? AppConstants.currencySuffix,
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.dark,
      ),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      qaydPromoDismissed: json['qaydPromoDismissed'] as bool? ?? false,
      nextOrderNumber: (json['nextOrderNumber'] as num?)?.toInt() ??
          AppConstants.firstOrderNumber,
    );
  }

  @override
  List<Object?> get props => [
        shopName,
        phone,
        currencySuffix,
        themeMode,
        notificationsEnabled,
        onboardingDone,
        qaydPromoDismissed,
        nextOrderNumber,
      ];
}
