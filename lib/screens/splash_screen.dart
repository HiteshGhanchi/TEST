import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_database.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      if (MockDatabase().isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ------------------ FARMER ABOVE WAVE ------------------
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: screenHeight * 0.70,
              width: double.infinity,
              color: Colors.green.shade100,
              child: Center(
                child: Image.asset(
                  'assets/farmer.png',
                  fit: BoxFit.contain,
                  height: screenHeight * 0.60,
                ),
              ),
            ),
          ),

          // ------------------ WHITE SECTION BELOW WAVE ------------------
          Expanded(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ------------ LOGO IMAGE ------------
                  SizedBox(
                    width: screenWidth * 0.65,
                    child: Image.asset(
                      'assets/white_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ------------ CENTERED LOADER ------------
                  CircularProgressIndicator(
                    color: Colors.green.shade700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ WAVE CLIPPER ------------------
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);

    var cp1 = Offset(size.width * 0.25, size.height);
    var ep1 = Offset(size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(cp1.dx, cp1.dy, ep1.dx, ep1.dy);

    var cp2 = Offset(size.width * 0.75, size.height - 80);
    var ep2 = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(cp2.dx, cp2.dy, ep2.dx, ep2.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
