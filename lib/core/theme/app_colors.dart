import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color accent = Color(0xFF00897B);
}

extension AppSchemeColors on ColorScheme {
  Color get success => brightness == Brightness.dark
      ? const Color(0xFF81C784)
      : const Color(0xFF2E7D32);

  Color get successContainer => brightness == Brightness.dark
      ? const Color(0xFF214D2F)
      : const Color(0xFFC8E6C9);

  Color get warning => brightness == Brightness.dark
      ? const Color(0xFFFFB74D)
      : const Color(0xFFEF6C00);

  Color get warningContainer => brightness == Brightness.dark
      ? const Color(0xFF5C3A13)
      : const Color(0xFFFFE0B2);
}