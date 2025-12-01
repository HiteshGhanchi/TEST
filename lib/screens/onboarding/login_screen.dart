import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/api/api_client.dart';

final Color _primaryGreen = Colors.green.shade700;
final Color _darkGreen = Colors.green.shade900;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;

  // Background effect mimicking the image (blurred field)
  final Widget background = Container(
    decoration: BoxDecoration(
        color: Colors.grey.shade100,
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1542282332-1b112310350d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          ), // Placeholder for background image
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withAlpha(77), BlendMode.dstATop),
        )),
  );

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.login(
        _phoneController.text,
        _passwordController.text,
      );
      final accessToken = response['accessToken'];
      if (mounted) {
        context.go('/add-farm', extra: {'accessToken': accessToken});
      }
    } catch (e) {
      _showErrorSnackbar('Invalid credentials. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          background,
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // App Name with highlighted 'culture' part
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: _primaryGreen,
                          ),
                          children: [
                            const TextSpan(text: 'agri'),
                            WidgetSpan(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  color: _primaryGreen.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'culture',
                                  style: TextStyle(
                                    color: _darkGreen,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Welcome Back, Farmer!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333), // Darker text
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Phone Input
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
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your phone number'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Password Input
                    Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                        suffixIcon: Icon(
                          Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your password' : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: _primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New to AgriGuard? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: _primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
