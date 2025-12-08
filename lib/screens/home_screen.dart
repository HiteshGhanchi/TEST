import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/api_client.dart';
import '../models/farm_model.dart';
import '../I10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Farm>> _farmsFuture;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _farmsFuture = ApiClient().getFarms();
    ApiClient().getMe().then((data) {
      if (mounted) setState(() => _userProfile = data['data']);
    }).catchError((_) {});
  }

  Future<void> _refreshFarms(BuildContext context) async {
    try {
      setState(() {
        _farmsFuture = ApiClient().getFarms();
      });
      await _farmsFuture;
      if (mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farms refreshed')));
    } catch (e) {
      if (mounted && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Refresh failed: ${e.toString()}')));
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await ApiClient().logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green.shade100,
              backgroundImage: const AssetImage('assets/farmer.png'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.translate('welcome_back'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  _userProfile?['name'] ?? "Farmer",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () async { await _refreshFarms(context); },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _farmsFuture = ApiClient().getFarms();
          });
          await _farmsFuture;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Weather Widget ---
              _buildWeatherCard(l10n),
              
              const SizedBox(height: 24),

              // --- 2. Smart Farming Grid ---
              Text(l10n.translate('smart_farming'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildFeatureGrid(context, l10n),

              const SizedBox(height: 24),

              // --- 3. Farm Management ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.translate('my_farms'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () async {
                      if (!mounted || !context.mounted) return;
                      final res = await context.push('/add-farm');
                      if (mounted && res == true && context.mounted) {
                        await _refreshFarms(context);
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text(l10n.translate('add_new')),
                    style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
                  )
                ],
              ),
              
              const SizedBox(height: 8),

              // --- Farm List FutureBuilder ---
              FutureBuilder<List<Farm>>(
                future: _farmsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final farms = snapshot.data ?? [];
                  if (farms.isEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: farms.length,
                    itemBuilder: (ctx, index) => _buildFarmCard(context, farms[index], l10n),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('todays_weather'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 5),
              const Text("28°C", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              Text("${l10n.translate('sunny')} • Humidity 65%", style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          Icon(Icons.wb_sunny, color: Colors.yellow.shade400, size: 50),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35, 
      children: [
        _buildFeatureCard(context, l10n.translate('advisory'), l10n.translate('ask_agribot'), Icons.chat_bubble_outline, Colors.blue, '/advisory'),
        _buildFeatureCard(context, l10n.translate('community'), l10n.translate('discussion'), Icons.groups_outlined, Colors.orange, '/community'),
        _buildFeatureCard(context, l10n.translate('finance'), l10n.translate('ledger'), Icons.account_balance_wallet_outlined, Colors.purple, '/finance'),
        _buildFeatureCard(context, l10n.translate('profile'), l10n.translate('bank_land'), Icons.person_outline, Colors.teal, '/profile'),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(l10n.translate('no_farms'))),
    );
  }

  Widget _buildFarmCard(BuildContext context, Farm farm, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => context.push('/farm/${farm.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70, height: 70, color: Colors.green.shade100,
                child: const Icon(Icons.agriculture, color: Colors.green),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(farm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          farm.address, 
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(l10n.translate('active'), style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}