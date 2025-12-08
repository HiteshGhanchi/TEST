import 'package:go_router/go_router.dart';
import 'package:myapp/screens/splash_screen.dart';
import 'package:myapp/screens/onboarding/login_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/add_farm_screen.dart';
import 'package:myapp/screens/farm_details_screen.dart';
import 'package:myapp/screens/smart_camera_screen.dart';

// Import the new feature screens based on your uploaded files
import 'package:myapp/screens/smart_farming/community_hub_screen.dart';
import 'package:myapp/screens/smart_farming/finance_ledger_screen.dart';
import 'package:myapp/screens/advisory/advisory_chat_screen.dart';
import 'package:myapp/screens/profile_setup/profile_setup_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
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
    GoRoute(
      path: '/camera/:farmId',
      builder: (context, state) => SmartCameraScreen(farmId: state.pathParameters['farmId']!),
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
      builder: (context, state) => const ProfileSetupScreen(), // Or a ProfileViewScreen if you have one
    ),
    GoRoute(
  path: '/camera/:farmId',
  builder: (context, state) => SmartCameraScreen(farmId: state.pathParameters['farmId']!),
),
  ],
);