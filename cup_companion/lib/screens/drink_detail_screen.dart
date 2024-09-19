// lib/screens/drink_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../models/drink.dart';
import '../providers/cart_provider.dart';
import '../models/review.dart';
import '../providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrinkDetailScreen extends StatefulWidget {
  final Drink drink;

  const DrinkDetailScreen({super.key, required this.drink});

  @override
  State<DrinkDetailScreen> createState() => _DrinkDetailScreenState();
}

class _DrinkDetailScreenState extends State<DrinkDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  double _userRating = 5.0;
  String _userReview = '';

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final appUser = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drink.name),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Drink Image with Hero
            Hero(
              tag: 'drinkImage_${widget.drink.id}',
              child: Image.network(
                widget.drink.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Failed to load image'),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Drink Name and Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.drink.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.isNightMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    '\$${widget.drink.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.isNightMode
                          ? Colors.amberAccent
                          : Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Drink Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.drink.description,
                style: TextStyle(
                  fontSize: 16,
                  color: themeNotifier.isNightMode
                      ? Colors.white70
                      : Colors.grey[800],
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 16),
            // Average Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.drink.averageRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.drink.reviews.length} reviews)',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeNotifier.isNightMode
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Add to Cart Button with Animation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  cartProvider.addToCart(widget.drink);
                  // Show a Snackbar with animation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.drink.name} added to cart!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: themeNotifier.isNightMode
                      ? Colors.amberAccent
                      : Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Ratings and Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeNotifier.isNightMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Display Existing Reviews
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.drink.reviews.length,
              itemBuilder: (context, index) {
                final review = widget.drink.reviews[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      review.username.isNotEmpty
                          ? review.username[0].toUpperCase()
                          : 'U',
                    ),
                  ),
                  title: Text(review.username),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      Text(review.comment),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Add a New Review
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a Review',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeNotifier.isNightMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating Dropdown
                    DropdownButtonFormField<double>(
                      value: _userRating,
                      decoration: const InputDecoration(
                        labelText: 'Rating',
                        border: OutlineInputBorder(),
                      ),
                      items: [1, 2, 3, 4, 5].map((value) {
                        return DropdownMenuItem<double>(
                          value: value.toDouble(),
                          child: Text('$value Star${value > 1 ? 's' : ''}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _userRating = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    // Review Text Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Review',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your review';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null) {
                          _userReview = value;
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    // Submit Button
                    ElevatedButton(
                      // Inside your submit review logic in DrinkDetailScreen

onPressed: appUser == null
    ? null
    : () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          // Create a new Review instance
          final newReview = Review(
            userId: appUser.id,
            username: appUser.username,
            comment: _userReview,
            rating: _userRating,
          );

          setState(() {
            widget.drink.reviews.add(newReview);
          });

          // Get a reference to the Firestore document for this drink
          final drinkDocRef = FirebaseFirestore.instance
              .collection('drinks')
              .doc(widget.drink.id);

          try {
            // Check if the drink document exists
            final drinkSnapshot = await drinkDocRef.get();

            if (drinkSnapshot.exists) {
              // If the document exists, update it with the new review
              await drinkDocRef.update({
                'reviews': FieldValue.arrayUnion([newReview.toMap()]),
              });
            } else {
              // If the document doesn't exist, create it and add the review
              await drinkDocRef.set({
                'reviews': [newReview.toMap()],
                'name': widget.drink.name,
                'price': widget.drink.price,
                'description': widget.drink.description,
                'imageUrl': widget.drink.imageUrl,
                'averageRating': newReview.rating,  // Initial average rating
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Review added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _formKey.currentState!.reset();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add review: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: themeNotifier.isNightMode
                            ? Colors.amberAccent
                            : Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Review',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}