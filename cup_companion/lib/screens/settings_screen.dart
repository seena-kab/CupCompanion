// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../providers/locale_provider.dart';
import 'package:cup_companion/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final appLocalizations = AppLocalizations.of(context)!; // Added '!' here

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.settings),
        backgroundColor: themeNotifier.isNightMode ? Colors.black : Colors.blueAccent,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(appLocalizations.nightMode),
            value: themeNotifier.isNightMode,
            onChanged: (bool value) {
              themeNotifier.toggleTheme(value);
            },
            secondary: Icon(
              themeNotifier.isNightMode ? Icons.nightlight_round : Icons.wb_sunny,
              color: themeNotifier.isNightMode ? Colors.amberAccent : Colors.blueAccent,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(appLocalizations.language),
            subtitle: Text(_getLanguageName(localeProvider.locale.languageCode, appLocalizations)),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          // Add more settings options here...
        ],
      ),
    );
  }

  String _getLanguageName(String code, AppLocalizations appLocalizations) {
    switch (code) {
      case 'en':
        return appLocalizations.english;
      case 'es':
        return appLocalizations.spanish;
      case 'ja':
        return appLocalizations.japanese;
      default:
        return appLocalizations.english;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final appLocalizations = AppLocalizations.of(context)!; // Added '!' here

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appLocalizations.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, appLocalizations.english, 'en'),
            _buildLanguageOption(context, appLocalizations.spanish, 'es'),
            _buildLanguageOption(context, appLocalizations.japanese, 'ja'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String languageName, String languageCode) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return RadioListTile<String>(
      value: languageCode,
      groupValue: localeProvider.locale.languageCode,
      title: Text(languageName),
      onChanged: (value) {
        localeProvider.setLocale(Locale(value!));
        Navigator.of(context).pop();
      },
    );
  }
}