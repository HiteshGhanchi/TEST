import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:exif/exif.dart';
import '../data/capture_data.dart';
import 'verification_result_screen.dart'; // Next screen

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Position? _currentPosition;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
    _startHighAccuracyLocation();
  }

  // --- LOCATION & PERMISSIONS ---
  Future<void> _startHighAccuracyLocation() async {
    setState(() => _isLocating = true);

    // 1. Check permissions and services
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle denied state for user guidance
        setState(() => _isLocating = false);
        return;
      }
    }

    // 2. Get high-accuracy position right away
    try {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      );
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e) {
      // Handle location fetch errors
      _showErrorDialog(
        "Location Error",
        "Could not get device GPS. Ensure location services are on.",
      );
    } finally {
      setState(() => _isLocating = false);
    }
  }

  // --- CAPTURE & VERIFICATION ---
  Future<void> _onCapture() async {
    if (_isLocating || _currentPosition == null) {
      _showErrorDialog(
        "Location Required",
        "Acquiring high-accuracy GPS. Please wait a moment.",
      );
      return;
    }

    try {
      await _initializeControllerFuture;
      final XFile photo = await _controller.takePicture();
      final File imageFile = File(photo.path);

      // 1. Extract EXIF data
      final Map<String, IfdTag> tags = await readExifFromBytes(
        await imageFile.readAsBytes(),
      );
      final GpsInfo? exifGps = tags.containsKey('GPS GPSLatitude')
          ? extractGpsInfo(tags)
          : null;
      final DateTime? exifDT = tags.containsKey('Image DateTime')
          ? DateTime.tryParse(
              tags['Image DateTime']!.values
                  .toString()
                  .replaceFirst(':', '')
                  .replaceAll(':', '-')
                  .trim(),
            )
          : null;

      // 2. Create Capture Data Object
      final CaptureData data = CaptureData(
        photoFile: photo,
        captureLat: _currentPosition!.latitude,
        captureLon: _currentPosition!.longitude,
        exifLat: exifGps?.latitude,
        exifLon: exifGps?.longitude,
        exifTimestamp: exifDT,
      );

      // 3. Client-Side EXIF check (MANDATORY)
      if (!data.isExifDataPresent) {
        _showErrorDialog(
          "Location Missing in Photo",
          "The photo file is missing location data. Please enable 'Geotagging' or 'Camera Location' in your device camera settings and retry.",
        );
        await imageFile.delete(); // Clean up local file
        return;
      }

      // 4. Navigate to the next screen for upload
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerificationResultScreen(captureData: data),
        ),
      );
    } catch (e) {
      _showErrorDialog(
        "Capture Failed",
        "An error occurred during capture: $e",
      );
    }
  }

  // --- UI & Helpers ---
  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Minimal GPS extraction helper (needs more robust date/time handling for production)
  GpsInfo? extractGpsInfo(Map<String, IfdTag> tags) {
    // Simplified logic: production code needs robust conversion of Rational values
    // This is often complex; relying on server-side exifr is safer, but we need the client check
    // For now, we only check for the presence of the tags.
    // A fully robust implementation is verbose. We assume tags[key].values are present for the check.
    if (tags.containsKey('GPS GPSLatitude') &&
        tags.containsKey('GPS GPSLongitude')) {
      // Mock data extraction for demo purposes, assume location is present if tags are.
      return GpsInfo(latitude: 0.0, longitude: 0.0);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Farm Photo')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isLocating
                            ? '🛰️ Getting high-accuracy GPS...'
                            : _currentPosition != null
                            ? '✅ GPS Locked. Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m'
                            : '❌ Location Unavailable. Check settings.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: FloatingActionButton(
                      onPressed: _onCapture,
                      child: const Icon(Icons.camera_alt, size: 36),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class GpsInfo {
  final double latitude;
  final double longitude;
  GpsInfo({required this.latitude, required this.longitude});
}
