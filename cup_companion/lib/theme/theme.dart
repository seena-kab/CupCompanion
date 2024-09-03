import 'package:flutter/material.dart';

class AppTheme {
  //Primary color scheme that matches your screenshots
  static const Color primaryColor = Color(0xFFE2B57D);
  static const Color backgroundColor = Color(0xFFFDF3E7);
  static const Color textColor = Color(0xFF000000);
  static const Color buttonTextColor = Color(0xFFFFFFFF);
  static const Color buttonBackgroundColor = Color(0xFF000000);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: textColor,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: textColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: textColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryColor),
        ),
        hintStyle: const TextStyle(color: Colors.black54),
        labelStyle: const TextStyle(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: const TextStyle(
            color: buttonTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor:  backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
    );
  }
}