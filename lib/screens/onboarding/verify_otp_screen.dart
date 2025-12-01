import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final Color _primaryGreen = Colors.lightGreen.shade500;

class VerifyOTPScreen extends StatefulWidget {
  final String sessionId;
  final String fullName;
  final String email;
  final String phone;

  const VerifyOTPScreen({
    super.key,
    required this.sessionId,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay and bypass backend call for frontend testing
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Mock access token for frontend flow
      const String mockAccessToken = "mock_access_token_67890";
      context.go('/set-password', extra: {'accessToken': mockAccessToken});
    }


    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the OTP sent to ${widget.phone}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter the OTP' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verify', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
