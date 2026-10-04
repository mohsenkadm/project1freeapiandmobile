import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> soft(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];
}
