import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  FriendsScreenState createState() => FriendsScreenState();
}

class FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _friendsList = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
    _fetchFriendsList();
  }

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
        queryRef = queryRef.where('username', isGreaterThanOrEqualTo: query)
                           .where('username', isLessThanOrEqualTo: query + '\uf8ff');
      }

      QuerySnapshot snapshot = await queryRef.get();

      // Mapping Firestore documents to users
      List<Map<String, dynamic>> userList = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'username': doc['username'],
          'email': doc['email'],
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

  // Method to fetch friend requests for the current user
  void _fetchFriendRequests() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('toUserId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      List<Map<String, dynamic>> requests = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'fromUserId': data['fromUserId'],
          'timestamp': data['timestamp'],
        };
      }).toList();

      setState(() {
        _friendRequests = requests;
      });
    } catch (e) {
      print('Error fetching friend requests: $e');
    }
  }

  // Method to fetch the user's friends list
  void _fetchFriendsList() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      List<dynamic> friends = (userDoc.data() as Map<String, dynamic>)['friends'] ?? [];

      setState(() {
        _friendsList = friends.map((friendId) => {'id': friendId}).toList();
      });
    } catch (e) {
      print('Error fetching friends list: $e');
    }
  }

  // Method to accept a friend request
  Future<void> _acceptFriendRequest(String requestId, String fromUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) return;

    try {
      // Update the friend request status to 'accepted'
      await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .update({'status': 'accepted'});

      // Add both users to each other's friend list
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([fromUserId])
      });

      await FirebaseFirestore.instance.collection('users').doc(fromUserId).update({
        'friends': FieldValue.arrayUnion([currentUserId])
      });

      _fetchFriendRequests();
      _fetchFriendsList();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request accepted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept friend request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
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
          // Friend Requests
          Expanded(
            child: ListView(
              children: [
                // Friend Requests Section
                if (_friendRequests.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Friend Requests',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ..._friendRequests.map((request) {
                    return ListTile(
                      title: Text('Request from: ${request['fromUserId']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              _acceptFriendRequest(request['id'], request['fromUserId']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              // Reject logic (similar to accept)
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // Friends List Section
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Friends List',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_friendsList.isEmpty)
                  const Center(
                    child: Text('No friends yet!'),
                  )
                else
                  ..._friendsList.map((friend) {
                    return ListTile(
                      title: Text('Friend ID: ${friend['id']}'),
                      // Add more friend details if needed
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
