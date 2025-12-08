import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  Interpreter? _interpreter;

  bool get isModelLoaded => _interpreter != null;

  /// Initialize the model (Call this in main.dart or Splash)
  Future<void> loadModel() async {
    try {
      // Ensure you add 'assets/model.tflite' and 'assets/labels.txt' to pubspec
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      // _labels = await FileUtil.loadLabels('assets/labels.txt'); // If you have labels
    } catch (e) {
      // Silently fail - using Mock Mode
    }
  }

  /// Validates if the image contains a crop/field
  /// Returns a confidence score (0.0 to 1.0)
  Future<double> validateCropImage(String imagePath) async {
    if (_interpreter == null) {
      return _mockValidation(); // Fallback for testing
    }

    // --- REAL ML LOGIC (Standard MobileNet Input) ---
    try {
      // 1. Read and Resize Image
      final imageData = File(imagePath).readAsBytesSync();
      final image = img.decodeImage(imageData);
      if (image == null) return 0.0;
      
      final resized = img.copyResize(image, width: 224, height: 224);

      // 2. Convert to input array [1, 224, 224, 3]
      var input = List.generate(1, (i) => 
        List.generate(224, (y) => 
          List.generate(224, (x) => 
            List.generate(3, (c) {
              var pixel = resized.getPixel(x, y);
              // Basic normalization (0-1 float)
              return pixel[c].toDouble() / 255.0; 
            })
          )
        )
      );

      // 3. Run Inference
      // Assuming output is [1, 1] (probability of being a crop)
      var output = List.filled(1 * 1, 0.0).reshape([1, 1]); 
      _interpreter!.run(input, output);

      return output[0][0]; // Return confidence

    } catch (e) {
      return 0.5; // Neutral score on error
    }
  }

  // --- MOCK LOGIC (For testing without .tflite file) ---
  Future<double> _mockValidation() async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate processing
    // Return a random high confidence to simulate "Success" most of the time
    // In real testing, return 0.1 to test "Failure" cases
    return 0.85 + (Random().nextDouble() * 0.15);
  }
}