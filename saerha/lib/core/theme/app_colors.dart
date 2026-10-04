import 'package:flutter/material.dart';

/// Dark-premium FinTech color system for سعّرها.
abstract final class AppColors {
  static const Color background = Color(0xFF08131A);
  static const Color surface = Color(0xFF0D1D26);
  static const Color card = Color(0xFF132A34);

  static const Color primary = Color(0xFF00C7A5);
  static const Color primaryDark = Color(0xFF009E8A);
  static const Color accent = Color(0xFF7CFFCB);

  static const Color profit = Color(0xFF32D583);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF5B5B);

  static const Color textPrimary = Color(0xFFF7FAFC);
  static const Color textSecondary = Color(0xFF9BAAB3);

  static const Color backgroundLight = Color(0xFFF3F7F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFECF3F6);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF00C7A5), Color(0xFF009E8A)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1D26), Color(0xFF08131A), Color(0xFF061018)],
  );

  static const LinearGradient profitGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF0E3D3A), Color(0xFF132A34), Color(0xFF0B2A28)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF104038), Color(0xFF132A34), Color(0xFF0D1D26)],
  );
}
