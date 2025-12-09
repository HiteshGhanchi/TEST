import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlockCameraScreen extends StatefulWidget {
  const BlockCameraScreen({super.key});

  @override
  State<BlockCameraScreen> createState() => _BlockCameraScreenState();
}

enum CaptureStep { fieldView, cropView }

class _BlockCameraScreenState extends State<BlockCameraScreen> {
  CameraController? _controller;
  CaptureStep _currentStep = CaptureStep.fieldView;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
    if(mounted) setState(() {});
  }

  Future<void> _takePhoto() async {
    if (_controller == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      
      // TODO: Call your ApiClient().presignUpload(...) here immediately
      
      if (_currentStep == CaptureStep.fieldView) {
        // Transition to Step 2
        setState(() {
          _currentStep = CaptureStep.cropView;
          _isProcessing = false;
        });
      } else {
        // Finish
        if(mounted) {
           context.pop(true); // Return 'true' to Map Screen
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    bool isFieldView = _currentStep == CaptureStep.fieldView;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Feed
          Center(child: CameraPreview(_controller!)),

          // 2. The Ghost Overlay (Hole Punch)
          CustomPaint(
            size: Size.infinite,
            painter: HolePunchPainter(
              // If Field View: Wide Rectangle. If Crop View: Small Square.
              holeSize: isFieldView ? const Size(350, 200) : const Size(200, 200),
              borderRadius: 12,
            ),
          ),

          // 3. Instructions & Controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.black54,
              child: Column(
                children: [
                  Text(
                    isFieldView ? "STEP 1: FIELD VIEW" : "STEP 2: CROP VIEW",
                    style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFieldView 
                      ? "Hold horizontal. Fit the horizon in the box." 
                      : "Get closer. Center a single leaf/stem in the box.",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FloatingActionButton(
                    onPressed: _takePhoto,
                    backgroundColor: Colors.white,
                    child: _isProcessing 
                      ? const CircularProgressIndicator() 
                      : const Icon(Icons.camera, size: 32, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- The Painter that darkens screen except for the hole ---
class HolePunchPainter extends CustomPainter {
  final Size holeSize;
  final double borderRadius;

  HolePunchPainter({required this.holeSize, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6); // Darken opacity
    
    // Create a path for the whole screen
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Create a path for the hole in the center
    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: holeSize.width,
      height: holeSize.height,
    );
    final holePath = Path()..addRRect(RRect.fromRectAndRadius(holeRect, Radius.circular(borderRadius)));

    // Subtract hole from background
    final finalPath = Path.combine(PathOperation.difference, backgroundPath, holePath);
    
    canvas.drawPath(finalPath, paint);

    // Optional: Draw a white border around the hole
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(RRect.fromRectAndRadius(holeRect, Radius.circular(borderRadius)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}