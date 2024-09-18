// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? _user;

  AppUser? get user => _user;

  UserProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        _user = AppUser.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        // If user does not exist in Firestore, create a new record
        _user = AppUser(
          id: firebaseUser.uid,
          username: firebaseUser.email?.split('@')[0] ?? 'User',
          email: firebaseUser.email ?? '',
        );
        await _firestore
            .collection('users')
            .doc(_user!.id)
            .set(_user!.toMap());
      }
      // Optionally, store user data in Hive for offline access
      var userBox = Hive.box<AppUser>('userBox');
      await userBox.put(_user!.id, _user!);
    }
    notifyListeners();
  }
}