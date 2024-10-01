// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/theme_notifier.dart';
import '../widgets/drink_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final favorites = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorites'),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.blueAccent,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text(
                'You have no favorite drinks.',
                style: TextStyle(
                  fontSize: 18,
                  color: themeNotifier.isNightMode
                      ? Colors.white70
                      : Colors.grey[700],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: favorites.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final drink = favorites[index];
                  return DrinkCard(
                    drink: drink,
                    index: index,
                    heroTagPrefix: 'favorites_', // Pass a unique prefix
                  );
                },
              ),
            ),
    );
  }
}