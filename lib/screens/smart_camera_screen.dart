import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../services/ml_service.dart';
import '../data/crop_standards.dart';
import '../api/api_client.dart';

class SmartCameraScreen extends StatefulWidget {
  final String farmId;
  const SmartCameraScreen({super.key, required this.farmId});

  @override
  State<SmartCameraScreen> createState() => _SmartCameraScreenState();
}

class _SmartCameraScreenState extends State<SmartCameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  bool _isLoading = true;
  
  // GPS State
  Position? _currentPosition;
  bool _isLocating = false;

  // Session State
  List<PhotoRequirement> _requirements = [];
  int _currentReqIndex = 0;
  int _photosTakenInCurrentReq = 0;
  
  @override
  void initState() {
    super.initState();
    _initCamera();
    _startHighAccuracyLocation();
    _loadRequirements();
  }
  
  Future<void> _loadRequirements() async {
    try {
      await ApiClient().getFarmById(widget.farmId);
      const int mockCurrentWeek = 5; 
      final stage = CropStandard.getStage(mockCurrentWeek);
      
      if (mounted) {
        setState(() {
          _requirements = CropStandard.getRequirements(stage);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("Data Error", "Failed to load farm protocols: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startHighAccuracyLocation() async {
    setState(() => _isLocating = true);
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => _isLocating = false);
        return;
      }
    }

    try {
      final LocationSettings locationSettings = const LocationSettings(accuracy: LocationAccuracy.bestForNavigation);
      _currentPosition = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
        await _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      if(mounted) _showErrorDialog("Camera Error", e.toString());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || _isProcessing) return;

    // --- GPS CHECK ---
    if (_currentPosition == null) {
      _showErrorDialog("Location Required", "Acquiring high-accuracy GPS. Please wait...");
      await _startHighAccuracyLocation();
      if (_currentPosition == null) return;
    }

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final req = _requirements[_currentReqIndex];

      // --- BLUR CHECK (Laplacian) ---
      // We do this BEFORE accepting the photo.
      bool isBlurry = await MLService().isBlurry(image.path);

      if (isBlurry) {
        // If blurry, show warning and DO NOT proceed.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Image is too blurry! Please hold steady."),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 2),
            )
          );
        }
      } else 
      {
        // Image is sharp, proceed with saving logic
        _photosTakenInCurrentReq++;
        
        if (_photosTakenInCurrentReq >= req.count) {
          setState(() {
            _currentReqIndex++;
            _photosTakenInCurrentReq = 0;
          });
        }
        
        if (_currentReqIndex >= _requirements.length) {
           _finishSession();
        } else {
           if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo Sharp & Saved! Next one..."), duration: Duration(seconds: 1)));
           }
        }
      }

    } catch (e) {
      _showErrorDialog("Error", e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _finishSession() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Weekly Update Complete"),
        content: const Text("Great job! All samples have been collected, geotagged, and stored."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/home');
            },
            child: const Text("Done"),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String msg) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(title), content: Text(msg), actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("OK"))]));
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized || _isLoading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    if (_currentReqIndex >= _requirements.length) return Container(color: Colors.black); 
    
    final req = _requirements[_currentReqIndex];
    final progress = "Step ${_currentReqIndex + 1}/${_requirements.length} • Photo ${_photosTakenInCurrentReq + 1}/${req.count}";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: CameraPreview(_controller!)),
          
          if (req.isMacro)
             Center(child: Container(width: 250, height: 250, decoration: BoxDecoration(border: Border.all(color: Colors.yellow, width: 2), borderRadius: BorderRadius.circular(12))))
          else
             Column(children: [Expanded(child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3)))))), Expanded(child: Container())]),

          Positioned(
            top: 50, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isLocating ? Icons.gps_not_fixed : Icons.gps_fixed, color: _isLocating ? Colors.red : Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _isLocating ? "Acquiring GPS..." : "GPS Locked (${_currentPosition?.accuracy.toStringAsFixed(1)}m)",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter
                )
              ),
              child: Column(
                children: [
                  Text(req.label.toUpperCase(), style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(req.instruction, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(progress, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 24),
                  FloatingActionButton(
                    onPressed: _isProcessing ? null : _capturePhoto,
                    backgroundColor: Colors.white,
                    child: _isProcessing 
                      ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.camera, color: Colors.green.shade800, size: 32),
                  )
                ],
              ),
            ),
          ),

           Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: const CircleAvatar(
                backgroundColor: Colors.black45,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}