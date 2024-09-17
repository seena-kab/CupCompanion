// auth_service.dart

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'dart:convert';
//import 'package:http/http.dart' as http;
//import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('users');

  // Public getters for accessing _auth and _databaseRef
  FirebaseAuth get auth => _auth; // Expose _auth as a public getter
  DatabaseReference get databaseRef =>
      _databaseRef; // Expose _databaseRef as a public getter

  // API call for creating a User
  Future<UserCredential> createUser(
      String email, String password, String username, String mobileNumber) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data in the database and set surveyCompleted to false
      await _databaseRef.child(userCredential.user!.uid).set({
        'email': email,
        'username': username,
        'mobileNumber': mobileNumber, // Save the mobile number
        'surveyCompleted': false, // New user must complete the survey
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseAuthException(e));
    }
  }

Future<UserCredential> signIn(String email, String password) async {
  try {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    // Handle specific FirebaseAuth exceptions
    print('FirebaseAuthException: ${e.code} - ${e.message}');
    rethrow; // Rethrow to be handled by the caller if needed
  } catch (e) {
    // Handle other exceptions
    print('General exception during sign-in: $e');
    rethrow;
  }
}


  // Fetch user data (username, location, and mobile number)
  Future<Map<String, String>> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      DataSnapshot snapshot = await _databaseRef.child(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(snapshot.value as Map);
        String username = userData['username'] ?? 'Unknown User';
        String location = userData['location'] ?? 'Unknown Location';
        String mobileNumber = userData['mobileNumber'] ?? 'Unknown Number';
        return {
          'username': username,
          'location': location,
          'mobileNumber': mobileNumber,
        };
      } else {
        return {
          'username': 'Unknown User',
          'location': 'Unknown Location',
          'mobileNumber': 'Unknown Number',
        };
      }
    } else {
      throw Exception('No user is currently signed in.');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // On successful email dispatch, you might want to notify the user
    } on FirebaseAuthException catch (e) {
      // Handle errors, such as invalid email format or no user corresponding to the email
      throw Exception(_handleFirebaseAuthException(e));
    }
  }

  // Sign-out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }


  // Method to get the current user with error handling
  User? getCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (e) {
      // Log the error or handle it appropriately
      print('Error getting current user: $e');
      return null;
    }
  }

  // Method to get the current user's ID with error handling
  String? getCurrentUserId() {
    try {
      return _auth.currentUser?.uid;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  // Method to get the current user's display name with error handling
  String? getCurrentUserDisplayName() {
    try {
      return _auth.currentUser?.displayName;
    } catch (e) {
      print('Error getting current user display name: $e');
      return null;
    }
  }


  // API CALL FOR SEARCHING ADDRESS
  /*
  Future<void> searchAddress(String address, GoogleMapController mapController,
      BuildContext context) async {
    if (address.isEmpty) return;
    String googleApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    final query = Uri.encodeComponent(address);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final LatLng newPosition = LatLng(location['lat'], location['lng']);

          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: newPosition,
                zoom: 15.0, // Adjust zoom level as needed
              ),
            ),
          );
        } else {
          _showDialog(context, 'No results found for this address.');
        }
      } else {
        _showDialog(context, 'Failed to fetch the location from the server.');
      }
    } catch (e) {
      _showDialog(context, 'An error occurred while fetching location: $e');
    }
  }
  */

  /*
  Future<List<String>> fetchSuggestions(
      String input, String sessionToken) async {
    final String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String googleApiKey = dotenv.env['GoogleMapsAPIKey'] ?? 'default_api_key';
    final String request =
        '$baseURL?input=$input&key=$googleApiKey&sessiontoken=$sessionToken';

    try {
      final response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          // Parse the response and return the suggestions
          return result['predictions']
              .map<String>((p) => p['description'] as String)
              .toList();
        }
      }
      return []; // Return an empty list on failure or no results
    } catch (e) {
      // Handle any exceptions here
      return [];
    }
  }
  */

  // Check if the user has completed the survey
  Future<bool> hasCompletedSurvey(String uid) async {
    DataSnapshot snapshot =
        await _databaseRef.child(uid).child('surveyCompleted').get();
    return snapshot.value == true;
  }

  // Mark the survey as completed
  Future<void> completeSurvey(String uid) async {
    await _databaseRef.child(uid).update({'surveyCompleted': true});
  }

  // Handle Firebase Authentication exceptions
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email address is already in use by another account';
      case 'invalid-email':
        return 'The email address is not valid';
      case 'weak-password':
        return 'The password provided is too weak';
      case 'wrong-password':
        return 'The password is incorrect';
      case 'user-not-found':
        return 'No user found with this email';
      default:
        return 'An unknown error occurred: ${e.message}';
    }
  }

  // Method to show a dialog (used in the searchAddress method)
  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}