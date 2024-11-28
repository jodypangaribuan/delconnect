import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightPrimary = primaryBlue;
  static const lightAccent = Color(0xFF60A5FA); // Blue-400
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF8FAFC); // Slate-50
  static const lightText = Color(0xFF1E293B); // Slate-800
  static const lightTextSecondary = Color(0xFF64748B); // Slate-500
  static const lightBorder = Color(0xFFE2E8F0); // Slate-200

  static const Color darkPrimary = primaryBlue;
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkText = Color(0xFFE5E5E5);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF2D2D2D);
  static const darkInput = Color(0xFF262626);

  static const pastelBlue = Color(0xFFBFDBFE); // Blue-200
  static const pastelIndigo = Color(0xFFC7D2FE); // Indigo-200
  static const pastelSky = Color(0xFFBAE6FD); // Sky-200

  static const gradientLight = [
    Color(0xFFEFF6FF), // Blue-50
    Color(0xFFDBEAFE), // Blue-100
  ];

  static final gradientDark = [
    const Color(0xFF121212),
    const Color(0xFF1E1E1E),
  ];

  static const Color primaryBlue = Color(0xFF107CC4);

  static final elevatedCard = BoxDecoration(
    color: lightBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: lightBorder),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      )
    ],
  );

  static final elevatedCardDark = BoxDecoration(
    color: darkSurface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: darkBorder),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      )
    ],
  );

  static const textStyleHeading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const textStyleSubheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const textStyleLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    // ...add other light theme configurations
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    // ...add other dark theme configurations
  );
}
