import 'package:flutter/material.dart';

/// Dark-premium FinTech color system for صندوقي.
abstract final class AppColors {
  static const Color background = Color(0xFF0B1117);
  static const Color surface = Color(0xFF121B24);
  static const Color card = Color(0xFF17232D);

  static const Color primary = Color(0xFF00BFA6);
  static const Color primaryDark = Color(0xFF008F80);

  static const Color success = Color(0xFF2DD4A8);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFFF5C5C);

  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFA7B0BA);

  static const Color backgroundLight = Color(0xFFF4F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF0F4F8);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF00BFA6), Color(0xFF008F80)],
  );

  static const LinearGradient expectedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E3D3A), Color(0xFF17232D), Color(0xFF0B2A28)],
  );
}
