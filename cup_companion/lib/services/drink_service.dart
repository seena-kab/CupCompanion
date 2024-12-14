// lib/services/drink_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/drink.dart';
import '../models/review.dart';

class DrinkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all drinks from Firestore
  Future<List<Drink>> fetchDrinks() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('drinks').get();
      return snapshot.docs.map((doc) {
        return Drink.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load drinks: $e');
    }
  }

  // Fetch drinks ordered by averageRating (highest first)
  Future<List<Drink>> fetchDrinksByAverageRating() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('drinks')
          .orderBy('averageRating', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        return Drink.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load drinks by average rating: $e');
    }
  }

  // Search drinks with filters
  Future<List<Drink>> searchDrinks({
    required String query,
    required bool isAlcoholic,
    required bool isNonAlcoholic,
  }) async {
    try {
      CollectionReference drinksRef = _firestore.collection('drinks');
      Query queryRef = drinksRef;

      // Apply filters
      if (isAlcoholic != isNonAlcoholic) {
        // Only one of them is true
        queryRef = queryRef.where('isAlcoholic', isEqualTo: isAlcoholic);
      } else if (!isAlcoholic && !isNonAlcoholic) {
        // Both are false, return empty list
        return [];
      }
      // If both are true, no need to filter by 'isAlcoholic'

      // Apply search query
      if (query.isNotEmpty) {
        queryRef = queryRef.where('searchKeywords',
            arrayContains: query.toLowerCase());
      }

      QuerySnapshot snapshot = await queryRef.get();

      // Map Firestore documents to Drink objects using fromMap
      List<Drink> drinkList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Drink.fromMap(data, doc.id);
      }).toList();

      return drinkList;
    } catch (e) {
      throw Exception('Failed to search drinks: $e');
    }
  }

  // Fetch a single drink by ID
  Future<Drink> fetchDrinkById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('drinks').doc(id).get();
      if (doc.exists) {
        return Drink.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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
      // Use Firestore's auto-generated ID
      await _firestore.collection('drinks').add(drink.toMap());
    } catch (e) {
      throw Exception('Failed to add drink: $e');
    }
  }

  // Update a drink
  Future<void> updateDrink(Drink drink) async {
    try {
      await _firestore
          .collection('drinks')
          .doc(drink.id)
          .update(drink.toMap());
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

  // ---------------------------
  // Additional Methods
  // ---------------------------

  // Fetch recommendations for a user
  Future<List<Drink>> fetchRecommendations(String userId) async {
    try {
      final recommendationsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recommendations')
          .get();

      return recommendationsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Drink.fromMap(data as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching recommendations: $e');
      return [];
    }
  }

  // Generate recommendations based on user survey data
  Future<void> generateRecommendations(
      String userId, Map<String, dynamic> surveyData) async {
    try {
      final drinksSnapshot = await _firestore.collection('drinks').get();
      if (drinksSnapshot.docs.isEmpty) return;

      final drinksList = drinksSnapshot.docs.map((doc) => doc.data()).toList();

      final recommendations = drinksList.where((drink) {
        final isAlcoholMatch = surveyData['alcoholChoice'] != null &&
            (drink['name'] as String)
                .toLowerCase()
                .contains(surveyData['alcoholChoice'].toLowerCase());
        final isCoffeeMatch = surveyData['coffeeChoice'] != null &&
            (surveyData['coffeeChoice'] as List<dynamic>).any((coffee) =>
                (drink['name'] as String)
                    .toLowerCase()
                    .contains(coffee.toLowerCase()) ||
                (drink['description'] != null &&
                    (drink['description'] as String)
                        .toLowerCase()
                        .contains(coffee.toLowerCase())));
        return isAlcoholMatch || isCoffeeMatch;
      }).toList();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recommendations')
          .add({'recommendations': recommendations});
    } catch (e) {
      print('Error generating recommendations: $e');
      throw Exception("Failed to generate recommendations.");
    }
  }
}
