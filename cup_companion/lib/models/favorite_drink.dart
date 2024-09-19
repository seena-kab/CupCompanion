// lib/models/favorite_drink.dart

import 'package:hive/hive.dart';
import 'drink.dart';

part 'favorite_drink.g.dart';

@HiveType(typeId: 3) // Ensure the typeId is unique across all models
class FavoriteDrink extends HiveObject {
  @HiveField(0)
  final Drink drink;

  FavoriteDrink({required this.drink});

  // Convert FavoriteDrink to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'drink': drink.toMap(),
    };
  }

  // Create FavoriteDrink from Map (Firestore)
  factory FavoriteDrink.fromMap(Map<String, dynamic> map) {
    return FavoriteDrink(
      drink: Drink.fromMap(map['drink']),
    );
  }
}