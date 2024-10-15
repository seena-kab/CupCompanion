// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:cup_companion/screens/policy_acceptance_screen.dart'; // Import the policy acceptance screen

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

// Import the SearchScreen
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final DrinkService _drinkService = DrinkService();

  String username = "Username";
  String zipCode = "00000";
  String location = "Location";
  int rewardPoints = 457;
  int _selectedIndex = 0; // Tracks selected bottom navigation tab

  // Example notification count
  int _notificationsCount = 3;

  // List to hold the fetched drinks
  List<Drink> _drinks = [];

  // Add a loading indicator
  bool _isLoading = true;

  // Add an error message
  String? _errorMessage;

  // Animation controller for playful animations
  late AnimationController _animationController;

  // Page controller for smooth transitions
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    // Ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPolicyAcceptance();
    });

    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize the page controller
    _pageController = PageController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Method to check if the user has accepted the policy
  void checkPolicyAcceptance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? policyAccepted = prefs.getBool('policyAccepted');

    if (policyAccepted != true) {
      // Show the policy acceptance screen
      bool? accepted = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PolicyAcceptanceScreen(),
        ),
      );

      if (accepted != true) {
        // If the user declines, exit the app or handle accordingly
        // For example, you can show a dialog or navigate to a different screen
        // Here, we'll simply exit the app
        if (mounted) {
          // Ensure the widget is still in the tree
          Navigator.of(context).pop();
        }
      } else {
        // Proceed with fetching user data and other initializations
        fetchUserData();
        fetchDrinks();
      }
    } else {
      // Policy already accepted; proceed as normal
      fetchUserData();
      fetchDrinks();
    }
  }

  // Method to fetch user data
  void fetchUserData() async {
    try {
      Map<String, String> userData = await _authService.fetchUserData();
      setState(() {
        username = userData['username'] ?? 'Username';
        zipCode = userData['zipCode'] ?? '00000'; // Default zip code
      });
      // After fetching user data, get the location
      print('User data fetched. Username: $username, Zip Code: $zipCode');
      getUserLocation();
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        username = 'Username';
        zipCode = '00000';
      });
      // Attempt to get user location even if fetching user data fails
      getUserLocation();
    }
  }

  // Method to get user location
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
        location =
            'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
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

  // Called when a tab is selected in the bottom navigation bar
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion

    // Initialize the list of screens
    final List<Widget> screens = [
      buildHomeScreenContent(), // Home
      const MapScreen(), // Map
      const MarketplaceScreen(), // Marketplace
      const EventScreen(), // Events
      const ForumPage(), // Forum
    ];

    return Scaffold(
      backgroundColor:
          themeNotifier.isNightMode ? Colors.black : Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Background with gradient
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
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
            // Main Content with PageView for smooth transitions
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: screens,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            themeNotifier.isNightMode ? Colors.black : Colors.white,
        selectedItemColor:
            themeNotifier.isNightMode ? Colors.amberAccent : Colors.blueAccent,
        unselectedItemColor:
            themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: appLocalizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_rounded),
            label: appLocalizations.map,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store_rounded),
            label: appLocalizations.marketplace,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_note_rounded),
            label: appLocalizations.events,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum),
            label: appLocalizations.forum,
          ),
        ],
      ),
      // Add the Search button just above the navigation bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0), // Adjust for bottom nav height
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Search Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
          child: const Icon(Icons.search), // Localized string
        ),
      ),
    );
  }

  // Builds the main home screen content with GridView for drinks
  Widget buildHomeScreenContent() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion
    return AnimationLimiter(
      child: SingleChildScrollView(
        child: Column(
          children: [
            GradientHeader(
              username: username,
              location: location,
              notificationsCount: _notificationsCount, // Pass the count
              onProfileTap: () {
                // Navigate to Profile Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              onNotificationTap: () {
                // Navigate to Notifications Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                ).then((_) {
                  // Reset notifications count after viewing
                  setState(() {
                    _notificationsCount = 0;
                  });
                });
              },
              onSettingsTap: () {
                // Handle settings via PopupMenu
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
                  items: [
                    PopupMenuItem<String>(
                      value: MenuOptions.settings,
                      child: Text(appLocalizations.settings),
                    ),
                    PopupMenuItem<String>(
                      value: MenuOptions.signOut,
                      child: Text(appLocalizations.signOut),
                    ),
                  ],
                ).then((value) {
                  if (value == MenuOptions.settings) {
                    Navigator.pushNamed(context, '/settings');
                  } else if (value == MenuOptions.signOut) {
                    _authService.signOut();
                    Navigator.pushReplacementNamed(context, '/signin');
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            RewardsSection(points: rewardPoints),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  appLocalizations.forYou, // Localized string
                  style: GoogleFonts.poppins(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: themeNotifier.isNightMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            buildCategoryList(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        )
                      : AnimationLimiter(
                          child: GridView.builder(
                            physics:
                                const NeverScrollableScrollPhysics(), // Prevent GridView from scrolling
                            shrinkWrap:
                                true, // Let GridView take only the needed space
                            itemCount: _drinks.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 per row
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 3 / 4, // Adjust as needed
                            ),
                            itemBuilder: (context, index) {
                              final drink = _drinks[index];
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                columnCount: 2,
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: buildDrinkCard(drink, index),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context)
                  .padding
                  .bottom, // Extra space to prevent overflow
            ),
          ],
        ),
      ),
    );
  }

  // Builds individual drink cards in a grid
  Widget buildDrinkCard(Drink drink, int index) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(drink.id);
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion
    return GestureDetector(
      onTap: () {
        // Navigate to DrinkDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrinkDetailScreen(
              drink: drink,
              heroTag: 'drinkImage$index', // Pass a unique hero tag
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
            // Drink Image with Hero animation
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
                        scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: themeNotifier.isNightMode
                                  ? Colors.redAccent
                                  : Colors.redAccent,
                            ),
                            onPressed: () {
                              // Handle favorite action with animation
                              favoritesProvider.toggleFavorite(drink);
                              _animationController.forward(from: 0.0);
                            },
                            tooltip: isFavorite
                                ? appLocalizations.removeFromFavorites
                                : appLocalizations
                                    .addToFavorites, // Localized tooltip
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Drink Details
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

  // Builds the category list
  Widget buildCategoryList() {
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion

    // Categories (localized)
    final List<String> categories = [
      appLocalizations.coffee,
      appLocalizations.tea,
      appLocalizations.juice,
      appLocalizations.smoothies,
      appLocalizations.cocktails,
    ];

    return CategoryList(categories: categories);
  }

  // Extracted Widget: Rewards Section
  Widget RewardsSection({required int points}) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 100, // Adjust height as needed
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
              BorderRadius.circular(20), // Rounded corners for a card-like look
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
            // Rewards Icon
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
            // Rewards Information
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
            // Redeem Button
            ElevatedButton(
              onPressed: () {
                // Handle Redeem button tap
                Navigator.pushNamed(context, '/redeem'); // Example navigation
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

  // Extracted Widget: Category List
  Widget CategoryList({required List<String> categories}) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Chip(
              backgroundColor: themeNotifier.isNightMode
                  ? Colors.white12
                  : Colors.blueAccent.withOpacity(0.1),
              label: Text(
                categories[index],
                style: GoogleFonts.poppins(
                  color: themeNotifier.isNightMode
                      ? Colors.white
                      : Colors.blueAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              avatar: const Icon(
                Icons.local_drink,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Extracted Widget: Gradient Header with Profile, Username, Location, Notifications, and Settings
class GradientHeader extends StatelessWidget {
  final String username;
  final String location;
  final int notificationsCount;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
      child: Column(
        children: [
          // First Row: Profile and Settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile Picture and Username
              Row(
                children: [
                  // Profile Picture Placeholder
                  GestureDetector(
                    onTap: onProfileTap,
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                          'assets/images/default_avatar.png'), // Ensure this asset exists
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Username
                  Text(
                    '${appLocalizations.hello}, $username', // Localized string
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Settings Icon
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                ),
                onPressed: onSettingsTap,
                tooltip: appLocalizations.settings, // Localized tooltip
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Second Row: Location and Notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location
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
              // Notification Bell Icon with Badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                    onPressed: onNotificationTap,
                    tooltip:
                        appLocalizations.notifications, // Localized tooltip
                  ),
                  if (notificationsCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$notificationsCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
