import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/theme_provider.dart';
import 'dart:ui';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark ? AppTheme.gradientDark : AppTheme.gradientLight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildThemeSection(isDark),
                        const SizedBox(height: 24),
                        _buildAccentColorSection(isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.blue.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Iconsax.arrow_left, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Tampilan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 16),
          const Icon(Iconsax.colorfilter, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Sesuaikan Pengalaman Anda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tema', isDark),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildThemeCard(
                  'System',
                  Iconsax.mobile,
                  'Ikuti sistem',
                  isDark,
                  ThemePreference.system == themeProvider.themePreference,
                  () =>
                      themeProvider.setThemePreference(ThemePreference.system),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeCard(
                  'Light',
                  Iconsax.sun_1,
                  'Tema terang',
                  isDark,
                  ThemePreference.light == themeProvider.themePreference,
                  () => themeProvider.setThemePreference(ThemePreference.light),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeCard(
                  'Dark',
                  Iconsax.moon,
                  'Tema gelap',
                  isDark,
                  ThemePreference.dark == themeProvider.themePreference,
                  () => themeProvider.setThemePreference(ThemePreference.dark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(String value, IconData icon, String label, bool isDark,
      bool isSelected, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? themeProvider.getAccentColor().withOpacity(0.2)
              : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? themeProvider.getAccentColor()
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? themeProvider.getAccentColor()
                  : (isDark ? Colors.white : Colors.black),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? themeProvider.getAccentColor()
                    : (isDark ? Colors.white : Colors.black),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentColorSection(bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Warna Aksen', isDark),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: [
                  _buildAccentCard(
                    'Blue',
                    Colors.blue,
                    'Biru',
                    isDark,
                    AccentColor.blue == themeProvider.accentColor,
                    () => themeProvider.setAccentColor(AccentColor.blue),
                  ),
                  _buildAccentCard(
                    'Purple',
                    Colors.purple,
                    'Ungu',
                    isDark,
                    AccentColor.purple == themeProvider.accentColor,
                    () => themeProvider.setAccentColor(AccentColor.purple),
                  ),
                  _buildAccentCard(
                    'Green',
                    Colors.green,
                    'Hijau',
                    isDark,
                    AccentColor.green == themeProvider.accentColor,
                    () => themeProvider.setAccentColor(AccentColor.green),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAccentCard(
                    'Orange',
                    Colors.orange,
                    'Oranye',
                    isDark,
                    AccentColor.orange == themeProvider.accentColor,
                    () => themeProvider.setAccentColor(AccentColor.orange),
                  ),
                  _buildAccentCard(
                    'Red',
                    Colors.red,
                    'Merah',
                    isDark,
                    AccentColor.red == themeProvider.accentColor,
                    () => themeProvider.setAccentColor(AccentColor.red),
                  ),
                  _buildAccentCard(
                    'Pink',
                    Colors.pink,
                    'Merah Muda',
                    isDark,
                    AccentColor.pink == themeProvider.accentColor,
                    () => themeProvider.setAccentColor(AccentColor.pink),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccentCard(String value, Color color, String label, bool isDark,
      bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.2)
                : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? color
                      : (isDark ? Colors.white : Colors.black),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
