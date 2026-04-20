import 'package:flutter/material.dart';

/// Telegram-style color palette
abstract class AppColors {
  // Primary
  static const Color primary = Color(0xFF2AABEE);
  static const Color primaryDark = Color(0xFF1A96D4);

  // Background
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF17212B);

  // Surface
  static const Color surfaceLight = Color(0xFFF1F1F1);
  static const Color surfaceDark = Color(0xFF232E3C);

  // Chat bubble
  static const Color bubbleOutgoing = Color(0xFFEFFAE1);
  static const Color bubbleOutgoingDark = Color(0xFF2B5278);
  static const Color bubbleIncoming = Color(0xFFFFFFFF);
  static const Color bubbleIncomingDark = Color(0xFF182533);

  // Text
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF707579);
  static const Color textSecondaryDark = Color(0xFF8D9BA8);

  // Divider
  static const Color dividerLight = Color(0xFFE4E4E4);
  static const Color dividerDark = Color(0xFF0E1621);

  // Online indicator
  static const Color online = Color(0xFF4DCD5E);

  // Error
  static const Color error = Color(0xFFE53935);

  // Transparent
  static const Color transparent = Colors.transparent;
}
