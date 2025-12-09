import 'dart:io';
import 'package:image/image.dart' as img;

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  /// Calculates the Laplacian Variance of an image.
  /// A lower variance indicates less edge detail (blurrier).
  /// A threshold of ~100-300 is common, but depends on resolution/lighting.
  Future<bool> isBlurry(String imagePath, {double threshold = 150.0}) async {
    try {
      // 1. Read Image
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return true; // Fail safe

      // 2. Resize to speed up calculation (processing full res is slow)
      final resized = img.copyResize(image, width: 500);

      // 3. Convert to Grayscale
      final grayscale = img.grayscale(resized);

      // 4. Apply Laplacian Kernel
      // [ 0, -1,  0]
      // [-1,  4, -1]
      // [ 0, -1,  0]
      final laplacian = img.convolution(grayscale, filter: [0, -1, 0, -1, 4, -1, 0, -1, 0]);

      // 5. Calculate Variance
      double sum = 0.0;
      double sumSq = 0.0;
      int count = 0;

      // Iterate through pixels to calculate statistical variance
      for (var pixel in laplacian) {
        // Since it's grayscale, r, g, and b are the same. We use r (red channel).
        final val = pixel.r.toDouble(); 
        sum += val;
        sumSq += val * val;
        count++;
      }

      final mean = sum / count;
      final variance = (sumSq / count) - (mean * mean);

      // If variance is less than threshold, it is blurry
      return variance < threshold;

    } catch (e) {
      // If something goes wrong, assume it's bad to force retake
      return true;
    }
  }
}