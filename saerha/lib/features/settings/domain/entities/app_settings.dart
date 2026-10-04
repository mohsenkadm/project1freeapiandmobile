import 'package:equatable/equatable.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

enum MarginMode {
  /// هامش الربح من سعر البيع: price = cost / (1 - margin)
  sellingMargin,

  /// نسبة زيادة على التكلفة: price = cost * (1 + markup)
  costMarkup,
}

class AppSettings extends Equatable {
  const AppSettings({
    this.shopName = 'محلي',
    this.currencySuffix = 'د.ع',
    this.themeMode = AppThemeMode.dark,
    this.notificationsEnabled = false,
    this.onboardingDone = false,
    this.qaydPromoDismissed = false,
    this.marginMode = MarginMode.sellingMargin,
  });

  final String shopName;
  final String currencySuffix;
  final AppThemeMode themeMode;
  final bool notificationsEnabled;
  final bool onboardingDone;
  final bool qaydPromoDismissed;
  final MarginMode marginMode;

  AppSettings copyWith({
    String? shopName,
    String? currencySuffix,
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? onboardingDone,
    bool? qaydPromoDismissed,
    MarginMode? marginMode,
  }) {
    return AppSettings(
      shopName: shopName ?? this.shopName,
      currencySuffix: currencySuffix ?? this.currencySuffix,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      qaydPromoDismissed: qaydPromoDismissed ?? this.qaydPromoDismissed,
      marginMode: marginMode ?? this.marginMode,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      shopName: json['shopName'] as String? ?? 'محلي',
      currencySuffix: json['currencySuffix'] as String? ?? 'د.ع',
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.dark,
      ),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      qaydPromoDismissed: json['qaydPromoDismissed'] as bool? ?? false,
      marginMode: MarginMode.values.firstWhere(
        (e) => e.name == json['marginMode'],
        orElse: () => MarginMode.sellingMargin,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'shopName': shopName,
        'currencySuffix': currencySuffix,
        'themeMode': themeMode.name,
        'notificationsEnabled': notificationsEnabled,
        'onboardingDone': onboardingDone,
        'qaydPromoDismissed': qaydPromoDismissed,
        'marginMode': marginMode.name,
      };

  @override
  List<Object?> get props => [
        shopName,
        currencySuffix,
        themeMode,
        notificationsEnabled,
        onboardingDone,
        qaydPromoDismissed,
        marginMode,
      ];
}
