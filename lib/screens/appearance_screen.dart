import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../constants/app_theme.dart';
import 'dart:ui';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _selectedTheme = 'system';
  String _selectedColor = 'default';
  String _selectedFont = 'default';

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

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
                        const SizedBox(height: 24),
                        _buildFontSection(isDark),
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeCard(
                  'Light',
                  Iconsax.sun_1,
                  'Tema terang',
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeCard(
                  'Dark',
                  Iconsax.moon,
                  'Tema gelap',
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
      String value, IconData icon, String label, bool isDark) {
    final isSelected = value.toLowerCase() == _selectedTheme;
    return GestureDetector(
      onTap: () => setState(() => _selectedTheme = value.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.2)
              : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.blue
                  : (isDark ? Colors.white : Colors.black),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.blue
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
    final colors = [
      {'name': 'Default', 'color': Colors.blue},
      {'name': 'Purple', 'color': Colors.purple},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Orange', 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Warna Aksen', isDark),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: colors
              .map((color) => _buildColorOption(
                    (color['name'] as String).toLowerCase(),
                    color['color'] as Color,
                    isDark,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(String value, Color color, bool isDark) {
    final isSelected = value == _selectedColor;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = value),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: isSelected
              ? const Icon(Iconsax.link, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }

  Widget _buildFontSection(bool isDark) {
    final fonts = ['Default', 'Roboto', 'Poppins', 'Montserrat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Font', isDark),
        const SizedBox(height: 16),
        Column(
          children: fonts
              .map((font) => _buildFontOption(
                    font.toLowerCase(),
                    font,
                    isDark,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFontOption(String value, String label, bool isDark) {
    final isSelected = value == _selectedFont;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue.withOpacity(0.2)
            : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.blue
                : (isDark ? Colors.white : Colors.black),
          ),
        ),
        trailing: isSelected
            ? const Icon(Iconsax.tick_circle, color: Colors.blue)
            : null,
        onTap: () => setState(() => _selectedFont = value),
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
