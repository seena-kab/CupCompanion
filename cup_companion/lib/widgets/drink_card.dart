import 'package:flutter/material.dart';
import '../models/drink.dart';
import '../screens/drink_detail_screen.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../providers/cart_provider.dart';

class DrinkCard extends StatelessWidget {
  final Drink drink;
  final int index;
  final String heroTagPrefix;

  const DrinkCard({
    super.key,
    required this.drink,
    required this.index,
    required this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Debugging: Print the image URL
    print('Loading image for drink "${drink.name}" from URL: ${drink.imageUrl}');

    return GestureDetector(
      onTap: () {
        // Navigate to Drink Detail Page with Hero animation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrinkDetailScreen(
              drink: drink,
              heroTag: '$heroTagPrefix$index', coffeeShopUrl: "https://www.starbucks.com",
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: themeNotifier.isNightMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: themeNotifier.isNightMode
                  ? Colors.black26
                  : Colors.grey.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            // Image with Add to Cart button overlaid
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Hero(
                      tag: '$heroTagPrefix$index',
                      child: Image.network(
                        drink.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      (progress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Debugging: Print the error
                          print('Error loading image for drink "${drink.name}": $error');
                          return const Center(
                            child: Icon(Icons.broken_image, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                  // Add to Cart Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.7),
                      child: IconButton(
                        icon: Icon(
                          Icons.add_shopping_cart,
                          color: themeNotifier.isNightMode
                              ? Colors.black87
                              : Colors.teal,
                        ),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Drink Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drink.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.isNightMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${drink.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeNotifier.isNightMode
                          ? Colors.tealAccent[200]
                          : Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
