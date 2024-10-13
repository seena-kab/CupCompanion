// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Default locale

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  // Load the saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');

    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  // Set a new locale and save it to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }

  // Clear the saved locale (optional)
  Future<void> clearLocale() async {
    _locale = const Locale('en');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('languageCode');
  }
}