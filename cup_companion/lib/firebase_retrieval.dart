import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';


Future<void> initializeFirebase(FirebaseOptions options) async {
  await Firebase.initializeApp(options: options);
}

class DatabaseHelper {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<String> fetchUserName(String userId) async {
    DataSnapshot snapshot = await _database.child('names/$userId/name').once().then((snapshot) {
      return snapshot as DataSnapshot; // Cast snapshot to DataSnapshot
    });
    return snapshot.value.toString();
  }
}







