// lib/services/auth_services.dart

import 'dart:async';
import 'dart:io'; // For File
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// Import other necessary packages

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('users');
  final FirebaseStorage _storage = FirebaseStorage.instance; // Initialize FirebaseStorage

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
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuth exceptions
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      // Handle other exceptions
      print('General exception during sign-in: $e');
      throw Exception('An unknown error occurred during sign-in.');
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

  /// Updates the user's profile information.
  ///
  /// [username], [email], [mobileNumber], and [location] are updated in the Realtime Database.
  /// If [profileImage] is provided, it is uploaded to Firebase Storage and the user's photoURL is updated.
  Future<void> updateUserProfile({
    required String username,
    required String email,
    required String mobileNumber,
    required String location,
    File? profileImage, // Optional new profile image
  }) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    try {
      // 1. Update email if it has changed
      if (email != user.email) {
        await user.updateEmail(email);
        // Optionally, send email verification if required
        // await user.sendEmailVerification();
      }

      // 2. Update password if needed (not handled here)

      // 3. Update profile image if provided
      String? photoURL;
      if (profileImage != null) {
        // Define the storage path
        String storagePath = 'profile_images/${user.uid}.jpg';

        // Upload the image to Firebase Storage
        UploadTask uploadTask =
            _storage.ref().child(storagePath).putFile(profileImage);

        // Wait for the upload to complete
        TaskSnapshot snapshot = await uploadTask;

        // Get the download URL
        photoURL = await snapshot.ref.getDownloadURL();

        // Update the user's photoURL
        await user.updatePhotoURL(photoURL);
      }

      // 4. Update user data in Realtime Database
      await _databaseRef.child(user.uid).update({
        'username': username,
        'email': email,
        'mobileNumber': mobileNumber,
        'location': location,
        if (photoURL != null) 'photoURL': photoURL,
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseAuthException(e));
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile.');
    }
  }

  // Update profile image method (Optional, since updateUserProfile handles it)
  Future<void> updateProfileImage(File imageFile) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference storageRef = _storage
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg'); // You can use any naming convention

      // Upload the file
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload to complete
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the user's profile with the new photo URL
      await user.updatePhotoURL(downloadUrl);

      // Optionally, if you're storing user data in Firestore, update there as well
      // Example:
      // await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      //   'photoURL': downloadUrl,
      // });
    } else {
      throw Exception('No user logged in');
    }
  }

  /// Fetches the list of favorite drinks for the currently signed-in user.
  Future<List<Map<String, String>>> getFavoriteDrinks() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    try {
      // Fetch the 'favoriteDrinks' node for the current user
      DataSnapshot snapshot =
          await _databaseRef.child(user.uid).child('favoriteDrinks').get();

      if (!snapshot.exists) {
        return []; // No favorite drinks found
      }

      // Assuming favoriteDrinks is stored as a map
      Map<dynamic, dynamic> drinksMap =
          snapshot.value as Map<dynamic, dynamic>;

      List<Map<String, String>> drinks = [];

      drinksMap.forEach((key, value) {
        // Ensure that each drink has the necessary fields
        Map<String, String> drink = {
          'name': value['name'] ?? 'Unknown Name',
          'image': value['image'] ?? '', // Adjust based on your image storage
          'details': value['details'] ?? 'No details available',
          'price': value['price']?.toString() ?? '0',
        };
        drinks.add(drink);
      });

      return drinks;
    } catch (e) {
      print('Error fetching favorite drinks: $e');
      throw Exception('Failed to fetch favorite drinks.');
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