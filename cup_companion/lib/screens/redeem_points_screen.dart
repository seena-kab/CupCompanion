// lib/screens/redeem_points_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class RedeemPointsScreen extends StatelessWidget {
  const RedeemPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Points'),
        backgroundColor:
            themeNotifier.isNightMode ? Colors.grey[900] : Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'Redeem your points here!',
          style: TextStyle(
            color: themeNotifier.isNightMode ? Colors.white : Colors.black87,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}