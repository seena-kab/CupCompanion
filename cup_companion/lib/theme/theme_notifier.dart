// theme/theme_notifier.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isNightMode;

  ThemeNotifier(this._isNightMode) {
    _loadFromPrefs();
  }

  bool get isNightMode => _isNightMode;

  toggleTheme(bool isNight) {
    _isNightMode = isNight;
    _saveToPrefs();
    notifyListeners();
  }

  _loadFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isNightMode = prefs.getBool('isNightMode') ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isNightMode', _isNightMode);
  }
}