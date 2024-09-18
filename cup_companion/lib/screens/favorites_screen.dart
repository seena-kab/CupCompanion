// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../services/auth_services.dart'; // Ensure correct import path

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final AuthService _authService = AuthService();

  // List to store favorite drinks
  List<Map<String, String>> favoriteDrinks = [];

  @override
  void initState() {
    super.initState();
    fetchFavoriteDrinks();
  }

  // Fetch favorite drinks from the AuthService
  void fetchFavoriteDrinks() async {
    try {
      List<Map<String, String>> fetchedFavorites =
          await _authService.getFavoriteDrinks();
      setState(() {
        favoriteDrinks = fetchedFavorites;
      });
    } catch (e) {
      setState(() {
        favoriteDrinks = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.blueAccent,
      ),
      body: favoriteDrinks.isEmpty
          ? Center(
              child: Text(
                'No favorites added yet!',
                style: TextStyle(
                  color:
                      themeNotifier.isNightMode ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: favoriteDrinks.length,
              itemBuilder: (context, index) {
                final drink = favoriteDrinks[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: drink['image']!.startsWith('http')
                        ? Image.network(
                            drink['image']!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            drink['image']!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                  ),
                  title: Text(
                    drink['name']!,
                    style: TextStyle(
                      color: themeNotifier.isNightMode
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    drink['details']!,
                    style: TextStyle(
                      color: themeNotifier.isNightMode
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                  trailing: Text(
                    '\$${drink['price']}',
                    style: TextStyle(
                      color: themeNotifier.isNightMode
                          ? Colors.amberAccent
                          : Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Handle tap, e.g., navigate to drink details
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => DrinkDetailsScreen(drink: drink)));
                  },
                );
              },
            ),
    );
  }
}