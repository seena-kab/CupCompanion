import 'package:flutter/material.dart';

class ForumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          ForumPost(
            username: 'User1',
            postTime: '2 hours ago',
            content: 'This is the first post content.',
          ),
          ForumPost(
            username: 'User2',
            postTime: '3 hours ago',
            content: 'This is the second post content.',
          ),
          ForumPost(
            username: 'User3',
            postTime: '5 hours ago',
            content: 'This is the third post content.',
          ),
        ],
      ),
    );
  }
}

class ForumPost extends StatelessWidget {
  final String username;
  final String postTime;
  final String content;

  ForumPost({required this.username, required this.postTime, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(username[0]),
                ),
                SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(postTime),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ForumScreen(),
  ));
}