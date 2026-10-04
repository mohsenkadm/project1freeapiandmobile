import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/entities/app_settings.dart';

class SaerhaApp extends ConsumerWidget {
  const SaerhaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = switch (settingsAsync.asData?.value.themeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.dark || null => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final safeInsets = media.viewInsets.copyWith(
          left: media.viewInsets.left.clamp(0, double.infinity),
          top: media.viewInsets.top.clamp(0, double.infinity),
          right: media.viewInsets.right.clamp(0, double.infinity),
          bottom: media.viewInsets.bottom.clamp(0, double.infinity),
        );
        return MediaQuery(
          data: media.copyWith(
            viewInsets: safeInsets,
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: kIsWeb ? 1.2 : 1.4,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      routerConfig: router,
    );
  }
}
