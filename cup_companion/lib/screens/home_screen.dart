import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isNightMode = false; // Controls day/night mode
  String username = "Username";
  String location = "Location";
  int rewardPoints = 457;
  int _selectedIndex = 0; // Tracks selected bottom navigation tab
  bool _isNavBarVisible = true;

  // Stores the favorite drinks
  List<Map<String, String>> favoriteDrinks = [];

  // Categories for day mode
  final List<String> categoriesDayMode = [
    'Coffee',
    'Tea',
    'Juice',
    'Smoothies',
    'Alcoholic Selections', // Add Alcoholic Selections at the end for day mode
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
      'image': 'assets/images/logo.png', // Placeholder image
      'name': 'Cappuccino',
      'details': 'with Oat Milk',
      'price': '3.90',
    },
    {
      'image': 'assets/images/logo.png', // Placeholder image
      'name': 'Latte',
      'details': 'with Soy Milk',
      'price': '4.50',
    },
    {
      'image': 'assets/images/logo.png', // Placeholder image
      'name': 'Espresso',
      'details': 'double shot',
      'price': '2.80',
    },
    {
      'image': 'assets/images/logo.png', // Placeholder image
      'name': 'Mocha',
      'details': 'with Chocolate',
      'price': '4.20',
    },
  ];

  // Simulating fetching username and location from the database
  void fetchUserData() {
    setState(() {
      username = "John Doe";
      location = "New York, NY";
    });
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
          color: Colors.grey[800],
          child: const Center(
            child: Text(
              'Filter options here',
              style: TextStyle(color: Colors.white),
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            if (scrollNotification.scrollDelta! > 0) {
              // User scrolled down, hide bottom navigation bar
              if (_isNavBarVisible) {
                setState(() {
                  _isNavBarVisible = false;
                });
              }
            } else if (scrollNotification.scrollDelta! < 0) {
              // User scrolled up, show bottom navigation bar
              if (!_isNavBarVisible) {
                setState(() {
                  _isNavBarVisible = true;
                });
              }
            }
          }
          return true;
        },
        child: Stack(
          children: [
            // Background with two colors: black on top and white below
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: const Color.fromARGB(255, 130,200,211),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            _selectedIndex == 0
                ? buildHomeScreenContent()
                : _selectedIndex == 1
                    ? buildFavoritesScreen()
                    : buildPlaceholderScreen('Coming Soon!'),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isNavBarVisible ? kBottomNavigationBarHeight : 0.0,
        child: Wrap(
          children: [
            buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // Builds the main home screen content
  Widget buildHomeScreenContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location and Username
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 12.0,
                            color:
                                isNightMode ? Colors.white70 : Colors.white70,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 18.0,
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
                    Image.asset(
                      'assets/images/logo.png',
                      height: 50,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Day',
                      style: TextStyle(
                          color: isNightMode ? Colors.white70 : Colors.white70),
                    ),
                    Switch(
                      value: isNightMode,
                      onChanged: toggleNightMode,
                      activeColor: Colors.yellow,
                      inactiveThumbColor: Colors.black,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    Text(
                      'Night',
                      style: TextStyle(
                          color: isNightMode ? Colors.white70 : Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SearchBar(isNightMode: isNightMode, onFilterTap: onFilterTap),
                const SizedBox(height: 20),
              ],
            ),
          ),
          RewardsSection(points: rewardPoints),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'For You:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isNightMode ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          isNightMode
              ? buildNightModeCategoryList()
              : buildDayModeCategoryList(),
          const SizedBox(height: 10),
          // Drink Cards List with Vertical Scrolling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Ensures proper scrolling
              itemCount: drinkList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two slides per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9, // Controls the height-to-width ratio
              ),
              itemBuilder: (context, index) {
                final drink = drinkList[index];
                return DrinkCard(
                  imageUrl: drink['image']!,
                  name: drink['name']!,
                  details: drink['details']!,
                  price: drink['price']!,
                  onAddToFavorites: () {
                    setState(() {
                      favoriteDrinks.add(drink); // Add to favorites
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build the Favorites screen content
  Widget buildFavoritesScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: favoriteDrinks.isNotEmpty
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: favoriteDrinks.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final drink = favoriteDrinks[index];
                  return DrinkCard(
                    imageUrl: drink['image']!,
                    name: drink['name']!,
                    details: drink['details']!,
                    price: drink['price']!,
                    onAddToFavorites: null, // Disable adding to favorites
                  );
                },
              )
            : const Center(
                child: Text(
                  'No favorite drinks yet!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                    ),
                ),
              ),
      ),
    );
  }

  // Build a placeholder screen for non-implemented tabs
  Widget buildPlaceholderScreen(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
      ],
      selectedItemColor: Colors.amberAccent,
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.white,
    );
  }

  // Build Categories List for day mode
  Widget buildDayModeCategoryList() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoriesDayMode.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: Text(categoriesDayMode[index]),
              backgroundColor: Colors.amberAccent,
            ),
          );
        },
      ),
    );
  }

  // Build Categories List for Night Mode
  Widget buildNightModeCategoryList() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoriesNightMode.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: Text(
                categoriesNightMode[index],
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.amberAccent,
            ),
          );
        },
      ),
    );
  }
}

/// Search Bar widget
class SearchBar extends StatelessWidget {
  final bool isNightMode;
  final VoidCallback onFilterTap;

  const SearchBar({
    Key? key, // Added key parameter
    required this.isNightMode,
    required this.onFilterTap,
  }) : super(key: key); // Passing key to the super constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isNightMode ? Colors.grey[900] : Colors.grey[300], // Background for the entire search bar
        borderRadius: BorderRadius.circular(30), // Rounded corners for the whole container
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isNightMode ? Colors.white70 : Colors.black45, // Search icon color
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a beverage',
                hintStyle: TextStyle(
                  color: isNightMode ? Colors.white70 : Colors.black45, // Hint text color
                ),
                border: OutlineInputBorder( // Here we explicitly control the border
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isNightMode ? Colors.grey[900]! : Colors.grey[300]!, // Same as the background color
                    width: 0.0, // Set border width to 0
                  ),
                ),
                focusedBorder: OutlineInputBorder( // For when the TextField is focused
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isNightMode ? Colors.grey[900]! : Colors.grey[300]!, // Same as the background color
                    width: 0.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder( // For when the TextField is not focused
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: isNightMode ? Colors.grey[900]! : Colors.grey[300]!, // Same as the background color
                    width: 0.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10), // Adjust height of the TextField
              ),
              style: TextStyle(
                color: isNightMode ? Colors.white : Colors.black, // Text color
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amberAccent, // Filter button background
                borderRadius: BorderRadius.circular(15), // Rounded corners for filter button
              ),
              child: const Icon(
                Icons.tune, // Filter button icon
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Rewards section implementation
class RewardsSection extends StatelessWidget {
  final int points;

  const RewardsSection({
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Colors.amberAccent, // Change this to modify the background color of the text
            child: const Text(
            'Rewards',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Text(
                  '$points',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'points available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
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
  final VoidCallback? onAddToFavorites; // To handle adding to favorites

  const DrinkCard({
    required this.imageUrl,
    required this.name,
    required this.details,
    required this.price,
    this.onAddToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ensuring that the image takes up the upper half
          Expanded(
            flex: 5, // Half of the available space
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                imageUrl, // Replace this with local asset path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  details,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(), // To push price and plus icon to the bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price at the bottom left
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Plus icon at the bottom right
                Container(
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onAddToFavorites,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8), // Add spacing at the bottom
        ],
      ),
    );
  }
}