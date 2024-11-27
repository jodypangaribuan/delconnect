import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF6C63FF);
  static const secondary = Color(0xFFFF6584);
  static const background = Color(0xFFF8F9FE);
  static const surface = Colors.white;
  static const text = Color(0xFF2D3142);
  static const textSecondary = Color(0xFF9CA3AF);

  static const gradientPrimary = [
    Color(0xFF6C63FF),
    Color(0xFF837DFF),
  ];

  static const gradientSecondary = [
    Color(0xFFFF6584),
    Color(0xFFFF8BA0),
  ];

  static BorderRadius borderRadius = BorderRadius.circular(16);
  static BorderRadius buttonRadius = BorderRadius.circular(12);

  static const cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    )
  ];
}
