import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  bool _isDarkMode = true;
  Color _seedColor = Colors.blue;
  bool _useGlassmorphism = true;
  Locale? _locale;

  bool get isDarkMode => _isDarkMode;
  Color get seedColor => _seedColor;
  bool get useGlassmorphism => _useGlassmorphism;
  Locale? get locale => _locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    _useGlassmorphism = prefs.getBool('use_glassmorphism') ?? true;
    final colorValue = prefs.getInt('seed_color');
    if (colorValue != null) {
      _seedColor = Color(colorValue);
    }

    final languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove('language_code');
    } else {
      await prefs.setString('language_code', locale.languageCode);
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seed_color', color.value);
    notifyListeners();
  }

  Future<void> toggleGlassmorphism() async {
    _useGlassmorphism = !_useGlassmorphism;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_glassmorphism', _useGlassmorphism);
    notifyListeners();
  }

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: _isDarkMode
          ? Colors.black
          : const Color(0xFFF5F5F7),
      cardTheme: CardThemeData(
        elevation: _useGlassmorphism ? 0 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: _isDarkMode
            ? (_useGlassmorphism
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFF1E1E1E))
            : (_useGlassmorphism
                  ? Colors.black.withOpacity(0.02)
                  : Colors.white),
      ),
    );
  }
}
