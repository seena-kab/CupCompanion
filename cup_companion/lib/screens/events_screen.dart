import 'package:flutter/material.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  EventsScreenState createState() => EventsScreenState();
}

class EventsScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Options'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFBE6B2), 
      // Set the background color to amber
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Create Event Button
              ElevatedButton(
                onPressed: () {
                  // Handle create event action here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create Event clicked')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set button color to green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                  elevation: 10, // Add shadow for a modern look
                  shadowColor: Colors.white, // Shadow color
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                child: const Text('Create Event'),
              ),
              const SizedBox(height: 20), // Space between the two buttons
              // Join Event Button
              ElevatedButton(
                onPressed: () {
                  // Handle join event action here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Join Event clicked')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700], // Set button color to yellow
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                  elevation: 10, // Add shadow for a modern look
                  shadowColor: Colors.white, // Shadow color
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                child: const Text('Join Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
