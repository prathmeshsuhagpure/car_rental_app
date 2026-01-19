/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _navigate());
  }

  Future<void> _navigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Optional delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    try {
      // This will now properly validate and clear invalid data
      final isLoggedIn = await authProvider.tryAutoLogin();

      if (!mounted) return;

      if (isLoggedIn && authProvider.user != null) {
        // Double-check that we actually have user data
        debugPrint("🟢 Auto-login successful for: ${authProvider.user?.name}");
        Navigator.pushReplacementNamed(context, '/user_home');
      } else {
        debugPrint("🔴 Auto-login failed or no user data");
        // Ensure we're cleared before going to login
        await authProvider.forceLogout();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint("🔴 Error in splash navigation: $e");
      await authProvider.forceLogout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20), // Dark green background matching DailyDrive
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // Lighter green at top
              Color(0xFF1B5E20), // Darker green at bottom
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container with modern styling
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Modern loading indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // App title with modern typography
              const Text(
                'DailyDrive',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Your Premium Car Rental Experience',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _navigate());
  }

  Future<void> _navigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Optional delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    try {
      // This will now properly validate and clear invalid data
      final isLoggedIn = await authProvider.tryAutoLogin();

      if (!mounted) return;

      if (isLoggedIn && authProvider.user != null) {
        final user = authProvider.user!;
        debugPrint("🟢 Auto-login successful for: ${user.name}");
        debugPrint("🟢 User role: ${user.role}");

        // ✅ FIXED: Navigate based on user role
        if (user.role.toLowerCase() == 'host') {
          debugPrint("🏠 Navigating to host home");
          Navigator.pushReplacementNamed(context, '/host_home');
        } else if (user.role.toLowerCase() == 'admin') {
          debugPrint("👑 Navigating to admin home");
          Navigator.pushReplacementNamed(context, '/admin_home');
        } else {
          debugPrint("👤 Navigating to user home");
          Navigator.pushReplacementNamed(context, '/user_home');
        }
      } else {
        debugPrint("🔴 Auto-login failed or no user data");
        // Ensure we're cleared before going to login
        await authProvider.forceLogout();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint("🔴 Error in splash navigation: $e");
      await authProvider.forceLogout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20), // Dark green background matching DailyDrive
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // Lighter green at top
              Color(0xFF1B5E20), // Darker green at bottom
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container with modern styling
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Modern loading indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // App title with modern typography
              const Text(
                'DailyDrive',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Your Premium Car Rental Experience',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}