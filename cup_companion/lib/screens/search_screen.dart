import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = ''; // For tracking the search query
  final TextEditingController _searchController = TextEditingController();

  // Query the drinks collection from Firebase Firestore
  Future<List<Map<String, dynamic>>> searchDrinks(String query) async {
    final firestoreInstance = FirebaseFirestore.instance;

    // Query the 'drinks' collection where the drink name contains the search query (case insensitive)
    QuerySnapshot snapshot = await firestoreInstance
        .collection('drinks')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Drinks'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Search for a drink...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.poppins(
                color: Colors.black,
              ),
            ),
          ),
          
          // Displaying search results
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: searchDrinks(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No drinks found'));
                }

                // List of search results
                final drinks = snapshot.data!;
                return ListView.builder(
                  itemCount: drinks.length,
                  itemBuilder: (context, index) {
                    final drink = drinks[index];
                    return ListTile(
                      leading: Icon(Icons.local_drink),
                      title: Text(drink['name']),
                      subtitle: Text('Price: \$${drink['price']}'),
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
