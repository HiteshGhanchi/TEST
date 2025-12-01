import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/ml_service.dart';

class SmartCameraScreen extends StatefulWidget {
  final String farmId;
  const SmartCameraScreen({super.key, required this.farmId});

  @override
  State<SmartCameraScreen> createState() => _SmartCameraScreenState();
}

class _SmartCameraScreenState extends State<SmartCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isMacroMode = false; // False = Wide Field, True = Macro Detail
  bool _isProcessing = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndValidate() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() => _isProcessing = true);

      // 1. Capture Image
      final image = await _controller!.takePicture();

      // 2. Run ML Validation
      // We tell the user we are "Analyzing crop health..."
      double confidence = await MLService().validateCropImage(image.path);

      setState(() => _isProcessing = false);

      // 3. Check Results
      // Threshold: 0.7 (70% confidence)
      if (confidence > 0.7) {
        _showSuccessDialog(image.path);
      } else {
        _showRetryDialog("Image Unclear or Not a Crop", "Please ensure the crop is centered and well-lit.");
      }

    } catch (e) {
      setState(() => _isProcessing = false);
      _showRetryDialog("Camera Error", e.toString());
    }
  }

  void _showSuccessDialog(String path) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text("Good Shot!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("Crop identified successfully.", style: TextStyle(color: Colors.grey)),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx), 
                    child: const Text("Retake")
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.pop(); // Return to Details
                      // Add logic here to save 'path' to database
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Weekly update saved!")));
                    },
                    child: const Text("Save Update")
                  )
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showRetryDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Try Again"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          if (_controller != null && _controller!.value.isInitialized)
            Center(child: CameraPreview(_controller!))
          else
            const Center(child: CircularProgressIndicator()),

          // 2. Overlay (Grid or Macro Box)
          _buildOverlay(),

          // 3. Top Bar (Back & Flash)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text(
                    _isMacroMode ? "MACRO MODE" : "FIELD VIEW",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              ],
            ),
          ),

          // 4. Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeButton("Wide Field", !_isMacroMode, () => setState(() => _isMacroMode = false)),
                      const SizedBox(width: 20),
                      _buildModeButton("Close-up (Macro)", _isMacroMode, () => setState(() => _isMacroMode = true)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Capture Button
                  GestureDetector(
                    onTap: _isProcessing ? null : _captureAndValidate,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: _isProcessing ? Colors.grey : Colors.white,
                      ),
                      child: _isProcessing 
                        ? const CircularProgressIndicator() 
                        : Icon(Icons.camera, size: 40, color: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.white54),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (_isMacroMode) {
            // Macro: Focus Box in center
            return Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellowAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Place leaf here", style: TextStyle(color: Colors.yellowAccent, backgroundColor: Colors.black45)),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            );
          } else {
            // Wide: Rule of Thirds Grid
            return Column(
              children: [
                Expanded(child: Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24, width: 1))))),
                Expanded(child: Container(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white24, width: 1))))),
                Expanded(child: Container()),
              ],
            );
          }
        },
      ),
    );
  }
}