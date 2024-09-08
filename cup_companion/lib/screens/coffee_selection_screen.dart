import 'package:flutter/material.dart';

class CoffeeSelectionScreen extends StatelessWidget {
  const CoffeeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Welcome!',
          style: TextStyle(color: Colors.grey, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add cart navigation logic here
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () {
              // Add profile navigation logic here
            },
            icon: const Icon(Icons.person_outline),
            color: Colors.black,
          ),
        ],
        leading: const SizedBox.shrink(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "(User)", // Replace with dynamic username
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Select your coffee",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: const [
                  CoffeeCard(imagePath: 'assets/images/americano.png', name: 'Americano'),
                  CoffeeCard(imagePath: 'assets/images/cappuccino.png', name: 'Cappuccino'),
                  CoffeeCard(imagePath: 'assets/images/latte.png', name: 'Latte'),
                  CoffeeCard(imagePath: 'assets/iamges/americano.png', name: 'Flat White'),
                  CoffeeCard(imagePath: 'assets/images/raf.png', name: 'Raf'),
                  CoffeeCard(imagePath: 'assets/images/espresso.png', name: 'Espresso'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory_outlined),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
        onTap: (index) {
          // Handle navigation here
        },
      ),
    );
  }
}

class CoffeeCard extends StatelessWidget {
  final String imagePath;
  final String name;

  const CoffeeCard({
    Key? key,
    required this.imagePath,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 80),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
