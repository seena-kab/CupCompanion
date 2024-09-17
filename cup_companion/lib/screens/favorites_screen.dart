// lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Placeholder for MapScreen
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.blueAccent,
      ),
      body: const Center(
        child: Text('Map view will be here.'),
      ),
    );
  }
}