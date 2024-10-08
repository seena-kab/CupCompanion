// lib/widgets/filter_options.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cup_companion/l10n/app_localizations.dart';

class FilterOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!; // Null assertion
    // Implement your filter options here
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          appLocalizations.filter,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        // Add your filter options widgets here
        // For example, category selection, price range, etc.
        // ...
      ],
    );
  }
}