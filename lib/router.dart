import 'package:go_router/go_router.dart';
import 'package:myapp/screens/splash_screen.dart';
import 'package:myapp/screens/onboarding/login_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/add_farm_screen.dart';
import 'package:myapp/screens/farm_details_screen.dart'; // Import the new screen
import 'package:myapp/screens/smart_camera_screen.dart';

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
      builder: (context, state) => const AddFarmScreen(accessToken: "mock"),
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
  ],
);