import 'package:flutter/material.dart';

class AppTheme {
  static const lightPrimary = Color(0xFF3B82F6); // Blue-500
  static const lightAccent = Color(0xFF60A5FA); // Blue-400
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF8FAFC); // Slate-50
  static const lightText = Color(0xFF1E293B); // Slate-800
  static const lightTextSecondary = Color(0xFF64748B); // Slate-500
  static const lightBorder = Color(0xFFE2E8F0); // Slate-200

  static const darkPrimary = Color(0xFF60A5FA); // Blue-400
  static const darkAccent = Color(0xFF3B82F6); // Blue-500
  static const darkBackground = Color(0xFF0F172A); // Slate-900
  static const darkSurface = Color(0xFF1E293B); // Slate-800
  static const darkText = Color(0xFFF8FAFC); // Slate-50
  static const darkTextSecondary = Color(0xFF94A3B8); // Slate-400
  static const darkBorder = Color(0xFF334155); // Slate-700

  static const pastelBlue = Color(0xFFBFDBFE); // Blue-200
  static const pastelIndigo = Color(0xFFC7D2FE); // Indigo-200
  static const pastelSky = Color(0xFFBAE6FD); // Sky-200

  static const gradientLight = [
    Color(0xFFEFF6FF), // Blue-50
    Color(0xFFDBEAFE), // Blue-100
  ];

  static const gradientDark = [
    Color(0xFF1E293B), // Slate-800
    Color(0xFF0F172A), // Slate-900
  ];

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
}
