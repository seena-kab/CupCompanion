import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/start_page.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/survey_intro_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'theme/theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cup Companion',
      theme: AppTheme.theme, //Apply the custom theme
      initialRoute: '/',   //Initial route set to Sign Up screen
      routes: {
        '/': (context) => const StartPage(),
        '/signup': (context) => const SignUpScreen(),
        '/signin': (context) => const SignInScreen(),
        '/survey': (context) => const SurveyIntroScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
    );
  } 
}

