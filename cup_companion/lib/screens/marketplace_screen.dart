// lib/screens/marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../models/drink.dart';
import '../services/drink_service.dart';
import '../widgets/drink_card.dart';

// Import the generated localization file
import 'package:cup_companion/l10n/app_localizations.dart';

/// **Category Class**
///
/// Represents a category with an identifier and localized display name.
class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final DrinkService _drinkService = DrinkService();
  List<Drink> allDrinks = [];
  List<Drink> displayedDrinks = [];
  String selectedCategory = 'all'; // Category ID
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String errorMessage = '';

  // List of category IDs
  final List<String> categoryIds = [
    'all',
    'alcoholic',
    'non_alcoholic',
    'cocktails',
    'smoothies',
    'sodas',
    'juices',
  ];

  // List of Category objects with id and localized name
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    fetchDrinks();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  // Fetch drinks from Firestore
  Future<void> fetchDrinks() async {
    try {
      List<Drink> drinks = await _drinkService.fetchDrinks();
      setState(() {
        allDrinks = drinks;
        displayedDrinks = List.from(allDrinks);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Handle search input changes
  void _onSearchChanged() {
    filterDrinks();
  }

  // Filter drinks based on search query and selected category
  void filterDrinks() {
    String query = searchController.text.toLowerCase();
    setState(() {
      displayedDrinks = allDrinks.where((drink) {
        bool matchesCategory =
            selectedCategory == 'all' || drink.category == selectedCategory;
        bool matchesSearch = drink.name.toLowerCase().contains(query) ||
            drink.description.toLowerCase().contains(query);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  // Build category filters as horizontal list
  Widget buildCategoryFilters() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion

    // Initialize categories with localized names
    if (categories.isEmpty) {
      categories = categoryIds.map((id) {
        String name;
        switch (id) {
          case 'all':
            name = appLocalizations.all;
            break;
          case 'alcoholic':
            name = appLocalizations.alcoholic;
            break;
          case 'non_alcoholic':
            name = appLocalizations.nonAlcoholic;
            break;
          case 'cocktails':
            name = appLocalizations.cocktails;
            break;
          case 'smoothies':
            name = appLocalizations.smoothies;
            break;
          case 'sodas':
            name = appLocalizations.sodas;
            break;
          case 'juices':
            name = appLocalizations.juices;
            break;
          default:
            name = id; // Fallback to id
        }
        return Category(id: id, name: name);
      }).toList();
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          Category category = categories[index];
          bool isSelected = category.id == selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category.id;
                filterDrinks();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (themeNotifier.isNightMode
                        ? Colors.tealAccent[700]
                        : Colors.teal)
                    : (themeNotifier.isNightMode
                        ? Colors.grey[800]
                        : Colors.grey[200]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (themeNotifier.isNightMode
                            ? Colors.white70
                            : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build the main content with search, filters, and drinks
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion

    return Scaffold(
      backgroundColor:
          themeNotifier.isNightMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          appLocalizations.marketplace, // Localized string
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              // Navigate to Cart Screen
              Navigator.pushNamed(context, '/cart');
            },
            tooltip: appLocalizations.cart, // Localized tooltip
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeNotifier.isNightMode
                              ? Colors.grey[800]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: appLocalizations.searchForDrinks, // Localized string
                            hintStyle: TextStyle(
                              color: themeNotifier.isNightMode
                                  ? Colors.white70
                                  : Colors.grey[400],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: themeNotifier.isNightMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    color: themeNotifier.isNightMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                                    onPressed: () {
                                      searchController.clear();
                                    },
                                    tooltip: appLocalizations.clearSearch, // Localized tooltip
                                  )
                                : null,
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: themeNotifier.isNightMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    // Category Filters
                    buildCategoryFilters(),
                    // Displayed Drinks Count
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${displayedDrinks.length} ${appLocalizations.drinksFound}', // Localized string
                          style: TextStyle(
                            color: themeNotifier.isNightMode
                                ? Colors.white70
                                : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Drinks Grid
                    Expanded(
                      child: displayedDrinks.isEmpty
                          ? Center(
                              child: Text(
                                appLocalizations.noDrinksFound, // Localized string
                                style: TextStyle(
                                  color: themeNotifier.isNightMode
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: displayedDrinks.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of columns
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                  childAspectRatio: 0.7, // Width / Height ratio
                                ),
                                itemBuilder: (context, index) {
                                  Drink drink = displayedDrinks[index];
                                  return DrinkCard(
                                    drink: drink,
                                    index: index,
                                    heroTagPrefix: 'marketplace_', // Use a unique prefix
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}