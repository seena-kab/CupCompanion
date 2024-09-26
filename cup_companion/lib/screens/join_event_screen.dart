import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JoinEventScreen extends StatelessWidget {
  const JoinEventScreen({super.key});

  // Fetch events from Firestore
  Stream<QuerySnapshot> _fetchEvents() {
    return FirebaseFirestore.instance.collection('events').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Event'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchEvents(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          // Check if loading data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If the snapshot has data, show the list of events
          if (snapshot.hasData && snapshot.data != null) {
            final events = snapshot.data!.docs;

            if (events.isEmpty) {
              return const Center(
                child: Text('No events available.'),
              );
            }

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                String title = event['title'] ?? 'No Title';
                String description = event['description'] ?? 'No Description';
                Timestamp eventTimestamp = event['date'];
                DateTime eventDate = eventTimestamp.toDate();
                String formattedDate =
                    "${eventDate.year}-${eventDate.month}-${eventDate.day} ${eventDate.hour}:${eventDate.minute}";

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date & Time: $formattedDate',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Handle when the user is interested in the event
                                FirebaseFirestore.instance
                                    .collection('events')
                                    .doc(event.id)
                                    .update({
                                  'interested': FieldValue.arrayUnion(['User']) // Update with current user ID/Name
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('You have shown interest in "$title".'),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: const Text('Interested'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          // If no data, show a message
          return const Center(
            child: Text('No events found'),
          );
        },
      ),
    );
  }
}
