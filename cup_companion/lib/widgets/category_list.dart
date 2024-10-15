// lib/widgets/category_list.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cup_companion/theme/theme_notifier.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatelessWidget {
  final List<String> categories;

  const CategoryList({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
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