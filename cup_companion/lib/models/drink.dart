// lib/models/drink.dart

import 'package:hive/hive.dart';
import 'review.dart';

part 'drink.g.dart';

@HiveType(typeId: 0)
class Drink extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final List<Review> reviews;

  Drink({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.reviews,
  });

  // Convert Firestore document to Drink object
  factory Drink.fromMap(Map<String, dynamic> map) {
    return Drink(
      id: map['id'] as String? ?? '', // Provide a default value if null
      name: map['name'] as String? ?? 'Unnamed Drink',
      category: map['category'] as String? ?? 'Uncategorized',
      imageUrl: map['imageUrl'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      reviews: (map['reviews'] as List<dynamic>?)
              ?.map((reviewMap) =>
                  Review.fromMap(reviewMap as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convert Drink object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
      'price': price,
      'reviews': reviews.map((review) => review.toMap()).toList(),
    };
  }

  // Calculate average rating
  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    double total = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }
}