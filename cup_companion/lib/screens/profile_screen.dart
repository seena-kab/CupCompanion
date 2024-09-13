// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  bool isNightMode = false; // Retrieve this from your app's settings if available

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
    }
  }

  // Build the profile header with profile picture and user info
  Widget buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNightMode
              ? [Colors.black87, Colors.black54]
              : [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('images/default_avatar.png')
                        as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: isNightMode ? Colors.black : Colors.blueAccent,
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
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
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
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
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
    return Container(
      color: isNightMode ? Colors.black : Colors.white,
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
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isNightMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isNightMode ? Colors.white70 : Colors.grey,
          ),
        ),
      ],
    );
  }

  // Build the user's bio or description
  Widget buildBioSection() {
    return Container(
      color: isNightMode ? Colors.black : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Text(
        'This is the user bio or description. You can update it to reflect your personality or share something about yourself.',
        style: TextStyle(
          fontSize: 16,
          color: isNightMode ? Colors.white70 : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Build the user's contact information
  Widget buildContactInfo() {
    return Container(
      color: isNightMode ? Colors.black : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.email,
              color: isNightMode ? Colors.white70 : Colors.blueAccent,
            ),
            title: Text(
              email,
              style: TextStyle(
                color: isNightMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Divider(color: isNightMode ? Colors.white12 : Colors.grey[300]),
          ListTile(
            leading: Icon(
              Icons.phone,
              color: isNightMode ? Colors.white70 : Colors.blueAccent,
            ),
            title: Text(
              mobileNumber,
              style: TextStyle(
                color: isNightMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the Edit Profile button
  Widget buildEditProfileButton() {
    return Container(
      color: isNightMode ? Colors.black : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Edit Profile screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isNightMode ? Colors.amberAccent : Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Edit Profile',
            style: TextStyle(
              color: isNightMode ? Colors.black : Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  // Build the user's posts grid
  Widget buildUserPosts() {
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
      color: isNightMode ? Colors.black : Colors.white,
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
    return Scaffold(
      backgroundColor: isNightMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isNightMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isNightMode ? Colors.white : Colors.black87,
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: isNightMode ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: isNightMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: buildProfileContent(),
    );
  }
}