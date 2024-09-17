// main.dart

import 'package:cup_companion/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/start_page.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/survey_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart'; // Import HomeScreen
// Import RedeemPointsScreen
import 'theme/theme.dart';

Future<void> main() async {
  // Ensure Firebase is initialized before running the application
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(false), // Initial theme: Day Mode
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeNotifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Cup Companion',
      theme: themeNotifier.isNightMode ? ThemeData.dark() : AppTheme.theme, // Apply the custom or dark theme
      initialRoute: '/', // Initial route set to Start page
      routes: {
        '/': (context) => const StartPage(),
        '/signup': (context) => const SignUpScreen(),
        '/signin': (context) => const SignInScreen(),
        '/survey': (context) => const SurveyScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(), // Add HomeScreen route
      },
    );
  }
}
