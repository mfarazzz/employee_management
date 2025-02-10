import 'package:flutter/material.dart';

class AppColors {
  static const int _primaryValue = 0xFF1DA1F2;

  static const MaterialColor customBlue = MaterialColor(
    _primaryValue,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(_primaryValue), // Main color
      600: Color(0xFF1A91DA),
      700: Color(0xFF1782C2),
      800: Color(0xFF146DA9),
      900: Color(0xFF0F5290),
    },
  );

  static const Color primaryColor = Color(0xFF1DA1F2); // Primary Button Color
  static const Color textPrimaryColor = Colors.white; // Button Text Color
}
