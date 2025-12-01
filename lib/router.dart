
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/splash_screen.dart';
import 'package:myapp/screens/onboarding/login_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/add_farm_screen.dart';
// Import other screens if they exist and you want to keep their routes active
// import 'package:myapp/screens/smart_farming/finance_ledger_screen.dart';
// import 'package:myapp/screens/smart_farming/community_hub_screen.dart';
// import 'package:myapp/screens/advisory/advisory_chat_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/', // Start at Splash
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
      // We pass a mock token since we removed the real auth
      builder: (context, state) => const AddFarmScreen(accessToken: "mock_token"),
    ),
    // You can keep these if the files exist, or comment them out until needed
    /*
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
    */
  ],
);
