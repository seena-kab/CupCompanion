// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../theme/theme_notifier.dart'; // Import ThemeNotifier

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: themeNotifier.isNightMode ? Colors.black : Colors.blueAccent,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Night Mode'),
            value: themeNotifier.isNightMode,
            onChanged: (bool value) {
              themeNotifier.toggleTheme(value);
            },
            secondary: Icon(
              themeNotifier.isNightMode ? Icons.nightlight_round : Icons.wb_sunny,
              color: themeNotifier.isNightMode ? Colors.amberAccent : Colors.blueAccent,
            ),
          ),
          // Add more settings options here...
        ],
      ),
    );
  }
}