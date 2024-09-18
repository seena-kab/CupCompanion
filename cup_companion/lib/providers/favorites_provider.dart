// lib/providers/favorites_provider.dart
 
import 'package:flutter/material.dart';
import '../models/drink.dart';
import 'package:hive/hive.dart';
 
class FavoritesProvider with ChangeNotifier {
  final Box<Drink> _favoritesBox = Hive.box<Drink>('favoritesBox');
 
  List<Drink> _favorites = [];
 
  List<Drink> get favorites => List.unmodifiable(_favorites);
 
  FavoritesProvider() {
    loadFavorites();
  }
 
  void loadFavorites() {
    _favorites = _favoritesBox.values.toList();
    notifyListeners();
  }
 
  void toggleFavorite(Drink drink) {
    final index = _favorites.indexWhere((item) => item.id == drink.id);
    if (index >= 0) {
      _favorites.removeAt(index);
      _favoritesBox.deleteAt(index);
    } else {
      _favorites.add(drink);
      _favoritesBox.add(drink);
    }
    notifyListeners();
  }
 
  bool isFavorite(String drinkId) {
    return _favorites.any((drink) => drink.id == drinkId);
  }
}