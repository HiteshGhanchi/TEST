import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client.dart';
import '../../I10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _currentSessionId;

  // 1. Request OTP
  void _handleGetOtp() async {
    final l10n = AppLocalizations.of(context);
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.translate('invalid_phone'))));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionId = await ApiClient().requestOtp(phone);
      if (mounted) {
        setState(() {
          _currentSessionId = sessionId;
          _isOtpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.translate('otp_sent'))));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  // 2. Verify OTP
  void _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || _currentSessionId == null) return;

    setState(() => _isLoading = true);

    try {
      // Pass empty phone/name since we are mocking/using session flow mostly
      await ApiClient().verifyOtp(_currentSessionId!, otp);
      
      if (mounted) {
        // Navigate to Home upon success
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.eco, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              l10n.translate('welcome_cropic'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 40),
            
            if (!_isOtpSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.translate('phone_label'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleGetOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.translate('get_otp'), style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.translate('enter_otp_label'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.translate('verify_login'), style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
              TextButton(
                onPressed: () => setState(() => _isOtpSent = false),
                child: Text(l10n.translate('change_phone')),
              )
            ]
          ],
        ),
      ),
    );
  }
}