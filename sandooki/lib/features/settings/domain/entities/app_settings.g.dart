// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      shopName: json['shopName'] as String? ?? 'محلي',
      currencySuffix: json['currencySuffix'] as String? ?? 'د.ع',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      themeMode:
          $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
          AppThemeMode.dark,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      qaydPromoDismissed: json['qaydPromoDismissed'] as bool? ?? false,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'shopName': instance.shopName,
      'currencySuffix': instance.currencySuffix,
      'openingBalance': instance.openingBalance,
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'notificationsEnabled': instance.notificationsEnabled,
      'onboardingDone': instance.onboardingDone,
      'qaydPromoDismissed': instance.qaydPromoDismissed,
    };

const _$AppThemeModeEnumMap = {
  AppThemeMode.system: 'system',
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
};
