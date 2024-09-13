// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added import for FirebaseAuth

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  bool _isEmojiVisible = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Toggle emoji keyboard visibility
  void toggleEmojiKeyboard() {
    setState(() {
      _isEmojiVisible = !_isEmojiVisible;
    });
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
          return Center(child: Text('Error loading messages.'));
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
          IconButton(
            icon: Icon(
              Icons.emoji_emotions,
              color:
                  themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
            ),
            onPressed: toggleEmojiKeyboard,
          ),
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

  // Build the emoji picker
  Widget buildEmojiPicker() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (!_isEmojiVisible) return const SizedBox.shrink();

    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _messageController.text += emoji.emoji;
          _messageController.selection = TextSelection.fromPosition(
            TextPosition(offset: _messageController.text.length),
          );
        },
        config: Config(
          verticalSpacing: 0,
          horizontalSpacing: 0,
          gridPadding: EdgeInsets.zero,
          initCategory: Category.SMILEYS,
          bgColor:
              themeNotifier.isNightMode ? Colors.grey[900]! : Colors.white,
          indicatorColor: themeNotifier.isNightMode
              ? Colors.amberAccent
              : Colors.blueAccent,
          iconColor: themeNotifier.isNightMode ? Colors.white : Colors.black,
          iconColorSelected: themeNotifier.isNightMode
              ? Colors.amberAccent
              : Colors.blueAccent,
          backspaceColor: themeNotifier.isNightMode
              ? Colors.amberAccent
              : Colors.blueAccent,
          skinToneDialogBgColor:
              themeNotifier.isNightMode ? Colors.grey[900]! : Colors.white,
          skinToneIndicatorColor: themeNotifier.isNightMode
              ? Colors.amberAccent
              : Colors.blueAccent,
          enableSkinTones: true,
          showRecents: true, // Corrected parameter name
          recentsLimit: 28,
          noRecents: const Text(
            'No Recents',
            style: TextStyle(fontSize: 20, color: Colors.black26),
            textAlign: TextAlign.center,
          ),
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL,
        ),
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
          buildEmojiPicker(),
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