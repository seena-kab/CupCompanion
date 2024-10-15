// lib/screens/drink_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../models/drink.dart';
import '../providers/cart_provider.dart';
import '../models/review.dart';
import '../providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import localization packages
import 'package:cup_companion/l10n/app_localizations.dart'; // Adjust the import path if necessary

class DrinkDetailScreen extends StatefulWidget {
  final Drink drink;
  final String heroTag; // Ensure heroTag is used correctly

  const DrinkDetailScreen({
    super.key,
    required this.drink,
    required this.heroTag,
  });

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

    // Retrieve localization instance
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion

    return Scaffold(
      backgroundColor:
          themeNotifier.isNightMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.drink.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Drink Image with Hero
            Hero(
              tag: widget.heroTag, // Updated Hero tag
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30)),
                child: Image.network(
                  widget.drink.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        appLocalizations.failedToLoadImage,
                        style: TextStyle(
                          color: themeNotifier.isNightMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Drink Name and Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.drink.name,
                    style: TextStyle(
                      fontSize: 28,
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
                          ? Colors.tealAccent[200]
                          : Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Drink Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                widget.drink.description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: themeNotifier.isNightMode
                      ? Colors.white70
                      : Colors.grey[800],
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 24),
            // Add to Cart Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  cartProvider.addToCart(widget.drink);
                  // Show a Snackbar with animation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${widget.drink.name} ${appLocalizations.addToCartButton}!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  appLocalizations.addToCartButton,
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: themeNotifier.isNightMode
                      ? Colors.tealAccent[700]
                      : Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Ratings and Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  appLocalizations.reviewsSection,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeNotifier.isNightMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Display Existing Reviews
            widget.drink.reviews.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      appLocalizations.noReviewsYet,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeNotifier.isNightMode
                            ? Colors.white70
                            : Colors.grey[700],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: widget.drink.reviews.length,
                    itemBuilder: (context, index) {
                      final review = widget.drink.reviews[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: themeNotifier.isNightMode
                                ? Colors.tealAccent[700]
                                : Colors.teal,
                            child: Text(
                              review.username.isNotEmpty
                                  ? review.username[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            review.username,
                            style: TextStyle(
                              color: themeNotifier.isNightMode
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
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
                              const SizedBox(height: 4),
                              Text(
                                review.comment,
                                style: TextStyle(
                                  color: themeNotifier.isNightMode
                                      ? Colors.white70
                                      : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            // Add a New Review
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLocalizations.addAReviewTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: themeNotifier.isNightMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rating Slider
                    Text(
                      appLocalizations.yourRating,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeNotifier.isNightMode
                            ? Colors.white70
                            : Colors.grey[800],
                      ),
                    ),
                    Slider(
                      value: _userRating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _userRating.round().toString(),
                      activeColor: themeNotifier.isNightMode
                          ? Colors.tealAccent[700]
                          : Colors.teal,
                      onChanged: (value) {
                        setState(() {
                          _userRating = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // Review Text Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: appLocalizations.yourReview,
                        labelStyle: TextStyle(
                          color: themeNotifier.isNightMode
                              ? Colors.white70
                              : Colors.grey[700],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: themeNotifier.isNightMode
                                ? Colors.tealAccent[700]!
                                : Colors.teal,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appLocalizations.pleaseEnterYourReview;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null) {
                          _userReview = value;
                        }
                      },
                      style: TextStyle(
                        color: themeNotifier.isNightMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Submit Button
                    ElevatedButton(
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
                                  final drinkSnapshot =
                                      await drinkDocRef.get();

                                  if (drinkSnapshot.exists) {
                                    // If the document exists, update it with the new review
                                    await drinkDocRef.update({
                                      'reviews': FieldValue.arrayUnion(
                                          [newReview.toMap()]),
                                    });
                                  } else {
                                    // If the document doesn't exist, create it and add the review
                                    await drinkDocRef.set({
                                      'reviews': [newReview.toMap()],
                                      'name': widget.drink.name,
                                      'price': widget.drink.price,
                                      'description': widget.drink.description,
                                      'imageUrl': widget.drink.imageUrl,
                                      'averageRating':
                                          newReview.rating, // Initial average rating
                                    });
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          appLocalizations.reviewAdded),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _formKey.currentState!.reset();
                                  setState(() {
                                    _userRating = 5.0; // Reset rating
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        appLocalizations.failedToAddReview(e.toString()),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: themeNotifier.isNightMode
                            ? Colors.tealAccent[700]
                            : Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        appLocalizations.submitReview,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}