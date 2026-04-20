import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static const String _fontFamily = 'Roboto';

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Chat-specific
  static const TextStyle chatName = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );

  static const TextStyle chatPreview = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );

  static const TextStyle timestamp = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );
}
