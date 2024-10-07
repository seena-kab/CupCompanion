import 'package:cup_companion/models/wall_post.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'chat_screen.dart'; // Import the ChatScreen widget

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});
  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _controller = TextEditingController();

  void _postMessage() async {
    if (_controller.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('posts').add({
        'text': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUser?.uid,
        'Likes': [],
        'commentCount': 0, 
      });
      _controller.clear();
    }
  }

  Future<String> _getUsername(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['username'] ?? 'Unknown User';
  }

  void _toggleLike(String postId, List<String> likes) async {
    final userId = currentUser?.uid;
    if (userId == null) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    if (likes.contains(userId)) {
      await postRef.update({
        'Likes': FieldValue.arrayRemove([userId])
      });
    } else {
      await postRef.update({
        'Likes': FieldValue.arrayUnion([userId])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE6B2),
      appBar: AppBar(
        title: const Text('Cup Social'),
        backgroundColor: const Color(0xFFFBE6B2),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final timestamp = message['timestamp'] as Timestamp?;
                    final time = timestamp != null
                        ? DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate())
                        : 'Unknown Time';
                    final userId = message['userId'];

                    return FutureBuilder<String>(
                      future: _getUsername(userId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return WallPost(
                          text: message['text'],
                          user: userSnapshot.data!,
                          time: time,
                          postId: message.id,
                          likes: List<String>.from(message['Likes'] ?? []),
                          onLike: () => _toggleLike(message.id, List<String>.from(message['Likes'] ?? [])),
                          commentCount: (message.data() as Map<String, dynamic>).containsKey('commentCount') ? message['commentCount'] : 0, // Provide default value
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Send your Post',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _postMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}