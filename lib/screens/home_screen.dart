import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_database.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockDatabase(),
      builder: (context, child) {
        final user = MockDatabase().currentUser;
        final farms = MockDatabase().farms;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Header ---
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: const AssetImage('assets/farmer.png'),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Hello,", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text(
                            user?.name ?? "Farmer",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_none, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // --- 2. Weather Bar ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cloudy", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            Text("26°C", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Icon(Icons.cloud_queue, color: Colors.white, size: 40),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- 3. Your Farms Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Your Farms", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => context.push('/add-farm'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add Farm"),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 10),

                  // --- 4. Farm List ---
                  if (farms.isEmpty)
                    _buildEmptyFarmState(context)
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: farms.length,
                      itemBuilder: (context, index) {
                        return _buildFarmCard(context, farms[index]);
                      },
                    ),
                ],
              ),
            ),
          ),
          // NO BOTTOM NAVIGATION BAR
        );
      },
    );
  }

  Widget _buildEmptyFarmState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.agriculture, size: 50, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text("No farms found", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmCard(BuildContext context, Farm farm) {
    return GestureDetector(
      // Navigate to Farm Details on Tap
      onTap: () => context.push('/farm/${farm.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Left Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/wheat1.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Center Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      farm.crop, 
                      style: const TextStyle(color: Colors.grey, fontSize: 14)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(farm.boundaryPoints.length * 0.5).toStringAsFixed(1)} Acres", 
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600, fontSize: 12)
                    ),
                  ],
                ),
              ),
              
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}