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
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('users');

  // Public getters for accessing _auth and _databaseRef
  FirebaseAuth get auth => _auth; // Expose _auth as a public getter
  DatabaseReference get databaseRef => _databaseRef; // Expose _databaseRef as a public getter

  // API call for creating a User
  Future<UserCredential> createUser(String email, String password) async {
    try{
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    //Save user data in the database and set surveryCompleted to false
    await _databaseRef.child(userCredential.user!.uid).set({
      'email': email,
      'surveyCompleted': false, //New user must complete the survey
    });

    return userCredential;
    
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseAuthException(e));
    }
  }

  // API call for signing in a User
  Future<UserCredential> signIn(String email, String password) async {
    try{
    final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseAuthException(e));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      //print('Password reset email sent');
      // On successful email dispatch, you might want to notify the user
      // You can use a dialog, snackbar, or another method to communicate this
    } on FirebaseAuthException catch (e) {
      // Handle errors, such as invalid email format or no user corresponding to the email
      throw Exception(_handleFirebaseAuthException(e));
      //print('Failed to send password reset email: ${e.message}');
      // Handle the error further if needed
    }
  }

// API CALL FOR SEARCHING ADDRESS

  // Future<void> searchAddress(String address, GoogleMapController mapController,
  //     BuildContext context) async {
  //   if (address.isEmpty) return;
  //   String googleApiKey = 'AIzaSyC_MglMu-1oRrIPHDyhulXZtPgAZB4pcLA';
  //   final query = Uri.encodeComponent(address); 
  //   final url =
  //       'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=$googleApiKey';

  //   try {
  //     final response = await http.get(Uri.parse(url));

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['results'] != null && data['results'].isNotEmpty) {
  //         final location = data['results'][0]['geometry']['location'];
  //         final LatLng newPosition = LatLng(location['lat'], location['lng']);

  //         mapController.animateCamera(
  //           CameraUpdate.newCameraPosition(
  //             CameraPosition(
  //               target: newPosition,
  //               zoom: 15.0, // Adjust zoom level as needed
  //             ),
  //           ),
  //         );
  //       } else {
  //         _showDialog(context, 'No results found for this address.');
  //       }
  //     } else {
  //       _showDialog(context, 'Failed to fetch the location from the server.');
  //     }
  //   } catch (e) {
  //     _showDialog(context, 'An error occurred while fetching location: $e');
  //   }
  // }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Future<List<String>> fetchSuggestions(
  //     String input, String sessionToken) async {
  //   final String baseURL =
  //       'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  //   String googleApiKey = dotenv.env['GoogleMapsAPIKey'] ?? 'default_api_key';
  //   final String request =
  //       '$baseURL?input=$input&key=$googleApiKey&sessiontoken=$sessionToken';

  //   try {
  //     final response = await http.get(Uri.parse(request));

  //     if (response.statusCode == 200) {
  //       final result = json.decode(response.body);
  //       if (result['status'] == 'OK') {
  //         // Parse the response and return the suggestions
  //         return result['predictions']
  //             .map<String>((p) => p['description'] as String)
  //             .toList();
  //       }
  //     }
  //     return []; // Return an empty list on failure or no results
  //   } catch (e) {
  //     // Handle any exceptions here
  //     return [];
  //   }
  // }

  //Check is the user has complete the survey
  Future<bool> hasCompletedSurvey(String uid) async {
    DataSnapshot snapshot = await _databaseRef.child(uid).child('surveyCompleted').get();
    return snapshot.value == true;
  }

  //Mark the survey as completed
  Future<void> completeSurvey(String uid) async {
    await _databaseRef.child(uid).update({'surveyCompleted':true});
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The email address is alreaduyin use by another account';
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
}