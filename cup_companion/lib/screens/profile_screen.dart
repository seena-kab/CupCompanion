// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme_notifier.dart';
import 'add_drink_dialog.dart';
import 'favorites_screen.dart';
import 'edit_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cup_companion/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  String username = 'Username';
  String zipCode = "00000";
  String email = 'Email';
  String mobileNumber = 'Mobile Number';
  String location = 'Location';
  String bio = 'This is the user bio or description. You can update it to reflect your personality or share something about yourself.';
  String profileImageUrl = '';
  File? _profileImage;

  List<Map<String, dynamic>> userDrinks = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUserDrinks();
  }

  // Fetch user data from the database
  void fetchUserData() async {
    try {
      Map<String, dynamic> userData = await _authService.fetchUserDataWithImage();
      setState(() {
        username = userData['username'] ?? 'Username';
        email = userData['email'] ?? 'Email';
        mobileNumber = userData['mobileNumber'] ?? 'Mobile Number';
        zipCode = userData['zipCode'] ?? '00000';
        bio = userData['bio'] ?? bio;
        profileImageUrl = userData['profileImageUrl'] ?? '';
      });
      // After fetching user data, get the location
      getUserLocation();
    } catch (e) {
      // Handle errors
      print('Error fetching user data: $e');
      // Optionally, set default values or show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user data: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      // Attempt to get user location even if fetching user data fails
      getUserLocation();
    }
  }

  void fetchUserDrinks() async {
    try {
      // Get the current user's UID
      String? userId = _authService.getCurrentUserId();

      // Fetch drinks where 'createdBy' equals the user's UID
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('drinks')
          .where('createdBy', isEqualTo: userId)
          .get();

      // Map the documents to a list
      List<Map<String, dynamic>> drinks = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'imageUrl': doc['imageUrl'],
          'description': doc['description'],
          'price': doc['price'],
          'isAlcoholic': doc['isAlcoholic'],
        };
      }).toList();

      setState(() {
        userDrinks = drinks;
      });
    } catch (e) {
      print('Error fetching user drinks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load your drinks: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Pick an image from the gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Convert XFile to File
      File imageFile = File(pickedFile.path);

      // Upload the image and update profile
      try {
        String imageUrl = await _authService.updateProfileImage(imageFile);
        setState(() {
          _profileImage = imageFile;
          profileImageUrl = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Handle upload errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      setState(() {
        location = 'Zip Code: $zipCode';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('Location permission is denied. Requesting permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('User denied location permission.');
        setState(() {
          location = 'Zip Code: $zipCode';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission is permanently denied.');
      setState(() {
        location = 'Zip Code: $zipCode';
      });
      return;
    }

    print('Location permission granted. Fetching position...');
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
          'Position obtained: Latitude ${position.latitude}, Longitude ${position.longitude}');

      // Update the location variable with latitude and longitude
      setState(() {
        location = 'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Lng: ${position.longitude.toStringAsFixed(6)}';
      });
      print('Location updated to: $location');
    } catch (e, stacktrace) {
      print('Error in getUserLocation(): $e');
      print('Stacktrace: $stacktrace');
      setState(() {
        location = 'Zip Code: $zipCode';
      });
    }
  }

  // Build the profile header with profile picture and user info
  Widget buildProfileHeader() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFC3A0), Color(0xFFFDF3E7)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        children: [
          // Profile Picture with Edit Icon
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider),
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    // Allow users to pick a new profile image
                    pickImage();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Username
          Text(
            username,
            style: GoogleFonts.montserrat(
              fontSize: 28,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.black54,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                location,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build the statistics section (e.g., posts, followers, following)
  Widget buildStatisticsSection() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildStatisticItem('Posts', '34'),
          buildStatisticItem('Followers', '1.2K'),
          buildStatisticItem('Following', '180'),
        ],
      ),
    );
  }

  // Helper method to build a single statistic item
  Widget buildStatisticItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Build the user's bio or description
  Widget buildBioSection() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Text(
            bio,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.black54),
              onPressed: () async {
                // Open dialog to edit bio
                final newBio = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    String updatedBio = bio;
                    return AlertDialog(
                      title: Text(appLocalizations.editBio),
                      content: TextField(
                        maxLines: 4,
                        onChanged: (value) {
                          updatedBio = value;
                        },
                        controller: TextEditingController(text: bio),
                        decoration: InputDecoration(
                          hintText: appLocalizations.enterYourBio,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(appLocalizations.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, updatedBio),
                          child: Text(appLocalizations.save),
                        ),
                      ],
                    );
                  },
                );

                if (newBio != null && newBio != bio) {
                  // Update bio in Firestore
                  try {
                    await _authService.updateUserBio(newBio);
                    setState(() {
                      bio = newBio;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLocalizations.bioUpdated),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${appLocalizations.failedToUpdateBio}: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build the user's contact information
  Widget buildContactInfo() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.email,
              color: Colors.black54,
            ),
            title: Text(
              email,
              style: GoogleFonts.montserrat(
                color: Colors.black87,
              ),
            ),
          ),
          Divider(color: Colors.grey[300]),
          ListTile(
            leading: const Icon(
              Icons.phone,
              color: Colors.black54,
            ),
            title: Text(
              mobileNumber,
              style: GoogleFonts.montserrat(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the Edit Profile button
  Widget buildEditProfileButton() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!;
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Edit Profile screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            ).then((_) {
              fetchUserData();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC3A0),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            appLocalizations.editProfile,
            style: GoogleFonts.montserrat(
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUserPosts() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    if (userDrinks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'You have not added any drinks yet.',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      );
    }

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: userDrinks.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          final drink = userDrinks[index];
          return GestureDetector(
            onTap: () {
              // Optionally navigate to drink details
            },
            child: Image.network(
              drink['imageUrl'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Build the entire profile page content
  Widget buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildProfileHeader(),
          buildStatisticsSection(),
          const SizedBox(height: 10),
          buildBioSection(),
          const SizedBox(height: 10),
          buildContactInfo(),
          buildEditProfileButton(),
          const SizedBox(height: 10),
          buildUserPosts(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
        title: Text(
          appLocalizations.profile,
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle Sign Out
              _authService.signOut().then((_) {
                Navigator.pushReplacementNamed(context, '/signin');
              }).catchError((error) {
                // Handle sign out error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out: $error'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              });
            },
            tooltip: appLocalizations.signOut,
          ),
        ],
      ),
      body: buildProfileContent(),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'favorites_button',
              onPressed: () {
                // Navigate to FavoritesScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
              backgroundColor: Colors.redAccent,
              tooltip: appLocalizations.favorites,
              child: const Icon(Icons.favorite),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'add_drink_button',
              onPressed: () {
                // Show the AddDrinkDialog when the button is pressed
                showDialog(
                  context: context,
                  builder: (context) => const AddDrinkDialog(),
                ).then((_) {
                  fetchUserDrinks();
                });
              },
              backgroundColor: Colors.orangeAccent,
              tooltip: appLocalizations.addDrink,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}