import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/start_page.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/survey_intro_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'theme/theme.dart';
import 'screens/coffee_selection_screen.dart'; // Import CoffeeSelectionScreen


Future<void> main() async{
  //Ensure Firebase is intitialized before running the application
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
      theme: AppTheme.theme, //Apply the custom theme
      // initialRoute: '/',   //Initial route set to Sign Up screen
      initialRoute: skipAuth ? '/coffee_selection' : '/', // Skip auth and go to survey screen
      routes: {
        '/': (context) => const StartPage(),
        '/signup': (context) => const SignUpScreen(),
        '/signin': (context) => const SignInScreen(),
        '/survey': (context) => const SurveyIntroScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/coffee_selection': (context) => const CoffeeSelectionScreen()
      },
    );
  } 
}