
import 'package:flutter/material.dart';
import 'package:myapp/router.dart';

final Color _primaryGreen = Colors.green.shade700;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CropClaimApp());
}

class CropClaimApp extends StatelessWidget {
  const CropClaimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Crop Claim App',
      theme: ThemeData(
        // Use a standard green primary color theme
        primarySwatch: Colors.green,
        primaryColor: _primaryGreen,
        scaffoldBackgroundColor: Colors.grey.shade100,
        // Define a consistent look for input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
