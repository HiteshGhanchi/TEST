import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_database.dart';

class FarmDetailsScreen extends StatefulWidget {
  final String farmId;

  const FarmDetailsScreen({super.key, required this.farmId});

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final farm = MockDatabase().farms.firstWhere(
      (f) => f.id == widget.farmId,
      orElse: () => Farm(id: '0', name: 'Unknown', address: '', sowingDate: DateTime.now(), crop: '', boundaryPoints: []),
    );

    if (farm.id == '0') {
      return const Scaffold(
        body: Center(child: Text("Farm not found")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- TOP CARD ----------
            Container(
              margin: const EdgeInsets.all(18),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    farm.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.grass, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        farm.crop,
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          farm.address,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ---------- ACTION BUTTONS ----------
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 1,
                children: [
                  _buildActionTile(
                    title: "Weekly Update",
                    subtitle: "Click Photo",
                    icon: Icons.camera_alt,
                    color: Colors.green.shade700,
                    onTap: () {
                        context.push('/camera/${widget.farmId}');
                    }
                  ),
                  _buildActionTile(
                    title: "Damage Report",
                    subtitle: "Report Issue",
                    icon: Icons.report_gmailerrorred_rounded,
                    color: Colors.red.shade600,
                    onTap: () {},
                  ),
                  _buildActionTile(
                    title: "Past Reports",
                    subtitle: "View History",
                    icon: Icons.history,
                    color: Colors.blue.shade700,
                    onTap: () {},
                  ),
                  _buildActionTile(
                    title: "Analytics",
                    subtitle: "Farm Insights",
                    icon: Icons.analytics_outlined,
                    color: Colors.orange.shade700,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
