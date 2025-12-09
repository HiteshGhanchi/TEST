import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../models/sampling_session.dart';

class SessionMapScreen extends StatefulWidget {
  final String farmId;
  const SessionMapScreen({super.key, required this.farmId});

  @override
  State<SessionMapScreen> createState() => _SessionMapScreenState();
}

class _SessionMapScreenState extends State<SessionMapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLocating = true;
  bool _isDevMode = false;
  StreamSubscription<Position>? _positionStream;

  // --- MOCK DATA (Replace with API later) ---
  // Create 2 targets near the user's mock location for testing
  List<SamplingBlock> _blocks = [
    SamplingBlock(
      id: '1',
      center: LatLng(28.4501, 77.2864), // Near T-Block
      boundary: [],
      status: BlockStatus.pending,
    ),
    SamplingBlock(
      id: '2',
      center: LatLng(28.4511, 77.2849), // Nearby Campus Block
      boundary: [],
      status: BlockStatus.pending,
    ),
  ];

  SamplingBlock? _selectedBlock;
  bool _isInRange = false;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    // 1. Check Permissions (Copy logic from your existing screens)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // 2. Start Stream
    const settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2);
    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen((Position position) {
  // If the accuracy is worse than 20 meters, ignore the jump
  if (position.accuracy > 20.0) {
    print("GPS Signal Weak: ${position.accuracy}m - Ignoring update");
    return; 
  }

  setState(() {
    _currentPosition = position;
    _isLocating = false;
    _checkProximity();
  });
});
  }

  void _checkProximity() {
    if (_selectedBlock == null || _currentPosition == null) {
      _isInRange = false;
      return;
    }

    // Calculate distance in meters
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _selectedBlock!.center.latitude,
      _selectedBlock!.center.longitude,
    );

    // UNLOCK DISTANCE: 30 meters
    setState(() {
      _isInRange = distance < 30;
    });
  }

  void _onBlockTapped(SamplingBlock block) {
    setState(() {
      _selectedBlock = block;
      _checkProximity();
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sampling Session")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _blocks.first.center, // Center on farm
              initialZoom: 18.0,
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              
              // 1. Draw Targets
             MarkerLayer(
                markers: _blocks.map((block) {
                  bool isSelected = _selectedBlock == block;
                  bool isCompleted = block.status == BlockStatus.completed;

                  return Marker(
                    point: block.center,
                    width: 60, // Touch target size
                    height: 60,
                    child: GestureDetector(
                      onTap: () => _onBlockTapped(block), // THIS MAKES IT CLICKABLE
                      child: Center(
                        child: Container(
                          // Visual Circle
                          width: isSelected ? 50 : 30, // Selected = Bigger
                          height: isSelected ? 50 : 30,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green.withOpacity(0.3)
                                : (isSelected
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                          // Optional: Add an icon inside so you know where to click
                          child: isCompleted
                              ? const Icon(Icons.check, size: 16, color: Colors.green)
                              : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              // 2. Draw User
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      child: const Icon(Icons.navigation, color: Colors.blue, size: 30),
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.orange,
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () {
                if (_currentPosition != null) {
                  setState(() {
                    // 1. Move the selected block (or first block) EXACTLY to you
                    SamplingBlock target = _selectedBlock ?? _blocks.first;
                    
                    // Update the list with the new position
                    _blocks[_blocks.indexOf(target)] = SamplingBlock(
                      id: target.id,
                      center: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      boundary: target.boundary,
                      status: target.status,
                    );
                    
                    // 2. Select it automatically
                    _selectedBlock = _blocks[_blocks.indexOf(target)];
                    
                    // 3. Force check proximity (will be 0 meters!)
                    _checkProximity();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("DEBUG: Target moved to you!")),
                    );
                  });
                }
              },
            ),
          ),
          Positioned(
  top: 50,
  right: 20,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Dev Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Switch(
          value: _isDevMode,
          activeColor: Colors.orange,
          onChanged: (val) {
            setState(() {
              _isDevMode = val;
            });
          },
        ),
      ],
    ),
  ),
),
          // 3. Bottom Card (The "Pokemon Go" Controller)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildBottomCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    if (_selectedBlock == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Text("Tap a red circle to start navigation.", textAlign: TextAlign.center),
      );
    }

    if (_selectedBlock!.status == BlockStatus.completed) {
       return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Block Completed!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    bool canStart = _isInRange || _isDevMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Target #${_selectedBlock!.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          
          // 2. Update Status Text
          canStart
              ? Text(
                  _isDevMode ? "Dev Mode: GPS Bypassed" : "You are in the zone!",
                  style: TextStyle(
                    color: _isDevMode ? Colors.orange : Colors.green, 
                    fontWeight: FontWeight.bold
                  ),
                )
              : const Text("Walk closer to the circle...", style: TextStyle(color: Colors.grey)),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              // 3. Logic: Enable button if canStart is true
              onPressed: canStart 
                  ? () async {
                      final result = await context.push('/block-camera', extra: _selectedBlock);
                      if (result == true) {
                        setState(() {
                          _selectedBlock!.status = BlockStatus.completed;
                          _selectedBlock = null; 
                        });
                      }
                    }
                  : null, 
              style: ElevatedButton.styleFrom(
                backgroundColor: canStart ? Colors.green : Colors.grey,
              ),
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                // 4. Update Label Text
                canStart 
                    ? (_isDevMode ? "START SAMPLING (DEV)" : "START SAMPLING") 
                    : "TOO FAR", 
                style: const TextStyle(color: Colors.white)
              ),
            ),
          ),
        ],
      ),
    );
  }
}