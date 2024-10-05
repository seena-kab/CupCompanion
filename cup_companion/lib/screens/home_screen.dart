// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cup_companion/services/auth_services.dart';
import 'package:cup_companion/screens/chat_screen.dart';
import 'package:cup_companion/screens/profile_screen.dart';
import 'package:cup_companion/screens/map_screen.dart';
import 'package:cup_companion/screens/marketplace_screen.dart';
import 'package:cup_companion/screens/notifications_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_notifier.dart';
import 'events_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  String username = "Username";
  String zipCode = "00000";
  String location = "Location";
  int rewardPoints = 457;
  int _selectedIndex = 0; // Tracks selected bottom navigation tab

  // Controls visibility of the bottom navigation bar
  bool _isNavBarVisible = true;

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

  // Mock data for drink cards
  final List<Map<String, String>> drinkList = [
    {
      'image': 'assets/images/cappuccino.png',
      'name': 'Cappuccino',
      'details': 'With Oat Milk',
      'price': '3.90',
    },
    {
      'image': 'assets/images/espresso.jpg',
      'name': 'Latte',
      'details': 'With Soy Milk',
      'price': '4.50',
    },
    {
      'image': 'assets/images/espresso.jpg',
      'name': 'Espresso',
      'details': 'Double Shot',
      'price': '2.80',
    },
    {
      'image': 'assets/images/espresso.jpg',
      'name': 'Mocha',
      'details': 'With Chocolate',
      'price': '4.20',
    },
  ];

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
        location = 'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Lng: ${position.longitude.toStringAsFixed(6)}';
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

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildBottomNavigationBar() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return BottomNavigationBar(
      backgroundColor:
          themeNotifier.isNightMode ? Colors.black : Colors.white,
      selectedItemColor: themeNotifier.isNightMode
          ? Colors.amberAccent
          : Colors.blueAccent,
      unselectedItemColor:
          themeNotifier.isNightMode ? Colors.white70 : Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onTabSelected,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10.0,
      unselectedFontSize: 10.0,
      iconSize: 24.0,
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

    final List<Widget> screens = [
      buildHomeScreenContent(),
      const MapScreen(),
      const MarketplaceScreen(),
      const ChatScreen(),
      const EventScreen(),
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
              _selectedIndex < screens.length
                  ? screens[_selectedIndex]
                  : buildPlaceholderScreen('Coming Soon!'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: _isNavBarVisible,
        child: SafeArea(
          child: buildBottomNavigationBar(),
        ),
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
                SearchBar(onFilterTap: onFilterTap), // Integrated SearchBar
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
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: drinkList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 4,
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

  Widget buildHeader() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
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
                backgroundImage:
                    AssetImage('assets/images/default_avatar.png'),
              ),
            ),
            const SizedBox(width: 10),
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
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
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

  Widget buildDrinkCard(Map<String, String> drink) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return GestureDetector(
      onTap: () {
        // Handle drink card tap
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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Image.asset(
                      drink['image']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite_border,
                            color: themeNotifier.isNightMode
                                ? Colors.black
                                : Colors.redAccent,
                          ),
                          onPressed: () {
                            // Handle favorite action
                          },
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
                    drink['name']!,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.isNightMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    drink['details']!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: themeNotifier.isNightMode
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${drink['price']}',
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

class SearchBar extends StatelessWidget {
  final VoidCallback onFilterTap;

  const SearchBar({
    super.key,
    required this.onFilterTap,
  });

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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchScreen()),
          );
        },
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
            borderSide: BorderSide.none,
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

class RewardsSection extends StatelessWidget {
  final int points;

  const RewardsSection({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
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
                    'Rewards Points',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: themeNotifier.isNightMode
                          ? Colors.white70
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    '$points Points',
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
              child: const Text(
                'Redeem',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
