// lib/models/cart_item.dart

import 'package:hive/hive.dart';
import 'drink.dart';

part 'cart_item.g.dart'; // Required for Hive TypeAdapter generation

@HiveType(typeId: 1) // Ensure typeId is unique across all Hive models
class CartItem extends HiveObject {
  @HiveField(0)
  final Drink drink;

  @HiveField(1)
  int quantity;

  CartItem({required this.drink, this.quantity = 1});
}