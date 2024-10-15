// lib/screens/friends_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  FriendsScreenState createState() => FriendsScreenState();
}

class FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to fetch users based on the search query
  void _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Query queryRef = FirebaseFirestore.instance.collection('users');

      // Apply search query (case-insensitive)
      if (query.isNotEmpty) {
        queryRef = queryRef.where('name', isGreaterThanOrEqualTo: query)
                           .where('name', isLessThanOrEqualTo: query + '\uf8ff');
      }

      QuerySnapshot snapshot = await queryRef.get();

      // Mapping Firestore documents to users
      List<Map<String, dynamic>> userList = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'email': doc['email'], // Assuming the 'users' collection has 'name' and 'email'
        };
      }).toList();

      setState(() {
        _searchResults = userList;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching users: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Friends'),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (query) {
                _searchUsers(query);
              },
              decoration: InputDecoration(
                hintText: 'Search for users',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchUsers(_searchController.text);
                  },
                ),
              ),
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
                        ? const Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final user = _searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(user['name']),
                                subtitle: Text(user['email']),
                                onTap: () {
                                  // Implement action when a user is tapped, like sending a friend request
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
