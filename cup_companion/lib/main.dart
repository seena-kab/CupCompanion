import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/start_page.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/survey_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart'; // Import HomeScreen
import 'theme/theme.dart';
import 'screens/coffee_selection_screen.dart'; // Import CoffeeSelectionScreen


Future<void> main() async {
  // Ensure Firebase is initialized before running the application
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

    // Flag to skip authentication for development purposes
  final bool skipAuth = true;  // Set to false when auth is ready

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cup Companion',
      theme: AppTheme.theme, // Apply the custom theme
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