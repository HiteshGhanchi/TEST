import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_database.dart'; // Import MockDB

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isOtpSent = false; // Toggle between Phone Input and OTP Input
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    if (!_isOtpSent) {
      // Step 1: Simulate Sending OTP
      await Future.delayed(const Duration(seconds: 1)); // Fake network call
      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP Sent: 1234")),
      );
    } else {
      // Step 2: Verify OTP
      bool success = await MockDatabase().login(
        _phoneController.text, 
        _otpController.text
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP (Try 1234)")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Welcome to Cropic",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 40),
            
            // Toggle Inputs based on state
            if (!_isOtpSent)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              )
            else
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    _isOtpSent ? "Verify & Login" : "Get OTP",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
            ),
            
            if (_isOtpSent)
              TextButton(
                onPressed: () => setState(() => _isOtpSent = false),
                child: const Text("Change Phone Number"),
              )
          ],
        ),
      ),
    );
  }
}