import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreference { system, light, dark }

enum AccentColor { default_, purple, green, orange }

enum FontFamily { default_, roboto, poppins, montserrat }

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _accentKey = 'accent_color';
  static const String _fontKey = 'font_family';

  late SharedPreferences _prefs;
  ThemePreference _themePreference = ThemePreference.system;
  AccentColor _accentColor = AccentColor.default_;
  FontFamily _fontFamily = FontFamily.default_;
  FontFamily get fontFamily => _fontFamily;

  // Add these getters
  ThemePreference get themePreference => _themePreference;
  AccentColor get accentColor => _accentColor;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      // Load theme preference with default as system (0)
      final themeIndex = _prefs.getInt(_themeKey) ?? 0;
      _themePreference = ThemePreference.values[themeIndex];

      // Load accent color with default as default_ (0)
      final accentIndex = _prefs.getInt(_accentKey) ?? 0;
      _accentColor = AccentColor.values[accentIndex];

      // Load font family with default as default_ (0)
      final fontIndex = _prefs.getInt(_fontKey) ?? 0;
      _fontFamily = FontFamily.values[fontIndex];
    } catch (e) {
      // If there's any error, reset to defaults
      _themePreference = ThemePreference.system;
      _accentColor = AccentColor.default_;
      _fontFamily = FontFamily.default_;

      // Clear any corrupted preferences
      await _prefs.remove(_themeKey);
      await _prefs.remove(_accentKey);
      await _prefs.remove(_fontKey);
    }
    notifyListeners();
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    _themePreference = preference;
    await _prefs.setInt(_themeKey, preference.index);
    notifyListeners();
  }

  Future<void> setAccentColor(AccentColor color) async {
    _accentColor = color;
    await _prefs.setInt(_accentKey, color.index);
    notifyListeners();
  }

  Future<void> setFontFamily(FontFamily font) async {
    _fontFamily = font;
    await _prefs.setInt(_fontKey, font.index);
    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_themePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  bool isDark(BuildContext context) {
    return themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
  }
}
