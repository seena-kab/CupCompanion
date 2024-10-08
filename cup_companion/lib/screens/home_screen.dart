// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

// Import other necessary packages and services
import 'package:cup_companion/services/auth_services.dart';
import 'package:cup_companion/services/drink_service.dart';
import 'package:cup_companion/models/drink.dart';
import 'package:cup_companion/screens/profile_screen.dart';
import 'package:cup_companion/screens/map_screen.dart';
import 'package:cup_companion/screens/marketplace_screen.dart';
import 'package:cup_companion/screens/notifications_screen.dart';
import 'package:cup_companion/screens/forum_page.dart';
import 'package:cup_companion/screens/events_screen.dart';
import 'package:cup_companion/screens/drink_detail_screen.dart';
import 'package:cup_companion/providers/favorites_provider.dart';
import 'package:cup_companion/theme/theme_notifier.dart';
import 'package:cup_companion/constants/menu_options.dart';
import 'package:cup_companion/l10n/app_localizations.dart';

// Additional imports for animations
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final DrinkService _drinkService = DrinkService();

  String username = "Username";
  String zipCode = "00000";
  String location = "Location";
  int rewardPoints = 457;
  int _selectedIndex = 0; // Tracks selected bottom navigation tab

  bool _isNavBarVisible = true;

  // Example notification count
  int _notificationsCount = 3;

  // Categories for day mode
  final List<String> categoriesDayMode = [
    'Coffee',
    'Tea',
    'Juice',
    'Smoothies',
    'Alcoholic Drinks',
  ];

  // Categories for night mode
  final List<String> categoriesNightMode = [
    'Beer',
    'Wine',
    'Whiskey',
    'Cocktails',
    'Non-Alcoholic',
  ];

  // List to hold the fetched drinks
  List<Drink> _drinks = [];

  // Add a loading indicator
  bool _isLoading = true;

  // Add an error message
  String? _errorMessage;

  // Animation controller for playful animations
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchDrinks(); // Fetch drinks when the widget initializes

    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to fetch user data
  void fetchUserData() async {
    try {
      Map<String, String> userData = await _authService.fetchUserData();
      setState(() {
        username = userData['username'] ?? 'Username';
        zipCode = userData['zipCode'] ?? '00000'; // Default zip code
      });
      getUserLocation();
    } catch (e) {
      setState(() {
        username = 'Username';
        zipCode = '00000';
      });
      getUserLocation();
    }
  }

  // Method to get user location
  void getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        location = 'Zip Code: $zipCode';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          location = 'Zip Code: $zipCode';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        location = 'Zip Code: $zipCode';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        location =
            'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        location = 'Zip Code: $zipCode';
      });
    }
  }

  void onFilterTap() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor:
          themeNotifier.isNightMode ? Colors.grey[850] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilterOptions(), // Extracted widget for filter options
        );
      },
    );
  }

  // Method to fetch drinks from Firestore
  void fetchDrinks() async {
    try {
      List<Drink> drinks = await _drinkService.fetchDrinks();
      setState(() {
        _drinks = drinks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching drinks: $e');
      setState(() {
        _errorMessage = 'Failed to load drinks.';
        _isLoading = false;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Builds the bottom navigation bar with 5 items
  Widget buildBottomNavigationBar() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion

    return CustomBottomNavBar(
      currentIndex: _selectedIndex,
      onTap: _onTabSelected,
      type: BottomNavigationBarType.fixed, // To show all items
      selectedFontSize: 10.0, // Reduced font size
      unselectedFontSize: 10.0, // Reduced font size
      iconSize: 24.0, // Adjusted icon size
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_rounded),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store_rounded),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_rounded),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note_rounded),
          label: 'Events',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    // final localeProvider = Provider.of<LocaleProvider>(context); // Unused
    // Removed the unused localeProvider to fix the error
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion

    final List<Widget> screens = [
      buildHomeScreenContent(), // Home
      const MapScreen(), // Map
      const MarketplaceScreen(), // Marketplace
      const ChatScreen(), // Chat
      const EventScreen(), // Events
    ];

    return Scaffold(
      backgroundColor:
          themeNotifier.isNightMode ? Colors.black : Colors.grey[50],
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              if (scrollNotification.scrollDelta! > 0) {
                if (_isNavBarVisible) {
                  setState(() {
                    _isNavBarVisible = false;
                  });
                }
              } else if (scrollNotification.scrollDelta! < 0) {
                if (!_isNavBarVisible) {
                  setState(() {
                    _isNavBarVisible = true;
                  });
                }
              }
            }
            return false;
          },
          child: Stack(
            children: [
              // Background with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: themeNotifier.isNightMode
                        ? [Colors.black87, Colors.black54]
                        : [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Main Content
              _selectedIndex < screens.length
                  ? screens[_selectedIndex]
                  : buildPlaceholderScreen('Coming Soon!'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _isNavBarVisible
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: buildBottomNavigationBar(),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget buildHomeScreenContent() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
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
                SearchBar(onFilterTap: onFilterTap),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          RewardsSection(points: rewardPoints),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'For You',
                style: GoogleFonts.poppins(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Prevent GridView from scrolling
              shrinkWrap: true, // Let GridView take only the needed space
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
          const SizedBox(height: 20),
          SizedBox(
              height: MediaQuery.of(context)
                  .padding
                  .bottom), // Extra space to prevent overflow
        ],
      ),
    );
  }

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

  // Builds the header with profile picture, username, location, and notification bell
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(
                    'assets/images/default_avatar.png'), // Ensure this asset exists
              ),
            ),
            const SizedBox(width: 10),
            // Username and Location
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $username',
                  style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
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
        // Notification Bell and Settings Icon
        Row(
          children: [
            // Notification Bell Icon
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                // Navigate to Notifications Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
              tooltip: 'Notifications',
            ),
            // Settings Icon with Drop-down Menu
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
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
          return buildCategoryChip(categoriesDayMode[index], index);
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
          return buildCategoryChip(categoriesNightMode[index], index);
        },
      ),
    );
  }

  // Builds individual category chips
  Widget buildCategoryChip(String category, int index) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    Color chipColor = Colors
        .primaries[index % Colors.primaries.length]; // Cycle through colors
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Chip(
        backgroundColor: chipColor.withOpacity(0.2),
        label: Text(
          category,
          style: GoogleFonts.poppins(
            color: chipColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        avatar: Icon(
          Icons.local_drink,
          color: chipColor,
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
      },
      child: Container(
        decoration: BoxDecoration(
          color: themeNotifier.isNightMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeNotifier.isNightMode
                  ? Colors.black45
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                child: Stack(
                  children: [
                    Hero(
                      tag: 'drinkImage$index',
                      child: Image.network(
                        drink.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, size: 50),
                          );
                        },
                      ),
                    ),
                    // Favorite Icon with Animation
                    Positioned(
                      right: 8,
                      top: 8,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1.0)
                            .animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOutBack,
                        )),
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: themeNotifier.isNightMode
                                  ? Colors.black
                                  : Colors.redAccent,
                            ),
                            onPressed: () {
                              // Handle favorite action with animation
                              favoritesProvider.toggleFavorite(drink);
                              _animationController.forward(from: 0.0);
                            },
                            tooltip: isFavorite
                                ? appLocalizations.removeFromFavorites
                                : appLocalizations.addToFavorites, // Localized tooltip
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    drink.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.isNightMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  if (drink.category.isNotEmpty)
                    Text(
                      drink.category,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: themeNotifier.isNightMode
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${drink.price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
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

  const GradientHeader({
    super.key,
    required this.username,
    required this.location,
    required this.notificationsCount,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor:
              themeNotifier.isNightMode ? Colors.grey[850] : Colors.white,
          hintText: 'Search for a beverage',
          hintStyle: GoogleFonts.poppins(
            color: themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.tune_rounded,
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
              color: themeNotifier.isNightMode
                  ? Colors.white70
                  : Colors.blueAccent,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        style: GoogleFonts.poppins(
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
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeNotifier.isNightMode
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.white, Colors.grey[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
              BorderRadius.circular(20),
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
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: themeNotifier.isNightMode
                  ? Colors.amberAccent.withOpacity(0.2)
                  : Colors.blueAccent.withOpacity(0.2),
              child: Icon(
                Icons.stars_rounded,
                color: themeNotifier.isNightMode
                    ? Colors.amberAccent
                    : Colors.blueAccent,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLocalizations.rewardsPoints, // Localized string
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: themeNotifier.isNightMode
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    '$points ${appLocalizations.points}', // Localized string
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.isNightMode
                          ? Colors.amberAccent
                          : Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/redeem');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeNotifier.isNightMode
                    ? Colors.amberAccent
                    : Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(
                appLocalizations.redeem, // Localized string
              ),
            ),
          ],
        ),
      ),
    );
  }
}