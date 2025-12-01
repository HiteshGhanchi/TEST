import 'package:uuid/uuid.dart';
import 'package:camera/camera.dart';

class CaptureData {
  final String localUploadId;
  final XFile photoFile;
  final DateTime captureTimestamp;

  // Device GPS at moment of capture (Primary Verification Source)
  final double captureLat;
  final double captureLon;

  // EXIF data extracted client-side (Used for quick rejection)
  final double? exifLat;
  final double? exifLon;
  final DateTime? exifTimestamp;

  // Data updated after /presign call
  String? uploadId;
  Map<String, dynamic>? signedUploadParams;

  CaptureData({
    required this.photoFile,
    required this.captureLat,
    required this.captureLon,
    required this.exifLat,
    required this.exifLon,
    required this.exifTimestamp,
  }) : localUploadId = const Uuid().v4(),
       captureTimestamp = DateTime.now().toUtc();

  // Mandatory check: if any EXIF coordinate or timestamp is missing, reject.
  bool get isExifDataPresent =>
      exifLat != null && exifLon != null && exifTimestamp != null;
}
