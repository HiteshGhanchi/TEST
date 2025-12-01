import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final Color _primaryGreen = Colors.lightGreen.shade500;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay and bypass backend call for frontend testing
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Mock session ID for frontend flow
      const String mockSessionId = "mock_session_id_12345";
      context.go('/verify-otp', extra: {
        'sessionId': mockSessionId,
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      });
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade50,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.brown.shade200,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person_add,
                                size: 40,
                                color: _primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Join Our Farming Community',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create an account to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                    Text(
                      'Full Name',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your full name' : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Email Address',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., yourname@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty || !value.contains('@')
                          ? 'Please enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Phone Number',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your phone number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your phone number' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _requestOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Already a member? Log In',
                          style: TextStyle(
                            color: _primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
