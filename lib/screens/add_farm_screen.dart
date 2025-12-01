// lib/screens/add_farm_screen.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../data/mock_database.dart';

class AddFarmScreen extends StatefulWidget {
  final String accessToken;
  const AddFarmScreen({super.key, required this.accessToken});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  // Removed Address Controller
  
  String? _selectedCrop;
  final List<LatLng> _polygonPoints = [];
  final MapController _mapController = MapController();

  bool _isLoading = false;
  LatLng _initialCenter = const LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _initialCenter = LatLng(position.latitude, position.longitude);
          _mapController.move(_initialCenter, 16.0);
        });
      }
    } catch (e) {
      log("Error: $e");
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng latLng) {
    if (_polygonPoints.length < 10) {
      setState(() => _polygonPoints.add(latLng));
    }
  }

  void _submitFarm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrop == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a crop")));
      return;
    }
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mark at least 3 points for boundary")));
      return;
    }

    setState(() => _isLoading = true);

    final boundaryData = _polygonPoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
    
    // Auto-generate a location string since we removed the input
    final String autoLocation = "Lat: ${_polygonPoints[0].latitude.toStringAsFixed(2)}, Lng: ${_polygonPoints[0].longitude.toStringAsFixed(2)}";

    MockDatabase().addFarm(
      _nameController.text.trim(),
      autoLocation, // Passing auto-generated location
      _selectedCrop!,
      boundaryData
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Farm Added!")));
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final crops = MockDatabase().availableCrops;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
      ),
      body: Stack(
        children: [
          // --- 1. Full Screen Map ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 13.0,
              onTap: _handleMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // FIX: Use valid package name to avoid OSM Block
                userAgentPackageName: 'com.example.myapp', 
              ),
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: _polygonPoints,
                    color: Colors.green.withOpacity(0.4),
                    borderColor: Colors.green,
                    borderStrokeWidth: 3,
                    isFilled: true,
                  ),
                ],
              ),
              MarkerLayer(
                markers: _polygonPoints.map((p) => Marker(
                  point: p,
                  width: 20, height: 20,
                  child: const Icon(Icons.circle, color: Colors.white, size: 14),
                )).toList(),
              ),
            ],
          ),

          // --- 2. Floating Controls ---
          Positioned(
            top: 100,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "undo",
                  backgroundColor: Colors.white,
                  onPressed: _polygonPoints.isEmpty ? null : () => setState(() => _polygonPoints.removeLast()),
                  child: const Icon(Icons.undo, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: "clear",
                  backgroundColor: Colors.white,
                  onPressed: _polygonPoints.isEmpty ? null : () => setState(() => _polygonPoints.clear()),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ),

          // --- 3. Bottom Form Panel (Address Removed) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("New Farm Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Farm Name',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.eco_outlined, color: Colors.green),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _selectedCrop,
                      decoration: InputDecoration(
                        labelText: 'Select Crop',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.grass, color: Colors.blue),
                      ),
                      items: crops.map((crop) => DropdownMenuItem(
                        value: crop,
                        child: Text(crop),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCrop = val),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitFarm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("SAVE FARM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}