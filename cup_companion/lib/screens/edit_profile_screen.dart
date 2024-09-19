// lib/screens/edit_profile_screen.dart

import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import '../theme/theme_notifier.dart';
import '../services/auth_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();

  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    populateUserData();
  }

  // Populate the text fields with existing user data
  void populateUserData() async {
    try {
      Map<String, String> userData = await _authService.fetchUserData();
      setState(() {
        _usernameController.text = userData['username'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _mobileNumberController.text = userData['mobileNumber'] ?? '';
        _locationController.text = userData['location'] ?? '';
      });
    } catch (e) {
      // Handle errors appropriately
      print('Error fetching user data for editing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user data: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Pick a new profile image
  Future<void> pickNewImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
      // Optionally, upload the image to your backend or Firebase Storage
    }
  }

  // Save the updated profile information
  void saveProfile() async {
    String updatedUsername = _usernameController.text.trim();
    String updatedEmail = _emailController.text.trim();
    String updatedMobileNumber = _mobileNumberController.text.trim();
    String updatedLocation = _locationController.text.trim();

    // Perform validation if necessary
    if (updatedUsername.isEmpty ||
        updatedEmail.isEmpty ||
        updatedMobileNumber.isEmpty ||
        updatedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await _authService.updateUserProfile(
        username: updatedUsername,
        email: updatedEmail,
        mobileNumber: updatedMobileNumber,
        location: updatedLocation,
        profileImage: _newProfileImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Go back to the ProfileScreen
    } catch (e) {
      // Handle update errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Image Section
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: themeNotifier.isNightMode
                        ? Colors.grey[800]
                        : Colors.white,
                    backgroundImage: _newProfileImage != null
                        ? FileImage(_newProfileImage!)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: pickNewImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: themeNotifier.isNightMode
                              ? Colors.grey[700]
                              : Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Username TextField
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Mobile Number TextField
              TextField(
                controller: _mobileNumberController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              // Location TextField
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Save Button
              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeNotifier.isNightMode
                      ? Colors.amberAccent
                      : Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}