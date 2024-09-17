// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  String username = 'Username';
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
        location = userData['location'] ?? 'Location';
      });
    } catch (e) {
      // Handle errors
      print('Error fetching user data: $e');
      // Optionally, set default values or show an error message to the user
    }
  }

  // Pick an image from the gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload the image to the database or storage here
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // Optionally, upload the image to your backend or Firebase Storage
      // and update the user's profile picture URL in the database
    }
  }

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
              CircleAvatar(
                radius: 60,
                backgroundColor:
                    themeNotifier.isNightMode ? Colors.grey[800] : Colors.white,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
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
                color:
                    themeNotifier.isNightMode ? Colors.white70 : Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                location,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      themeNotifier.isNightMode ? Colors.white70 : Colors.grey[600],
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              // Handle logout
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
          ),
        ],
      ),
      body: buildProfileContent(),
    );
  }
}

// Placeholder for EditProfileScreen
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: themeNotifier.isNightMode ? Colors.black : Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Edit Profile Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}