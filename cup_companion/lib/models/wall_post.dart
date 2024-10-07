import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WallPost extends StatefulWidget {
  final String text;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final int commentCount;
  final VoidCallback onLike;

  const WallPost({
    super.key,
    required this.text,
    required this.user,
    required this.time,
    required this.postId,
    required this.likes,
    required this.commentCount,
    required this.onLike,
  });

  @override
  _WallPostState createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  late List<String> likes;
  late int commentCount;
  final _commentTextController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    likes = widget.likes;
    commentCount = widget.commentCount;
    print('Current user email: ${currentUser?.email}');
    print('Post user email: ${widget.user}');
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

  void addComment(String commentText) {
    if (currentUser != null) {
      FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
        "CommentText": commentText,
        "CommentedBy": currentUser!.email, // Use the current user's email
        "CommentTime": Timestamp.now(),
      });

      FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        "commentCount": FieldValue.increment(1),
      });

      setState(() {
        commentCount += 1;
      });
    }
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add a comment"),
          content: TextField(
            controller: _commentTextController,
            decoration: InputDecoration(hintText: "Enter your comment here"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                addComment(_commentTextController.text);
                _commentTextController.clear();
                Navigator.pop(context);
              },
              child: Text("Post"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final commentsSnapshot = await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .get();

                for (var doc in commentsSnapshot.docs) {
                  await doc.reference.delete();
                }

                await FirebaseFirestore.instance.collection('posts').doc(widget.postId).delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Post deleted successfully')),
                );

                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete post: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract the username part of the current user's email
    final currentUserEmail = currentUser?.email?.split('@')[0];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              Spacer(),
              if (currentUserEmail == widget.user)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: deletePost,
                ),
            ],
          ),
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
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: showCommentDialog,
              ),
              Text('$commentCount'),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .collection('comments')
                .orderBy('CommentTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final comments = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final commentText = comment['CommentText'];
                  final commentedBy = comment['CommentedBy'];
                  final commentTime = (comment['CommentTime'] as Timestamp).toDate();
                  final formattedTime = DateFormat('yyyy-MM-dd – kk:mm').format(commentTime);

                  return ListTile(
                    title: Text(commentedBy),
                    subtitle: Text(commentText),
                    trailing: Text(formattedTime),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}