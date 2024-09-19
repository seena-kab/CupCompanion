// lib/screens/chat_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/theme_notifier.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isSending = false; // To handle loading state during image upload

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Get the current user's ID
  String getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('No user is currently signed in.');
    }
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  // Fetch current user's details from the Realtime Database
  Future<Map<String, dynamic>> getCurrentUserDetails() async {
    final userId = getCurrentUserId();
    final DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users').child(userId);
    final DatabaseEvent event = await userRef.once();

    if (event.snapshot.value != null) {
      final userData = Map<String, dynamic>.from(event.snapshot.value as Map);
      // Process username
      String username = userData['username'] ?? 'Anonymous';
      if (username.contains('@')) {
        username = username.split('@')[0];
      }
      return {
        'username': username,
      };
    } else {
      // Fallback to FirebaseAuth displayName or email's local part
      final user = getCurrentUser()!;
      String username =
          user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous';
      return {
        'username': username,
      };
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users').child(userId);
    final DatabaseEvent event = await userRef.once();

    if (event.snapshot.value != null) {
      final userData = Map<String, dynamic>.from(event.snapshot.value as Map);
      // Process username
      String username = userData['username'] ?? 'Unknown';
      if (username.contains('@')) {
        username = username.split('@')[0];
      }
      return {
        'username': username,
      };
    } else {
      // If user data doesn't exist, fallback to default values
      return {
        'username': 'Unknown',
      };
    }
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
            final isMe = data['senderId'] == getCurrentUserId();

            return FutureBuilder<Map<String, dynamic>>(
              future: isMe
                  ? getCurrentUserDetails()
                  : getUserDetails(data['senderId']),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(); // Or a placeholder
                }
                if (userSnapshot.hasError) {
                  return const SizedBox(); // Or an error widget
                }
                final userData = userSnapshot.data!;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isMe)
                        const CircleAvatar(
                          backgroundImage: AssetImage(
                              'assets/images/default_avatar.png'),
                          radius: 20,
                        ),
                      if (!isMe) const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['username'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeNotifier>(context)
                                        .isNightMode
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.blueAccent
                                    : Provider.of<ThemeNotifier>(context)
                                            .isNightMode
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (data['message'] != null)
                                    Text(
                                      data['message'],
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Provider.of<ThemeNotifier>(
                                                        context)
                                                    .isNightMode
                                                ? Colors.white
                                                : Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                  if (data['imageUrl'] != null &&
                                      data['imageUrl']
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        data['imageUrl'],
                                        width: 210,
                                        loadingBuilder: (context, child,
                                            loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                        errorBuilder: (context, error,
                                            stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  ],
                                  // Add timestamp here
                                  const SizedBox(height: 4),
                                  if (data['timestamp'] != null)
                                    Text(
                                      formatTimestamp(data['timestamp']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isMe
                                            ? Colors.white70
                                            : Provider.of<ThemeNotifier>(
                                                        context)
                                                    .isNightMode
                                                ? Colors.white70
                                                : Colors.black54,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMe) const SizedBox(width: 8),
                      if (isMe)
                        const CircleAvatar(
                          backgroundImage: AssetImage(
                              'assets/images/default_avatar.png'),
                          radius: 20,
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Format timestamp
  String formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }

  // Send a message
  Future<void> sendMessage({String? imageUrl}) async {
    if (_messageController.text.trim().isEmpty && imageUrl == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Get the current user's details
      Map<String, dynamic> currentUserDetails =
          await getCurrentUserDetails();
      String username = currentUserDetails['username'] ?? 'Anonymous';

      await FirebaseFirestore.instance.collection('chats').add({
        'senderId': getCurrentUserId(),
        'username': username,
        'message': _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
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
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  // Pick an image from gallery and upload it
  Future<void> pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress the image
      );

      if (pickedFile != null) {
        setState(() {
          _isSending = true;
        });

        final file = File(pickedFile.path);
        final fileName = const Uuid().v4();
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_images')
            .child(fileName);
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await sendMessage(imageUrl: downloadUrl);
      }
    } catch (e) {
      // Handle image picker error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick or upload image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  // Build the message input field
  Widget buildMessageInput() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color:
          themeNotifier.isNightMode ? Colors.grey[900] : Colors.grey[100],
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            icon: Icon(
              Icons.add_photo_alternate_rounded,
              color: themeNotifier.isNightMode
                  ? Colors.amberAccent
                  : Colors.blueAccent,
              size: 28,
            ),
            onPressed: pickAndUploadImage,
          ),
          // Expanded Text Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeNotifier.isNightMode
                    ? Colors.grey[800]
                    : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: themeNotifier.isNightMode
                      ? Colors.white
                      : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(
                    color: themeNotifier.isNightMode
                        ? Colors.white70
                        : Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send Button
          _isSending
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeNotifier.isNightMode
                        ? Colors.amberAccent
                        : Colors.blueAccent,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => sendMessage(),
                  ),
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
      title: const Text(
        'Chat',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor:
          themeNotifier.isNightMode ? Colors.black : Colors.blueAccent,
      automaticallyImplyLeading: false, // Add this line to remove the back arrow
    ),
    body: Column(
      children: [
        Expanded(child: buildMessagesList()),
        buildMessageInput(),
      ],
    ),
  );
}
}