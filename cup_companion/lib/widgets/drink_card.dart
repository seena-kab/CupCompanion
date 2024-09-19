// lib/widgets/drink_card.dart

import 'package:flutter/material.dart';
import '../models/drink.dart';
import '../screens/drink_detail_screen.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../providers/cart_provider.dart';

class DrinkCard extends StatelessWidget {
  final Drink drink;

  const DrinkCard({super.key, required this.drink});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        // Navigate to Drink Detail Page with Hero animation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrinkDetailScreen(drink: drink),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drink Image with Hero
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Hero(
                tag: 'drinkImage_${drink.id}',
                child: Image.network(
                  drink.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image, size: 50));
                  },
                ),
              ),
            ),
            // Drink Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                drink.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      themeNotifier.isNightMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '\$${drink.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: themeNotifier.isNightMode
                      ? Colors.amberAccent
                      : Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Add to Cart Button with Animation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  cartProvider.addToCart(drink);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check, color: Colors.white),
                          const SizedBox(width: 10),
                          Text('${drink.name} added to cart!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeNotifier.isNightMode ? Colors.amberAccent : Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}