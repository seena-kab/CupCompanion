// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/start_page.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/survey_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/home_screen.dart'; // Import HomeScreen
import 'screens/redeem_points_screen.dart'; // Import RedeemPointsScreen
import 'theme/theme.dart';
import 'theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'screens/favorites_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/events_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/cart_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart'; // Import UserProvider
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cart_item.dart';
import 'models/drink.dart';
// If you have a FavoriteDrink model
import 'models/user_model.dart'; // Import the AppUser model
import 'models/review.dart';
import 'theme/theme_notifier.dart'; // Import ThemeNotifier
import 'screens/forum_page.dart'; // Import ForumScreen


Future<void> main() async {
  // Ensure Firebase is initialized before running the application
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(DrinkAdapter());
  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(AppUserAdapter());
  Hive.registerAdapter(ReviewAdapter()); // Register the AppUser adapter
  // Register other adapters like ReviewAdapter, FavoriteDrinkAdapter if necessary

  // Open Hive boxes
  await Hive.openBox<CartItem>('cartBox');
  await Hive.openBox<AppUser>('userBox');
  await Hive.openBox('cart'); // Ensure you open the userBox here
  // Open other boxes like favoritesBox if necessary

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(false)),
        ChangeNotifierProvider(create: (_) => CartProvider()), // Add CartProvider here
      ],
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
        '/profile': (context) => const ProfileScreen(), // No need to pass isNightMode
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/redeem': (context) => const RedeemPointsScreen(),
      },
    );
  }
}