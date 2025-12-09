import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/ml_service.dart';
import '../data/crop_standards.dart';
import '../data/mock_database.dart';

class SmartCameraScreen extends StatefulWidget {
  final String farmId;
  const SmartCameraScreen({super.key, required this.farmId});

  @override
  State<SmartCameraScreen> createState() => _SmartCameraScreenState();
}

class _SmartCameraScreenState extends State<SmartCameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false;
  
  // Session State
  late List<PhotoRequirement> _requirements;
  int _currentReqIndex = 0;
  int _photosTakenInCurrentReq = 0;
  
  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadRequirements();
  }
  
  void _loadRequirements() {
    final farm = MockDatabase().farms.firstWhere((f) => f.id == widget.farmId);
    final stage = CropStandard.getStage(farm.currentWeek);
    _requirements = CropStandard.getRequirements(stage);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final req = _requirements[_currentReqIndex];

      // --- 1. BLUR DETECTION ---
      // We only do this check now.
      bool isBlurry = await MLService().isBlurry(image.path);
      if (isBlurry) {
        _showErrorDialog("Blurry Image", "The photo is too blurry. Please hold steady and try again.");
        setState(() => _isProcessing = false);
        return;
      }

      // --- 2. PROCEED (Validation Removed) ---
      // If not blurry, we accept the photo immediately.
      
      _photosTakenInCurrentReq++;
      
      // Check if we need to move to next requirement
      if (_photosTakenInCurrentReq >= req.count) {
        _currentReqIndex++;
        _photosTakenInCurrentReq = 0;
      }
      
      // Check if session is complete
      if (_currentReqIndex >= _requirements.length) {
          _finishSession();
      } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo Saved! Next one...")));
      }

    } catch (e) {
      _showErrorDialog("Error", e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _finishSession() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Weekly Update Complete"),
        content: const Text("Great job! All samples have been collected and geotagged."),
        actions: [
          TextButton(
            onPressed: () {
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
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    // Current Instruction
    if (_currentReqIndex >= _requirements.length) return Container(); // Session over
    final req = _requirements[_currentReqIndex];
    final progress = "Step ${_currentReqIndex + 1}/${_requirements.length} • Photo ${_photosTakenInCurrentReq + 1}/${req.count}";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: CameraPreview(_controller!)),
          
          // --- OVERLAY GUIDES ---
          if (req.isMacro)
             Center(child: Container(width: 200, height: 200, decoration: BoxDecoration(border: Border.all(color: Colors.yellow, width: 2), borderRadius: BorderRadius.circular(12))))
          else
             // Grid for wide shots
             Column(children: [Expanded(child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3)))))), Expanded(child: Container())]),

          // --- BOTTOM INSTRUCTIONS ---
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
                      ? const CircularProgressIndicator() 
                      : Icon(Icons.camera, color: Colors.green.shade800, size: 32),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}