import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // For accessing the device's file system

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

        // Convert the data to JSON
        String jsonData = json.encode(data);

        // Get the directory to save the file
        Directory directory = await getApplicationDocumentsDirectory();
        String filePath = '${directory.path}/$fileName';

        // Write the JSON data to the file
        File file = File(filePath);
        await file.writeAsString(jsonData);

        print('Data exported successfully to $filePath');
      } else {
        print('Data is not a map');
      }
    } catch (error) {
      print('Failed to export data: $error');
    }
  }
}
