import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_preference';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _saveThemePreference(themeMode);
    notifyListeners();
  }
  
  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
  
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeValue = prefs.getString(_themePreferenceKey);
      
      if (themeValue != null) {
        if (themeValue == 'dark') {
          _themeMode = ThemeMode.dark;
        } else if (themeValue == 'light') {
          _themeMode = ThemeMode.light;
        } else {
          _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, use system default
      _themeMode = ThemeMode.system;
    }
  }
  
  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeValue;
      
      if (mode == ThemeMode.dark) {
        themeValue = 'dark';
      } else if (mode == ThemeMode.light) {
        themeValue = 'light';
      } else {
        themeValue = 'system';
      }
      
      await prefs.setString(_themePreferenceKey, themeValue);
    } catch (e) {
      // Ignore errors when saving preferences
    }
  }
}