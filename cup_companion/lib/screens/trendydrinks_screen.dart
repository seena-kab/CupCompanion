// lib/screens/trendydrinks_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:cup_companion/services/drink_service.dart';
import 'package:cup_companion/models/drink.dart';
import 'package:cup_companion/screens/drink_detail_screen.dart';
import 'package:cup_companion/providers/favorites_provider.dart';
import 'package:cup_companion/theme/theme_notifier.dart';
import 'package:cup_companion/l10n/app_localizations.dart';

class TrendyDrinksScreen extends StatefulWidget {
  const TrendyDrinksScreen({Key? key}) : super(key: key);

  @override
  _TrendyDrinksScreenState createState() => _TrendyDrinksScreenState();
}

class _TrendyDrinksScreenState extends State<TrendyDrinksScreen>
    with SingleTickerProviderStateMixin {
  final DrinkService _drinkService = DrinkService();
  late AnimationController _animationController;

  List<Drink> _drinks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Fetch the drinks in order of highest averageRating
    fetchHighRatedDrinks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void fetchHighRatedDrinks() async {
    try {
      List<Drink> drinks = await _drinkService.fetchDrinksByAverageRating();
      setState(() {
        _drinks = drinks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load drinks.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.trendyDrinks, // "Trendy Drinks"
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: themeNotifier.isNightMode ? Colors.white : Colors.black,
        ),
        elevation: 0,
      ),
      backgroundColor:
          themeNotifier.isNightMode ? Colors.black : Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : AnimationLimiter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      itemCount: _drinks.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Display drinks in two columns
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3 / 4,
                      ),
                      itemBuilder: (context, index) {
                        final drink = _drinks[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          columnCount: 2,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: buildDrinkCard(drink, index, context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  Widget buildDrinkCard(Drink drink, int index, BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(drink.id);
    final appLocalizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        // Navigate to DrinkDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrinkDetailScreen(
              drink: drink,
              heroTag: 'trendyDrinkImage$index',
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: themeNotifier.isNightMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeNotifier.isNightMode
                  ? Colors.black45
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image with Hero animation
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Hero(
                      tag: 'trendyDrinkImage$index',
                      child: Image.network(
                        drink.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, size: 50),
                          );
                        },
                      ),
                    ),
                    // Favorite Icon
                    Positioned(
                      right: 8,
                      top: 8,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: themeNotifier.isNightMode
                                  ? Colors.redAccent
                                  : Colors.redAccent,
                            ),
                            onPressed: () {
                              // Toggle favorite and run animation
                              favoritesProvider.toggleFavorite(drink);
                              _animationController.forward(from: 0.0);
                            },
                            tooltip: isFavorite
                                ? appLocalizations.removeFromFavorites
                                : appLocalizations.addToFavorites,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Drink details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    drink.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.isNightMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  if (drink.category.isNotEmpty)
                    Text(
                      drink.category,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: themeNotifier.isNightMode
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${drink.price.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: themeNotifier.isNightMode
                          ? Colors.amberAccent
                          : Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (drink.averageRating != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${appLocalizations.averageRating}: ${drink.averageRating!.toStringAsFixed(1)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: themeNotifier.isNightMode
                              ? Colors.white70
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
