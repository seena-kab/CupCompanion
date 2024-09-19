// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/drink.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider with ChangeNotifier {
  final Box<CartItem> _cartBox = Hive.box<CartItem>('cartBox');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItem> get items => _cartBox.values.toList();

  String get userId => _auth.currentUser?.uid ?? '';

  Future<void> addToCart(Drink drink) async {
    if (userId.isEmpty) return; // Ensure user is authenticated

    final existingItem = _cartBox.values.firstWhere(
      (item) => item.drink.id == drink.id,
      orElse: () => CartItem(drink: drink, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      existingItem.quantity += 1;
      existingItem.save();
    } else {
      _cartBox.add(CartItem(drink: drink, quantity: 1));
    }

    // Sync with Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(drink.id)
        .set({
      'drink': drink.toMap(),
      'quantity': existingItem.quantity > 0 ? existingItem.quantity : 1,
    });

    notifyListeners();
  }

  Future<void> removeFromCart(String drinkId) async {
    if (userId.isEmpty) return;

    final existingItem = _cartBox.values.firstWhere(
      (item) => item.drink.id == drinkId,
      orElse: () => CartItem(
        drink: Drink(
          id: drinkId,
          name: 'Unknown',
          category: 'Non-Alcoholic',
          imageUrl: '',
          description: '',
          price: 0.0,
          reviews: [], // Added reviews parameter
        ),
        quantity: 0,
      ),
    );

    if (existingItem.quantity > 0) {
      existingItem.delete();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(drinkId)
          .delete();
    }

    notifyListeners();
  }

  Future<void> incrementQuantity(String drinkId) async {
    if (userId.isEmpty) return;

    final existingItem = _cartBox.values.firstWhere(
      (item) => item.drink.id == drinkId,
      orElse: () => CartItem(
        drink: Drink(
          id: drinkId,
          name: 'Unknown',
          category: 'Non-Alcoholic',
          imageUrl: '',
          description: '',
          price: 0.0,
          reviews: [], // Added reviews parameter
        ),
        quantity: 0,
      ),
    );

    if (existingItem.quantity > 0) {
      existingItem.quantity += 1;
      existingItem.save();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(drinkId)
          .update({'quantity': existingItem.quantity});

      notifyListeners();
    }
  }

  Future<void> decrementQuantity(String drinkId) async {
    if (userId.isEmpty) return;

    final existingItem = _cartBox.values.firstWhere(
      (item) => item.drink.id == drinkId,
      orElse: () => CartItem(
        drink: Drink(
          id: drinkId,
          name: 'Unknown',
          category: 'Non-Alcoholic',
          imageUrl: '',
          description: '',
          price: 0.0,
          reviews: [], // Added reviews parameter
        ),
        quantity: 0,
      ),
    );

    if (existingItem.quantity > 1) {
      existingItem.quantity -= 1;
      existingItem.save();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(drinkId)
          .update({'quantity': existingItem.quantity});
    } else if (existingItem.quantity == 1) {
      existingItem.delete();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(drinkId)
          .delete();
    }

    notifyListeners();
  }

  double get totalPrice {
    return _cartBox.values
        .fold(0.0, (sum, item) => sum + (item.drink.price * item.quantity));
  }

  Future<void> clearCart() async {
    if (userId.isEmpty) return;

    _cartBox.clear();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    notifyListeners();
  }
}