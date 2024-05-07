import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:html' as html;


Future<void> initializeFirebase(FirebaseOptions options) async {
  await Firebase.initializeApp(options: options);
}

class DatabaseHelper {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> exportData(String path, String fileName) async {
    try {
      DatabaseEvent event = await _database.child(path).once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        // Convert the data to JSON and encode it as a blob
        String jsonData = json.encode(data);
        var blob = html.Blob([jsonData], 'application/json');

        // Create a URL for the blob and make it downloadable
        var url = html.Url.createObjectUrlFromBlob(blob);
        var anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fileName;
        html.document.body!.children.add(anchor);

        // Simulate a click on the anchor to start the download
        anchor.click();

        // Clean up: remove the anchor from the document and revoke the blob URL
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        print('Data exported successfully to $fileName');
      } else {
        print('Data is not a map');
      }
    } catch (error) {
      print('Failed to export data: $error');
    }
  }
}









