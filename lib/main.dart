import 'package:car_rent_app/providers/booking_provider.dart';
import 'package:car_rent_app/providers/car_provider.dart';
import 'package:car_rent_app/screens/auth/login_screen.dart';
import 'package:car_rent_app/screens/home/host_home_screen.dart';
import 'package:car_rent_app/services/notification_service.dart';
import 'package:car_rent_app/utils/date_time_selection.dart';
import 'package:car_rent_app/widgets/bottom_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📩 Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env loaded successfully");
  } catch (e) {
    print("⚠️ Failed to load .env file: $e");
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider<DateTimeSelectionService>(
          create: (_) => DateTimeSelectionService(),
        ),
        // Add other providers here if needed
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
        },
        home: const SplashScreen(),
      ),
    );
  }
}
