import 'package:flutter/material.dart';

class WallPost extends StatefulWidget {
  final String text;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final VoidCallback onLike;

  const WallPost({
    super.key,
    required this.text,
    required this.user,
    required this.time,
    required this.postId,
    required this.likes,
    required this.onLike,
  });

  @override
  _WallPostState createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  late List<String> likes;

  @override
  void initState() {
    super.initState();
    likes = widget.likes;
  }

  void _handleLike() {
    widget.onLike();
    setState(() {
      if (likes.contains(widget.postId)) {
        likes.remove(widget.postId);
      } else {
        likes.add(widget.postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ), // BoxDecoration
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          // profile pic
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[400],
            ),
            padding: EdgeInsets.all(10),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ), // Container
          const SizedBox(width: 20),
          // message and user email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[500]),
              ), // Text
              const SizedBox(height: 5),
              Text(
                widget.time,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ), // Text
              const SizedBox(height: 10),
              Text(widget.text),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      likes.contains(widget.postId) ? Icons.favorite : Icons.favorite_border,
                      color: likes.contains(widget.postId) ? Colors.red : Colors.grey,
                    ),
                    onPressed: _handleLike,
                  ),
                  Text('${likes.length}'),
                ],
              ),
            ],
          ), // Column
        ],
      ), // Row
    ); // Container
  } // build method
} // WallPost class