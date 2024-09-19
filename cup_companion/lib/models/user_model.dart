// lib/models/user_model.dart

import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 3)
class AppUser extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
  });

  // Convert AppUser to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }

  // Create AppUser from Map (Firestore)
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      username: map['username'],
      email: map['email'],
    );
  }
}