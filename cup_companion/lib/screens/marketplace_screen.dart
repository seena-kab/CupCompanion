// lib/screens/marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../models/drink.dart';
import '../services/drink_service.dart';
import '../widgets/drink_card.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final DrinkService _drinkService = DrinkService();
  List<Drink> allDrinks = [];
  List<Drink> displayedDrinks = [];
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String errorMessage = '';

  // List of categories
  final List<String> categories = [
    'All',
    'Alcoholic',
    'Non-Alcoholic',
  ];

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
            selectedCategory == 'All' || drink.category == selectedCategory;
        bool matchesSearch = drink.name.toLowerCase().contains(query) ||
            drink.description.toLowerCase().contains(query);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  // Build category filters as horizontal list
  Widget buildCategoryFilters() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index];
          bool isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
                filterDrinks();
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (themeNotifier.isNightMode ? Colors.blueAccent : Colors.blueAccent)
                    : (themeNotifier.isNightMode ? Colors.grey[800] : Colors.grey[300]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (themeNotifier.isNightMode ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.blueAccent,
            automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: themeNotifier.isNightMode ? Colors.white : Colors.white,
            ),
            onPressed: () {
              // Navigate to Cart Screen
              Navigator.pushNamed(context, '/cart');
            },
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
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for drinks...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: themeNotifier.isNightMode
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    // Category Filters
                    buildCategoryFilters(),
                    // Displayed Drinks Count
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${displayedDrinks.length} drinks found',
                          style: TextStyle(
                            color: themeNotifier.isNightMode
                                ? Colors.white70
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    // Drinks Grid
                    Expanded(
                      child: displayedDrinks.isEmpty
                          ? Center(
                              child: Text(
                                'No drinks found.',
                                style: TextStyle(
                                  color: themeNotifier.isNightMode
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GridView.builder(
                                itemCount: displayedDrinks.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of columns
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.75, // Width / Height ratio
                                ),
                                itemBuilder: (context, index) {
                                  Drink drink = displayedDrinks[index];
                                  return DrinkCard(drink: drink);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}