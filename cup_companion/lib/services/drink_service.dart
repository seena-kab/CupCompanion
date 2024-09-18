// lib/services/drink_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drink.dart';

class DrinkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all drinks from Firestore
  Future<List<Drink>> fetchDrinks() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('drinks').get();
      return snapshot.docs.map((doc) {
        return Drink.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load drinks: $e');
    }
  }

  // Fetch a single drink by ID
  Future<Drink> fetchDrinkById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('drinks').doc(id).get();
      if (doc.exists) {
        return Drink.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Drink not found');
      }
    } catch (e) {
      throw Exception('Failed to load drink: $e');
    }
  }

  // Add a new drink (admin functionality)
  Future<void> addDrink(Drink drink) async {
    try {
      await _firestore.collection('drinks').doc(drink.id).set(drink.toMap());
    } catch (e) {
      throw Exception('Failed to add drink: $e');
    }
  }

  // Update a drink
  Future<void> updateDrink(Drink drink) async {
    try {
      await _firestore.collection('drinks').doc(drink.id).update(drink.toMap());
    } catch (e) {
      throw Exception('Failed to update drink: $e');
    }
  }

  // Delete a drink
  Future<void> deleteDrink(String id) async {
    try {
      await _firestore.collection('drinks').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete drink: $e');
    }
  }
}