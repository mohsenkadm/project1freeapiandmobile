import 'package:flutter/material.dart';

/// Dark-premium business color system for مسار.
abstract final class AppColors {
  static const Color background = Color(0xFF07131A);
  static const Color surface = Color(0xFF0F2029);
  static const Color card = Color(0xFF142B35);

  static const Color primary = Color(0xFF00BFA6);
  static const Color primaryDark = Color(0xFF008F80);
  static const Color accent = Color(0xFF6FFFE0);

  static const Color success = Color(0xFF28D17C);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF5B5B);
  static const Color info = Color(0xFF4DA3FF);

  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF9BAAB3);

  static const Color backgroundLight = Color(0xFFF3F6F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFEDF2F5);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF00BFA6), Color(0xFF008F80)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1C24), Color(0xFF07131A), Color(0xFF0C2430)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E3D3A), Color(0xFF142B35), Color(0xFF0B2A28)],
  );

  static Color statusColor(String status) {
    switch (status) {
      case 'new':
        return info;
      case 'processing':
        return warning;
      case 'ready':
        return accent;
      case 'outForDelivery':
        return primary;
      case 'delivered':
        return success;
      case 'cancelled':
        return danger;
      default:
        return textSecondary;
    }
  }
}
