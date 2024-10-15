// lib/screens/search_screen.dart

import 'package:cup_companion/models/review.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cup_companion/models/drink.dart';
import 'package:cup_companion/screens/drink_detail_screen.dart';
import 'package:cup_companion/theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cup_companion/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Drink> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    // Optionally, load search history from local storage
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to fetch drinks based on the search query
  void _searchDrinks(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Query queryRef = FirebaseFirestore.instance.collection('drinks');

      // Apply search query (case-insensitive and partial match)
      if (query.isNotEmpty) {
        String formattedQuery = query.toLowerCase(); // Convert query to lowercase
        queryRef = queryRef.where('name', isGreaterThanOrEqualTo: formattedQuery)
                           .where('name', isLessThanOrEqualTo: formattedQuery + '\uf8ff');
      }

      QuerySnapshot snapshot = await queryRef.get();

      // Mapping Firestore documents to Drink objects
      List<Drink> drinkList = snapshot.docs.map((doc) {
        return Drink(
          id: doc.id,
          name: doc['name'],
          category: doc['category'],
          imageUrl: doc['imageUrl'],
          description: doc['description'],
          price: (doc['price'] as num?)?.toDouble() ?? 0.0,
          reviews: (doc['reviews'] as List<dynamic>?)
              ?.map((reviewMap) =>
                  Review.fromMap(reviewMap as Map<String, dynamic>))
              .toList() ??
              [], // Ensure the price is cast to double
        );
      }).toList();

      setState(() {
        _searchResults = drinkList;
        _isLoading = false;
      });

      // Add to search history
      if (query.isNotEmpty && !_searchHistory.contains(query)) {
        setState(() {
          _searchHistory.add(query);
        });
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching drinks: $e';
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
        title: const Text('Search'),
        backgroundColor: themeNotifier.isNightMode ? Colors.black : Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (query) {
                _searchDrinks(query);
              },
              decoration: InputDecoration(
                hintText: appLocalizations.searchForDrinks,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchDrinks(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          // Search history
          if (_searchHistory.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: _searchHistory.reversed.map((history) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = history;
                      _searchDrinks(history);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Chip(
                        label: Text(history),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            _searchHistory.remove(history);
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          // Search results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text(
                              appLocalizations.noDrinksFound,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final drink = _searchResults[index];
                              return ListTile(
                                leading: Image.network(
                                  drink.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(drink.name),
                                subtitle: Text('\$${drink.price.toStringAsFixed(2)}'),
                                onTap: () {
                                  // Navigate to DrinkDetailScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DrinkDetailScreen(
                                        drink: drink,
                                        heroTag: 'drinkImage${drink.id}',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
