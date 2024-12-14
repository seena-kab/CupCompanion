import 'dart:async';
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
  String _selectedFilter = 'All'; // New filter variable
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load all drinks initially
    _searchDrinks('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Method to fetch drinks based on the search query and filter
  void _searchDrinks(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      CollectionReference drinksRef = FirebaseFirestore.instance.collection('drinks');
      Query queryRef = drinksRef;

      // Apply search query (case-insensitive and partial match)
      if (query.isNotEmpty) {
        String formattedQuery = query.toLowerCase().trim();
        queryRef = queryRef.where('searchKeywords', arrayContains: formattedQuery);
      }

      // Apply filter
      if (_selectedFilter == 'Alcoholic') {
        queryRef = queryRef.where('isAlcoholic', isEqualTo: true);
      } else if (_selectedFilter == 'Non-Alcoholic') {
        queryRef = queryRef.where('isAlcoholic', isEqualTo: false);
      }

      QuerySnapshot snapshot = await queryRef.get();

      // Mapping Firestore documents to Drink objects
      List<Drink> drinkList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Drink(
          id: doc.id,
          name: data['name'] ?? '',
          category: data['category'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          reviews: (data['reviews'] as List<dynamic>?)
                  ?.map((reviewMap) => Review.fromMap(reviewMap as Map<String, dynamic>))
                  .toList() ??
              [],
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
        backgroundColor: themeNotifier.isNightMode
            ? Colors.black87
            : const Color(0xFFFFC3A0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          appLocalizations.search,
          style: GoogleFonts.montserrat(
            color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFC3A0), Color(0xFFFDF3E7)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 300), () {
                        _searchDrinks(query);
                      });
                    },
                    style: GoogleFonts.montserrat(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: appLocalizations.searchForDrinks,
                      hintStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(Icons.search, color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black54),
                        onPressed: () {
                          _searchController.clear();
                          _searchDrinks('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Filter dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  items: ['All', 'Alcoholic', 'Non-Alcoholic']
                      .map((filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                      _searchDrinks(_searchController.text);
                    });
                  },
                  isExpanded: true,
                ),
              ),
              const SizedBox(height: 16.0),
              // Search history
              if (_searchHistory.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _searchHistory.reversed.map((history) {
                      return GestureDetector(
                        onTap: () {
                          _searchController.text = history;
                          _searchDrinks(history);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Chip(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            label: Text(
                              history,
                              style: GoogleFonts.montserrat(color: Colors.black87),
                            ),
                            deleteIcon: const Icon(Icons.close, color: Colors.black54),
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
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      )
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
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ListView.builder(
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final drink = _searchResults[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DrinkDetailScreen(
                                              drink: drink,
                                              heroTag: 'drinkImage${drink.id}', coffeeShopUrl: "https://www.starbucks.com",
                                            ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        elevation: 5,
                                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Hero(
                                              tag: 'drinkImage${drink.id}',
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  bottomLeft: Radius.circular(20),
                                                ),
                                                child: Image.network(
                                                  drink.imageUrl,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      drink.name,
                                                      style: GoogleFonts.montserrat(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '\$${drink.price.toStringAsFixed(2)}',
                                                      style: GoogleFonts.montserrat(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          drink.averageRating.toStringAsFixed(1),
                                                          style: GoogleFonts.montserrat(
                                                            fontSize: 14,
                                                            color: Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
