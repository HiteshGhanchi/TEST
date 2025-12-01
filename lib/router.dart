
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/add_farm_screen.dart';
import 'package:myapp/screens/advisory/advisory_chat_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/onboarding/language_select_screen.dart';
import 'package:myapp/screens/onboarding/login_screen.dart';
import 'package:myapp/screens/onboarding/set_password_screen.dart';
import 'package:myapp/screens/onboarding/signup_screen.dart';
import 'package:myapp/screens/onboarding/verify_otp_screen.dart';
import 'package:myapp/screens/profile_setup/profile_setup_screen.dart';
import 'package:myapp/screens/smart_farming/community_hub_screen.dart';
import 'package:myapp/screens/smart_farming/finance_ledger_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/signup',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LanguageSelectScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return VerifyOTPScreen(
          sessionId: extra['sessionId'],
          fullName: extra['fullName'],
          email: extra['email'],
          phone: extra['phone'],
        );
      },
    ),
    GoRoute(
      path: '/set-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return SetPasswordScreen(accessToken: extra['accessToken']);
      },
    ),
    GoRoute(
      path: '/add-farm',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return AddFarmScreen(accessToken: extra['accessToken']);
      },
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/ledger',
      builder: (context, state) => const FinanceLedgerScreen(),
    ),
    GoRoute(
      path: '/community',
      builder: (context, state) => const CommunityHubScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const AdvisoryChatScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
