import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class RedeemPointsScreen extends StatefulWidget {
  const RedeemPointsScreen({super.key});

  @override
  _RedeemPointsScreenState createState() => _RedeemPointsScreenState();
}

class _RedeemPointsScreenState extends State<RedeemPointsScreen>
    with TickerProviderStateMixin {
  int userPoints = 1000; // User's available points
  late AnimationController _confettiController;
  late AnimationController _buttonController;

  // Mock list of redeemable items
  final List<RedeemableItem> redeemableItems = [
    RedeemableItem(
        name: 'Coffee Mug',
        points: 200,
        image: 'assets/images/mug.jpg',
        color: Colors.orangeAccent),
    RedeemableItem(
        name: 'T-Shirt',
        points: 500,
        image: 'assets/images/tshirt.jpg',
        color: Colors.lightBlueAccent),
    RedeemableItem(
        name: 'Backpack',
        points: 800,
        image: 'assets/images/backpack.jpg',
        color: Colors.greenAccent),
    RedeemableItem(
        name: 'Headphones',
        points: 1200,
        image: 'assets/images/headphones.jpg',
        color: Colors.purpleAccent),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the animation controllers
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _redeemItem(RedeemableItem item) {
    setState(() {
      userPoints -= item.points;
    });
    // Play confetti animation
    _confettiController.forward(from: 0.0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Congratulations! You redeemed a ${item.name}!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAnimatedButton(RedeemableItem item, bool isAffordable) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: _buttonController,
          curve: Curves.easeInOut,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isAffordable ? item.color : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 6,
          shadowColor: item.color.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        onPressed: isAffordable
            ? () async {
                await _buttonController.forward();
                _buttonController.reverse();
                _redeemItem(item);
              }
            : null,
        child: const Text(
          'Redeem',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isNightMode = themeNotifier.isNightMode;

    return Scaffold(
      backgroundColor: isNightMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: isNightMode ? Colors.grey[900] : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isNightMode ? Colors.white : Colors.black,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isNightMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: isNightMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Toggle the theme by passing the opposite of the current theme
              themeNotifier.toggleTheme(!isNightMode);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // User Points Display with Animated Counter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isNightMode ? Colors.grey[900] : Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Points',
                      style: TextStyle(
                        color: isNightMode ? Colors.white70 : Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                            child: child, scale: animation);
                      },
                      child: Text(
                        '$userPoints',
                        key: ValueKey<int>(userPoints),
                        style: TextStyle(
                          color: isNightMode ? Colors.white : Colors.black87,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (userPoints % 200) / 200,
                      backgroundColor:
                          isNightMode ? Colors.grey[800] : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isNightMode ? Colors.tealAccent : Colors.blueAccent),
                    ),
                  ],
                ),
              ),
              // Redeemable Items Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: redeemableItems.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final item = redeemableItems[index];
                    final isAffordable = userPoints >= item.points;

                    return GestureDetector(
                      onTap: isAffordable ? () => _redeemItem(item) : null,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isAffordable ? 1.0 : 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isNightMode
                                ? Colors.grey[850]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: isNightMode
                                    ? Colors.black54
                                    : Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Item Image with Hero Animation
                              Expanded(
                                child: Hero(
                                  tag: 'itemImage${item.name}',
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image.asset(
                                      item.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // Item Name
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    color: isNightMode
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Item Points
                              Text(
                                '${item.points} Points',
                                style: TextStyle(
                                  color: isNightMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Redeem Button with Animation
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildAnimatedButton(
                                    item, isAffordable),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Confetti Animation when item is redeemed
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(_confettiController.value),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model class for redeemable items
class RedeemableItem {
  final String name;
  final int points;
  final String image;
  final Color color;

  RedeemableItem({
    required this.name,
    required this.points,
    required this.image,
    required this.color,
  });
}

// Custom painter for confetti animation
class ConfettiPainter extends CustomPainter {
  final double progress;
  final Random random = Random();

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw confetti based on progress
    final confettiCount = (progress * 150).toInt();

    for (int i = 0; i < confettiCount; i++) {
      final paint = Paint()
        ..color = Color.fromARGB(
          255,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );

      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * progress;
      final rotation = random.nextDouble() * 360;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      final sizeFactor = 4 + random.nextDouble() * 6;
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: sizeFactor, height: sizeFactor / 4),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}