// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';
import 'package:cup_companion/screens/chat_screen.dart';
import 'package:cup_companion/screens/profile_screen.dart';
import 'package:cup_companion/screens/map_screen.dart';
import 'package:cup_companion/screens/marketplace_screen.dart';
import 'package:cup_companion/screens/favorites_screen.dart';
import 'package:cup_companion/screens/notifications_screen.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  String username = "Username";
  String location = "Location";
  int rewardPoints = 457;
  int _selectedIndex = 0; // Tracks selected bottom navigation tab
  int _notificationCount = 3; // Number of notifications

  // Stores the favorite drinks
  List<Map<String, String>> favoriteDrinks = [];

  // Categories for day mode
  final List<String> categoriesDayMode = [
    'Coffee',
    'Tea',
    'Juice',
    'Smoothies',
    'Alcoholic Selections',
  ];

  // Categories for night mode (Alcoholic Selections)
  final List<String> categoriesNightMode = [
    'Beer',
    'Wine',
    'Whiskey',
    'Vodka',
    'Non-Alcoholic Selections',
  ];

  // Mock data for drink cards
  final List<Map<String, String>> drinkList = [
    {
      'image': 'assets/images/logo.png', // Updated to use logo.png
      'name': 'Cappuccino',
      'details': 'with Oat Milk',
      'price': '3.90',
    },
    {
      'image': 'assets/images/logo.png', // Updated to use logo.png
      'name': 'Latte',
      'details': 'with Soy Milk',
      'price': '4.50',
    },
    {
      'image': 'assets/images/logo.png', // Updated to use logo.png
      'name': 'Espresso',
      'details': 'double shot',
      'price': '2.80',
    },
    {
      'image': 'assets/images/logo.png', // Updated to use logo.png
      'name': 'Mocha',
      'details': 'with Chocolate',
      'price': '4.20',
    },
    // Add more drinks as needed
  ];

  // Fetch user data (username and location)
  void fetchUserData() async {
    try {
      Map<String, String> userData = await _authService.fetchUserData();
      setState(() {
        username = userData['username'] ?? 'Username';
        location = userData['location'] ?? 'Location';
      });
    } catch (e) {
      // Handle any errors here
      setState(() {
        username = 'Username';
        location = 'Location';
      });
    }
  }

  // Callback for filter button in SearchBar
  void onFilterTap() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: themeNotifier.isNightMode ? Colors.grey[850] : Colors.white,
          child: Center(
            child: Text(
              'Filter options here',
              style: TextStyle(
                color: themeNotifier.isNightMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Called when a tab is selected in the bottom navigation bar
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Builds the bottom navigation bar with 6 items
  Widget buildBottomNavigationBar() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return BottomNavigationBar(
      backgroundColor: themeNotifier.isNightMode ? Colors.black : Colors.white,
      selectedItemColor:
          themeNotifier.isNightMode ? Colors.amberAccent : Colors.blueAccent,
      unselectedItemColor:
          themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onTabSelected,
      type: BottomNavigationBarType.fixed, // To show all items
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      backgroundColor:
          themeNotifier.isNightMode ? Colors.black : Colors.grey[50],
      body: Stack(
        children: [
          _selectedIndex == 0
              ? buildHomeScreenContent()
              : _selectedIndex == 1
                  ? buildFavoritesScreen()
                  : _selectedIndex == 2
                      ? const MapScreen()
                      : _selectedIndex == 3
                          ? const MarketplaceScreen()
                          : _selectedIndex == 4
                              ? const ChatScreen()
                              : const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  // Builds the main home screen content with GridView for drinks
  Widget buildHomeScreenContent() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeNotifier.isNightMode
                  ? [Colors.black87, Colors.black54]
                  : [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              buildHeader(),
              const SizedBox(height: 20),
              buildDayNightSwitch(),
              const SizedBox(height: 20),
              SearchBar(onFilterTap: onFilterTap), // Provide valid callback
              const SizedBox(height: 20),
            ],
          ),
        ),
        RewardsSection(points: rewardPoints), // Updated RewardsSection
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'For You:',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color:
                    themeNotifier.isNightMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        themeNotifier.isNightMode
            ? buildNightModeCategoryList()
            : buildDayModeCategoryList(),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              itemCount: drinkList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 per row
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 4, // Adjust as needed
              ),
              itemBuilder: (context, index) {
                return buildDrinkCard(drinkList[index]);
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Builds the Favorites screen content
  Widget buildFavoritesScreen() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Center(
      child: Text(
        'Favorites Screen',
        style: TextStyle(
          color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
          fontSize: 24,
        ),
      ),
    );
  }

  // Placeholder screen for other tabs (if any)
  Widget buildPlaceholderScreen(String text) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
          fontSize: 24,
        ),
      ),
    );
  }

  // Builds the header with profile picture, username, and location
  Widget buildHeader() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile Picture and Username
        Row(
          children: [
            // Profile Picture Placeholder
            GestureDetector(
              onTap: () {
                // Navigate to Profile Screen
                Navigator.pushNamed(context, '/profile');
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage:
                    const AssetImage('assets/images/default_avatar.png'),
              ),
            ),
            const SizedBox(width: 10),
            // Username and Location
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $username',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Notification Icon and Settings Icon with Drop-down Menu
        Row(
          children: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color:
                        themeNotifier.isNightMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    // Handle notification icon press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
                if (_notificationCount > 0)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.settings,
                color: themeNotifier.isNightMode ? Colors.white : Colors.black,
              ),
              onSelected: (String value) {
                if (value == 'Settings') {
                  Navigator.pushNamed(context, '/settings');
                } else if (value == 'Sign Out') {
                  _authService.signOut();
                  Navigator.pushReplacementNamed(context, '/signin');
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Settings', 'Sign Out'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ],
    );
  }

  // Builds the day/night mode switch
  Widget buildDayNightSwitch() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.wb_sunny,
          color: Colors.white70,
        ),
        Switch(
          value: themeNotifier.isNightMode,
          activeColor: Colors.amberAccent,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.white70,
          onChanged: (bool value) {
            themeNotifier.toggleTheme(value);
          },
        ),
        const Icon(
          Icons.nightlight_round,
          color: Colors.white70,
        ),
      ],
    );
  }

  // Builds the category list for day mode
  Widget buildDayModeCategoryList() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoriesDayMode.length,
        itemBuilder: (context, index) {
          return buildCategoryChip(categoriesDayMode[index]);
        },
      ),
    );
  }

  // Builds the category list for night mode
  Widget buildNightModeCategoryList() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoriesNightMode.length,
        itemBuilder: (context, index) {
          return buildCategoryChip(categoriesNightMode[index]);
        },
      ),
    );
  }

  // Builds individual category chips
  Widget buildCategoryChip(String category) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Chip(
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[800] : Colors.grey[300],
        label: Text(
          category,
          style: TextStyle(
            color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Builds individual drink cards in a grid
  Widget buildDrinkCard(Map<String, String> drink) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return GestureDetector(
      onTap: () {
        // Handle drink card tap, e.g., navigate to drink details
        // Navigator.push(context, MaterialPageRoute(builder: (context) => DrinkDetailsScreen(drink: drink)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: themeNotifier.isNightMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeNotifier.isNightMode
                  ? Colors.black26
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drink Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  drink['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            // Drink Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    drink['name']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          themeNotifier.isNightMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    drink['details']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeNotifier.isNightMode
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${drink['price']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeNotifier.isNightMode
                          ? Colors.amberAccent
                          : Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SearchBar widget with updated styling
class SearchBar extends StatelessWidget {
  final VoidCallback onFilterTap;

  const SearchBar({
    Key? key,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: themeNotifier.isNightMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(50), // More rounded corners
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor:
              themeNotifier.isNightMode ? Colors.grey[850] : Colors.white,
          hintText: 'Search for a beverage',
          hintStyle: TextStyle(
            color: themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.tune,
              color: themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
            ),
            onPressed: onFilterTap,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none, // Removes the border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: themeNotifier.isNightMode ? Colors.white70 : Colors.blueAccent,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        style: TextStyle(
          color: themeNotifier.isNightMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

// RewardsSection widget
class RewardsSection extends StatelessWidget {
  final int points;

  const RewardsSection({
    Key? key,
    required this.points,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 60, // Adjust height as needed
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: themeNotifier.isNightMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(30), // Rounded corners for a skinny rectangle
          boxShadow: [
            BoxShadow(
              color: themeNotifier.isNightMode
                  ? Colors.black54
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Rewards Information
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.stars,
                    color: Colors.amberAccent,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rewards Points',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '$points Points',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeNotifier.isNightMode
                              ? Colors.amberAccent
                              : Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Redeem Button
            ElevatedButton(
              onPressed: () {
                // Handle Redeem button tap
                Navigator.pushNamed(context, '/redeem'); // Example navigation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeNotifier.isNightMode
                    ? Colors.amberAccent
                    : Colors.blueAccent, // Updated parameter
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Redeem',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}