import 'package:flutter/material.dart';

/// Soft elevation for premium cards.
abstract final class AppShadows {
  static List<BoxShadow> soft({Color color = const Color(0x33000000)}) => [
        BoxShadow(
          color: color,
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
}
