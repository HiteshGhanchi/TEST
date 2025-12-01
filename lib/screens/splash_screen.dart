import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_database.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 1. Show logo for 2 seconds (Simulate app loading)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Check if logged in using our MockDatabase
    if (mounted) {
      if (MockDatabase().isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Try to load a local logo asset; fallback to an icon/avatar if missing
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(
                'assets/images/cropic_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.spa, size: 60, color: Colors.green),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "CROPIC",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
