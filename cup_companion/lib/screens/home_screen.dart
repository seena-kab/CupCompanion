import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart'; // Corrected import
import 'package:cup_companion/screens/profile_screen.dart';
import 'package:cup_companion/screens/settings_screen.dart';
import 'package:cup_companion/screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  bool isNightMode = false; // Controls day/night mode
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
      'image': 'assets/images/logo.png',
      'name': 'Cappuccino',
      'details': 'with Oat Milk',
      'price': '3.90',
    },
    {
      'image': 'assets/images/logo.png',
      'name': 'Latte',
      'details': 'with Soy Milk',
      'price': '4.50',
    },
    {
      'image': 'assets/images/logo.png',
      'name': 'Espresso',
      'details': 'double shot',
      'price': '2.80',
    },
    {
      'image': 'assets/images/logo.png',
      'name': 'Mocha',
      'details': 'with Chocolate',
      'price': '4.20',
    },
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

  void toggleNightMode(bool value) {
    setState(() {
      isNightMode = value;
    });
  }

  void onFilterTap() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: isNightMode ? Colors.grey[850] : Colors.white,
          child: Center(
            child: Text(
              'Filter options here',
              style: TextStyle(
                color: isNightMode ? Colors.white : Colors.black,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isNightMode ? Colors.black : Colors.grey[50],
      body: Stack(
        children: [
          _selectedIndex == 0
              ? buildHomeScreenContent()
              : _selectedIndex == 1
                  ? buildFavoritesScreen()
                  : buildPlaceholderScreen('Coming Soon!'),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  // Builds the main home screen content
  Widget buildHomeScreenContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isNightMode
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
                SearchBar(isNightMode: isNightMode, onFilterTap: onFilterTap),
                const SizedBox(height: 20),
              ],
            ),
          ),
          RewardsSection(points: rewardPoints, isNightMode: isNightMode),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'For You:',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: isNightMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          isNightMode
              ? buildNightModeCategoryList()
              : buildDayModeCategoryList(),
          const SizedBox(height: 20),
          buildDrinkSlider(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Build the header with username and notification icons
  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Location and Username
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location,
              style: TextStyle(
                fontSize: 14.0,
                color: isNightMode ? Colors.white70 : Colors.white70,
              ),
            ),
            Row(
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: isNightMode ? Colors.white : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: isNightMode ? Colors.white70 : Colors.white70,
                ),
              ],
            ),
          ],
        ),
        // Row for Notification Bell and Profile Icon
        Row(
          children: [
            // Notification Bell Icon with Badge
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Navigate to Notifications
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
                    );
                  },
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // Profile Icon with Dropdown
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: isNightMode ? Colors.black : Colors.blueAccent,
                ),
              ),
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                } else if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Text('Profile'),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Settings'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Build the day/night switch
  Widget buildDayNightSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wb_sunny, color: Colors.white),
        Switch(
          value: isNightMode,
          onChanged: toggleNightMode,
          activeColor: Colors.yellow,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.white70,
        ),
        const Icon(Icons.nights_stay, color: Colors.white),
      ],
    );
  }

  // Build the drink slider
  Widget buildDrinkSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: drinkList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final drink = drinkList[index];
          return DrinkCard(
            imageUrl: drink['image']!,
            name: drink['name']!,
            details: drink['details']!,
            price: drink['price']!,
            isNightMode: isNightMode,
            onAddToFavorites: () {
              setState(() {
                favoriteDrinks.add(drink);
              });
            },
          );
        },
      ),
    );
  }

  // Build the Favorites screen content
  Widget buildFavoritesScreen() {
    return favoriteDrinks.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: favoriteDrinks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final drink = favoriteDrinks[index];
                return DrinkCard(
                  imageUrl: drink['image']!,
                  name: drink['name']!,
                  details: drink['details']!,
                  price: drink['price']!,
                  isNightMode: isNightMode,
                  onAddToFavorites: null, // Disable adding to favorites
                );
              },
            ),
          )
        : Center(
            child: Text(
              'No favorite drinks yet!',
              style: TextStyle(
                fontSize: 20,
                color: isNightMode ? Colors.white : Colors.black54,
              ),
            ),
          );
  }

  // Build a placeholder screen for non-implemented tabs
  Widget buildPlaceholderScreen(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isNightMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  // Build the Bottom Navigation Bar
  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onTabSelected,
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
          label: 'Maps',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
      ],
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: isNightMode ? Colors.black87 : Colors.white,
    );
  }

  // Build Categories List for day mode
  Widget buildDayModeCategoryList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categoriesDayMode.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(categoriesDayMode[index]),
              selected: false,
              onSelected: (bool selected) {},
              backgroundColor: Colors.grey[200],
              labelStyle: const TextStyle(color: Colors.black),
            ),
          );
        },
      ),
    );
  }

  // Build Categories List for Night Mode
  Widget buildNightModeCategoryList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categoriesNightMode.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(categoriesNightMode[index]),
              selected: false,
              onSelected: (bool selected) {},
              backgroundColor: Colors.grey[800],
              labelStyle: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

// Updated SearchBar widget with more rounded corners and modern styling
class SearchBar extends StatelessWidget {
  final bool isNightMode;
  final VoidCallback onFilterTap;

  const SearchBar({
    Key? key,
    required this.isNightMode,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isNightMode ? Colors.black26 : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(50), // More rounded corners
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: isNightMode ? Colors.grey[850] : Colors.white,
          hintText: 'Search for a beverage',
          hintStyle: TextStyle(
            color: isNightMode ? Colors.white70 : Colors.grey,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isNightMode ? Colors.white70 : Colors.grey,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.tune,
              color: isNightMode ? Colors.white70 : Colors.grey,
            ),
            onPressed: onFilterTap,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50), // Increased from 30 to 50
            borderSide: BorderSide.none, // Removes the border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: isNightMode ? Colors.white70 : Colors.blueAccent,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        style: TextStyle(
          color: isNightMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

// Rewards section implementation
class RewardsSection extends StatelessWidget {
  final int points;
  final bool isNightMode;

  const RewardsSection({
    Key? key,
    required this.points,
    required this.isNightMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNightMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isNightMode ? Colors.black26 : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard,
            color: isNightMode ? Colors.amberAccent : Colors.blueAccent,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$points points available',
              style: TextStyle(
                fontSize: 18,
                color: isNightMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isNightMode ? Colors.amberAccent : Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Redeem',
              style: TextStyle(
                color: isNightMode ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// DrinkCard class implementation
class DrinkCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String details;
  final String price;
  final bool isNightMode;
  final VoidCallback? onAddToFavorites; // To handle adding to favorites

  const DrinkCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.details,
    required this.price,
    required this.isNightMode,
    this.onAddToFavorites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to drink details page
      },
      child: Container(
        decoration: BoxDecoration(
          color: isNightMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isNightMode ? Colors.black26 : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image section
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            // Details section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isNightMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: TextStyle(
                        color: isNightMode ? Colors.white70 : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Text(
                          '\$$price',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isNightMode
                                ? Colors.amberAccent
                                : Colors.blueAccent,
                          ),
                        ),
                        // Add to favorites button
                        IconButton(
                          icon: Icon(
                            onAddToFavorites != null
                                ? Icons.favorite_border
                                : Icons.favorite,
                            color: isNightMode
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                          onPressed: onAddToFavorites,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}