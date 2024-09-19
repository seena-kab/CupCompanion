// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/theme_notifier.dart';
import 'favorites_screen.dart';
import 'edit_profile_screen.dart'; // Import the new EditProfileScreen

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
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

 // Fetch user data from the database
void fetchUserData() async {
  try {
    Map<String, String> userData = await _authService.fetchUserData();
    setState(() {
      username = userData['username'] ?? 'Username';
      email = userData['email'] ?? 'Email';
      mobileNumber = userData['mobileNumber'] ?? 'Mobile Number';
      zipCode = userData['zipCode'] ?? '00000'; // Fetch the zip code
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
        await _authService.updateProfileImage(imageFile);
        setState(() {
          _profileImage = imageFile;
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

    print('Position obtained: Latitude ${position.latitude}, Longitude ${position.longitude}');

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
// Build the profile header with profile picture and user info
Widget buildProfileHeader() {
  final themeNotifier = Provider.of<ThemeNotifier>(context);
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: themeNotifier.isNightMode
            ? [Colors.black87, Colors.black54]
            : [Colors.blueAccent, Colors.lightBlueAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Column(
      children: [
          // Profile Picture with PopupMenuButton
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  // Allow users to pick a new profile image
                  pickImage();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      themeNotifier.isNightMode ? Colors.grey[800] : Colors.white,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Handle Edit Profile
                      // Navigate to EditProfileScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    } else if (value == 'signout') {
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
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: themeNotifier.isNightMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          const Text('Edit Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'signout',
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: themeNotifier.isNightMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          const Text('Sign Out'),
                        ],
                      ),
                    ),
                  ],
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: themeNotifier.isNightMode
                          ? Colors.black
                          : Colors.blueAccent,
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
          style: TextStyle(
            fontSize: 28,
            color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        // Location
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: themeNotifier.isNightMode ? Colors.white70 : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 5),
            Text(
              location,
              style: TextStyle(
                fontSize: 16,
                color: themeNotifier.isNightMode ? Colors.white70 : Colors.grey[600],
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
      color: themeNotifier.isNightMode ? Colors.black : Colors.white,
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
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
          ),
        ),
      ],
    );
  }

  // Build the user's bio or description
  Widget buildBioSection() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      color: themeNotifier.isNightMode ? Colors.black : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Text(
        'This is the user bio or description. You can update it to reflect your personality or share something about yourself.',
        style: TextStyle(
          fontSize: 16,
          color: themeNotifier.isNightMode ? Colors.white70 : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Build the user's contact information
  Widget buildContactInfo() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      color: themeNotifier.isNightMode ? Colors.black : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.email,
              color: themeNotifier.isNightMode ? Colors.white70 : Colors.blueAccent,
            ),
            title: Text(
              email,
              style: TextStyle(
                color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Divider(
              color:
                  themeNotifier.isNightMode ? Colors.white12 : Colors.grey[300]),
          ListTile(
            leading: Icon(
              Icons.phone,
              color: themeNotifier.isNightMode ? Colors.white70 : Colors.blueAccent,
            ),
            title: Text(
              mobileNumber,
              style: TextStyle(
                color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
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
    return Container(
      color: themeNotifier.isNightMode ? Colors.black : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Edit Profile screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                themeNotifier.isNightMode ? Colors.amberAccent : Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Edit Profile',
            style: TextStyle(
              color: themeNotifier.isNightMode ? Colors.black : Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  // Build the user's posts grid
  Widget buildUserPosts() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    // Placeholder for user posts
    List<Map<String, String>> userPosts = [
      {'image': 'assets/images/logo.png'},
      {'image': 'assets/images/logo.png'},
      {'image': 'assets/images/logo.png'},
      {'image': 'assets/images/logo.png'},
      {'image': 'assets/images/logo.png'},
      {'image': 'assets/images/logo.png'},
    ];

    return Container(
      color: themeNotifier.isNightMode ? Colors.black : Colors.white,
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: userPosts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          return Image.asset(
            userPosts[index]['image']!,
            fit: BoxFit.cover,
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
    return Scaffold(
      backgroundColor: themeNotifier.isNightMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themeNotifier.isNightMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: const [
          // Optional: Add action buttons if needed
          // Currently, the logout button is handled within the PopupMenuButton in the profile header
        ],
      ),
      body: buildProfileContent(),
      // Add navigation to Favorites via FloatingActionButton or another method
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to FavoritesScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FavoritesScreen(),
            ),
          );
        },
        backgroundColor:
            themeNotifier.isNightMode ? Colors.amberAccent : Colors.blueAccent,
        tooltip: 'Favorites',
        child: const Icon(Icons.favorite),
      ),
    );
  }
}