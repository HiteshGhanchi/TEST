import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/camera_screen.dart';
import 'package:transparent_image/transparent_image.dart';

final Color _primaryGreen = Colors.green.shade700;
final Color _darkGreen = Colors.green.shade900;
final Color _lightGreen = Colors.green.shade100;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _startClaimFlow(BuildContext context) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No camera found.')));
        }
        return;
      }

      if (context.mounted) {
        // Navigate to Camera Screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraScreen(camera: cameras.first),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error accessing camera: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 20,
              backgroundColor: _lightGreen,
              child: ClipOval(
                child: FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: const NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg'),
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                  fadeInDuration: const Duration(milliseconds: 300),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.green,
                      width: 40,
                      height: 40,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Good Morning, Alex',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
            onPressed: () => context.go('/chat'),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.red,
            ), // Use red for a notification dot look
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Weather Card ---
            _buildWeatherCard(),

            // --- 2. Smart Tools Section ---
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                "Smart Farming Tools",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildToolCard(
                    context,
                    'Finance Ledger',
                    Icons.account_balance_wallet,
                    Colors.teal,
                    '/ledger',
                  ),
                  _buildToolCard(
                    context,
                    'Community Hub',
                    Icons.people_alt,
                    Colors.blue,
                    '/community',
                  ),
                  _buildToolCard(
                    context,
                    'Trust Score',
                    Icons.workspace_premium,
                    Colors.amber,
                    null,
                  ),
                  _buildToolCard(
                    context,
                    'Mandi Rates',
                    Icons.store,
                    Colors.red,
                    null,
                  ),
                ],
              ),
            ),

            // --- 3. Recent Activity Section ---
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Recent Activity",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Activity List items
            _buildActivityTile(
              icon: Icons.qr_code_scanner,
              color: _primaryGreen,
              title: 'Scan completed for Field A',
              subtitle: 'Today, 9:41 AM',
              trailingWidget: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
            ),
            _buildActivityTile(
              icon: Icons.description,
              color: Colors.blue.shade700,
              title: 'New claim filed',
              subtitle: 'Yesterday, 3:20 PM',
              trailingWidget: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
            ),
            _buildActivityTile(
              icon: Icons.warning,
              color: Colors.red.shade700,
              title: 'Pest alert issued for Field B',
              subtitle: 'June 20, 11:00 AM',
              trailingWidget: Container(
                decoration: BoxDecoration(
                  color: _primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _startClaimFlow(context),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startClaimFlow(context),
        backgroundColor: _darkGreen,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          'File New Claim',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Fields'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Claims',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 0,
        selectedItemColor: _primaryGreen,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather in Greenfield',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '28°C Sunny',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Humidity: 65% | Wind: 12 km/h',
                      style: TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: const NetworkImage('https://openweathermap.org/img/wn/01d@2x.png'),
                width: 48,
                height: 48,
                fadeInDuration: const Duration(milliseconds: 300),
                imageErrorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    color: Colors.green,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String? route,
  ) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          context.go(route);
        }
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(25),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget trailingWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withAlpha(25),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(title),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
          trailing: trailingWidget,
        ),
      ),
    );
  }
}
