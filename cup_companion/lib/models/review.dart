// lib/models/review.dart

import 'package:hive/hive.dart';

part 'review.g.dart';

@HiveType(typeId: 2)
class Review extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String comment;

  @HiveField(3)
  final double rating;

  Review({
    required this.userId,
    required this.username,
    required this.comment,
    required this.rating,
  });

  // Convert Firestore document to Review object
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'] as String? ?? '',
      username: map['username'] as String? ?? 'Anonymous',
      comment: map['comment'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convert Review object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'comment': comment,
      'rating': rating,
    };
  }
}