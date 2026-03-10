import 'package:flutter/material.dart';

/// Application Color Constants
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF10B981);
  static const Color primaryVariant = Color(0xFF059669);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFFF59E0B);

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF111827);
  static const Color secondaryLight = Color(0xFF3B82F6);
  static const Color errorLight = Color(0xFFEF4444);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color cardBackgroundDark = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFF9FAFB);
  static const Color primaryDark = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF3B82F6);
  static const Color errorDark = Color(0xFFEF4444);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF10B981);
  static const Color gradientEnd = Color(0xFF3B82F6);

  // Common Colors
  static const Color green = Color(0xFF10B981);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF59E0B);
  static const Color red = Color(0xFFEF4444);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color error = Color(0xFFEF4444);

  // Legacy aliases for backward compatibility
  static Color get primaryLight => primary;
  static Color get surface => surfaceLight;
  static Color get background => backgroundLight;
  static Color get cardBackground => cardBackgroundLight;
  static Color get textPrimary => textPrimaryLight;
  static Color get textSecondary => textSecondaryLight;
}
