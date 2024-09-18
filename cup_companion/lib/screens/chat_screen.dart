// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure FirebaseAuth is imported

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Build the chat messages list
  Widget buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading messages.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data = messages[index].data() as Map<String, dynamic>;
            final isMe = data['senderId'] == _authService.getCurrentUserId();
            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                margin:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.blueAccent
                      : Provider.of<ThemeNotifier>(context).isNightMode
                          ? Colors.grey[800]
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data['message'] ?? '',
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : Provider.of<ThemeNotifier>(context).isNightMode
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Send a message
  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('chats').add({
        'senderId': _authService.getCurrentUserId(),
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      // Handle send message error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Build the message input field
  Widget buildMessageInput() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: themeNotifier.isNightMode ? Colors.grey[900] : Colors.white,
      child: Row(
        children: [
          // Removed Emoji IconButton
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color:
                    themeNotifier.isNightMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(
                  color: themeNotifier.isNightMode
                      ? Colors.white70
                      : Colors.grey,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: themeNotifier.isNightMode
                  ? Colors.amberAccent
                  : Colors.blueAccent,
            ),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.black : Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(child: buildMessagesList()),
          buildMessageInput(),
          // Removed buildEmojiPicker()
        ],
      ),
    );
  }
}

// Extension to AuthService to get the current user's ID
extension AuthServiceExtension on AuthService {
  String getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('No user is currently signed in.');
    }
  }
}