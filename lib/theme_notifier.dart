import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier({required ThemeData initialTheme}) : _themeData = initialTheme;

  ThemeData get themeData => _themeData;

  void setThemeData(ThemeData newTheme) {
    _themeData = newTheme;
    notifyListeners();
  }
}