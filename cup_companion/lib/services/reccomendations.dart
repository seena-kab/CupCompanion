import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer' as developer;

class RecommendationService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Future<List<String>> getDrinkRecommendations(String userId) async {
    try {
      // Fetch the survey data for the given user
      DataSnapshot snapshot = (await _databaseRef.child('users').child(userId).child('surveyData').once()) as DataSnapshot;
      if (snapshot.exists) {
        final Map<String, dynamic>? surveyData = snapshot.value as Map<String, dynamic>?;

        if (surveyData != null) {
          // Get the user's coffee preferences and other relevant data
          List<String> coffeeChoice = List<String>.from(surveyData['coffeeChoice'] ?? []);
          String coffeeFrequency = surveyData['coffeeFrequency'] ?? '';
          String dietaryPreference = surveyData['dietaryPreference'] ?? '';

          // Generate recommendations based on coffee choices and other data
          return _generateRecommendations(coffeeChoice, coffeeFrequency, dietaryPreference);
        }
      }
    } catch (e) {
      developer.log('Error fetching recommendations: $e', name: 'RecommendationService');
    }

    return ['No recommendations available'];
  }

  // Algorithm to generate recommendations based on survey data
  List<String> _generateRecommendations(List<String> coffeeChoice, String coffeeFrequency, String dietaryPreference) {
    List<String> recommendations = [];

    // Recommend drinks based on coffee preferences
    if (coffeeChoice.contains('Latte')) {
      recommendations.add('Try our Vanilla Latte');
      if (dietaryPreference == 'Vegan') {
        recommendations.add('Try our Oat Milk Latte');
      }
    }
    if (coffeeChoice.contains('Espresso')) {
      recommendations.add('Try a Double Shot Espresso');
      if (coffeeFrequency == 'Very often' || coffeeFrequency == 'Often') {
        recommendations.add('Try an Espresso Macchiato');
      }
    }
    if (coffeeChoice.contains('Black coffee')) {
      recommendations.add('Try our Single Origin Black Coffee');
      if (coffeeFrequency == 'Rarely' || coffeeFrequency == 'Never') {
        recommendations.add('Try a Light Roast Black Coffee');
      }
    }
    if (coffeeChoice.contains('Cappuccino')) {
      recommendations.add('Try a Cinnamon Cappuccino');
      if (dietaryPreference == 'Gluten-Free') {
        recommendations.add('Pair it with a Gluten-Free Snack');
      }
    }
    if (coffeeChoice.contains('Other')) {
      recommendations.add('Explore some custom coffee blends!');
    }

    // Add some general recommendations
    if (recommendations.isEmpty) {
      recommendations.add('Explore some seasonal specials!');
    }

    return recommendations;
  }
}
