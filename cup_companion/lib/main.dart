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
import 'providers/locale_provider.dart'; // Import LocaleProvider
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'providers/favorites_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cart_item.dart';
import 'models/drink.dart';
import 'models/user_model.dart'; // Import the AppUser model
import 'models/review.dart';

// Import localization packages
import 'package:flutter_localizations/flutter_localizations.dart';
// Import the generated localization file
import 'package:cup_companion/l10n/app_localizations.dart'; // Adjust the import path if necessary

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
  Hive.registerAdapter(ReviewAdapter()); // Register the Review adapter
  // Register other adapters like FavoriteDrinkAdapter if necessary

  // Open Hive boxes
  await Hive.openBox<CartItem>('cartBox');
  await Hive.openBox<AppUser>('userBox');
  // await Hive.openBox('cart'); // Remove if 'cartBox' is sufficient
  await Hive.openBox<Drink>('favoritesBox');
  // Open other boxes like 'favoritesBox' if necessary

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(false)),
        ChangeNotifierProvider(create: (_) => CartProvider()), // Include CartProvider
        ChangeNotifierProvider(create: (_) => UserProvider()), // Include UserProvider
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()), // Include LocaleProvider
        // Add other providers if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

    // Flag to skip authentication for development purposes
  final bool skipAuth = true;  // Set to false when auth is ready

  @override
  Widget build(BuildContext context) {
    // Access the ThemeNotifier
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    // Access the LocaleProvider
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Cup Companion',
      theme: themeNotifier.isNightMode ? ThemeData.dark() : AppTheme.theme,
      locale: localeProvider.locale, // Set the locale from LocaleProvider
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('ja'), // Japanese
        // Add other supported locales here
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate, // Generated localization delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/', // Initial route set to Start page
      routes: {
      '/': (context) => const StartPage(),
      '/signup': (context) => const SignUpScreen(),
      '/signin': (context) => const SignInScreen(),
      '/survey': (context) => const SurveyScreen(),
      '/forgot_password': (context) => const ForgotPasswordScreen(),
      '/home': (context) => const HomeScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/notifications': (context) => const NotificationsScreen(),
      '/redeem': (context) => const RedeemPointsScreen(),
    },
    );
  }
}