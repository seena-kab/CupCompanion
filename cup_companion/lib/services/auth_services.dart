// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'dart:convert';
//import 'package:http/http.dart' as http;
//import 'package:flutter_dotenv/flutter_dotenv.dart';
class AuthService {
  // API call for creating a User
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> createUser(String email, String password) async {
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  // API call for signing in a User
  Future<UserCredential> signIn(String email, String password) async {
    final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
      // On successful email dispatch, you might want to notify the user
      // You can use a dialog, snackbar, or another method to communicate this
    } on FirebaseAuthException catch (e) {
      // Handle errors, such as invalid email format or no user corresponding to the email
      print('Failed to send password reset email: ${e.message}');
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
}