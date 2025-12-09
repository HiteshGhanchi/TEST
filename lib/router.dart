import 'package:go_router/go_router.dart';
import 'package:myapp/screens/splash_screen.dart';
import 'package:myapp/screens/onboarding/login_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/add_farm_screen.dart';
import 'package:myapp/screens/farm_details_screen.dart';
import 'package:myapp/screens/smart_camera_screen.dart';
import 'package:myapp/screens/onboarding/language_select_screen.dart'; // Added import
import 'package:myapp/screens/onboarding/verify_otp_screen.dart'; // Added import
import 'package:myapp/screens/onboarding/set_password_screen.dart'; // Added import

// Import the new feature screens based on your uploaded files
import 'package:myapp/screens/smart_farming/community_hub_screen.dart';
import 'package:myapp/screens/smart_farming/finance_ledger_screen.dart';
import 'package:myapp/screens/advisory/advisory_chat_screen.dart';
import 'package:myapp/screens/profile_setup/profile_setup_screen.dart';

import 'package:myapp/screens/smart_farming/session_map_screen.dart';
import 'package:myapp/screens/sampling/block_camera_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // Added Route for Language Select
    GoRoute(
      path: '/language-select',
      builder: (context, state) => const LanguageSelectScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        // Handle extra params safely
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return VerifyOTPScreen(
            sessionId: extra['sessionId'] ?? '',
            fullName: extra['fullName'] ?? '',
            email: extra['email'] ?? '',
            phone: extra['phone'] ?? ''
        );
      },
    ),
    GoRoute(
      path: '/set-password',
      builder: (context, state) {
         final extra = state.extra as Map<String, dynamic>? ?? {};
         return SetPasswordScreen(accessToken: extra['accessToken'] ?? '');
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-farm',
      builder: (context, state) => const AddFarmScreen(accessToken: "valid"),
    ),
    GoRoute(
      path: '/farm/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return FarmDetailsScreen(farmId: id);
      },
    ),
    
    // --- NEW ROUTES FOR HOME SCREEN NAVIGATION ---
    GoRoute(
      path: '/community',
      builder: (context, state) => const CommunityHubScreen(),
    ),
    GoRoute(
      path: '/finance',
      builder: (context, state) => const FinanceLedgerScreen(),
    ),
    GoRoute(
      path: '/advisory',
      builder: (context, state) => const AdvisoryChatScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileSetupScreen(), 
    ),
    GoRoute(
      path: '/camera/:farmId',
      builder: (context, state) => SmartCameraScreen(farmId: state.pathParameters['farmId']!),
    ),
    GoRoute(
      path: '/session-map/:farmId',
      builder: (context, state) => SessionMapScreen(farmId: state.pathParameters['farmId']!),
    ),
    GoRoute(
      path: '/block-camera',
      builder: (context, state) => const BlockCameraScreen(),
    ),
  ],
);