import 'package:car_rent_app/providers/booking_provider.dart';
import 'package:car_rent_app/providers/car_provider.dart';
import 'package:car_rent_app/providers/favourites_provider.dart';
import 'package:car_rent_app/providers/host_provider.dart';
import 'package:car_rent_app/providers/review_provider.dart';
import 'package:car_rent_app/screens/host_screens/host_home_screen.dart';
import 'package:car_rent_app/screens/splash_screen.dart';
import 'package:car_rent_app/screens/user_screens/auth/email_signup_screen.dart';
import 'package:car_rent_app/screens/user_screens/auth/login_screen.dart';
import 'package:car_rent_app/services/api_service.dart';
import 'package:car_rent_app/services/notification_service.dart';
import 'package:car_rent_app/providers/date_time_selection_provider.dart';
import 'package:car_rent_app/widgets/bottom_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Base services
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        // Independent providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => HostDashboardProvider()),
        ChangeNotifierProvider<DateTimeSelectionProvider>(
          create: (_) => DateTimeSelectionProvider(),
        ),
        // 👇 DEPENDENT provider (FIXED)
        ChangeNotifierProxyProvider<ApiService, ReviewProvider>(
          create: (_) => ReviewProvider(null),
          update: (_, apiService, previous) => ReviewProvider(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Car Rental App',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        navigatorKey: navigatorKey,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/user_home': (context) => const UserHomeScreen(),
          '/host_home': (context) => const HostHomeScreen(),
          '/loginWithEmail': (context) => const EmailSignupScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}
