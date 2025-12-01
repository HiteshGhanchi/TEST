import 'dart:io';
import 'package:flutter/material.dart';
import '../data/capture_data.dart';
import '../api/api_client.dart';

// Define verification statuses for UI mapping
enum VerificationStatus { pending, verified, lowConfidence, unverified, flagged, rejected }

class VerificationResultScreen extends StatefulWidget {
  final CaptureData captureData;

  const VerificationResultScreen({super.key, required this.captureData});

  @override
  State<VerificationResultScreen> createState() => _VerificationResultScreenState();
}

class _VerificationResultScreenState extends State<VerificationResultScreen> {
  VerificationStatus _status = VerificationStatus.pending;
  String _message = "Starting secure upload process...";
  double? _distance;

  @override
  void initState() {
    super.initState();
    _startUploadFlow();
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending: return Colors.blue;
      case VerificationStatus.verified: return Colors.green;
      case VerificationStatus.lowConfidence: return Colors.amber;
      case VerificationStatus.unverified: return Colors.grey;
      case VerificationStatus.flagged: return Colors.red;
      case VerificationStatus.rejected: return Colors.deepOrange;
    }
  }

  String _getStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending: return 'PENDING';
      case VerificationStatus.verified: return 'VERIFIED'; // Green badge
      case VerificationStatus.lowConfidence: return 'LOW CONFIDENCE'; // Yellow badge
      case VerificationStatus.unverified: return 'UNVERIFIED'; // Grey badge
      case VerificationStatus.flagged: return 'FLAGGED'; // Red badge
      case VerificationStatus.rejected: return 'REJECTED';
    }
  }

  Future<void> _startUploadFlow() async {
    final client = ApiClient();
    try {
      // STEP 1: /api/uploads/presign
      _updateStatus(VerificationStatus.pending, "1/3: Requesting signed upload parameters...");
      final presignResponse = await client.presignUpload(widget.captureData);
      
      widget.captureData.uploadId = presignResponse['uploadId'];
      widget.captureData.signedUploadParams = presignResponse['upload'];
      
      // STEP 2: Direct Upload to Cloudinary
      _updateStatus(VerificationStatus.pending, "2/3: Uploading file to Cloudinary...");
      final cloudinaryResponse = await client.uploadToCloudinary(
        widget.captureData.photoFile, 
        widget.captureData.signedUploadParams!,
      );

      final publicId = cloudinaryResponse['public_id'];
      
      // STEP 3: /api/uploads/complete
      _updateStatus(VerificationStatus.pending, "3/3: Submitting data for server verification...");
      final completeResponse = await client.completeUpload(
        widget.captureData, 
        publicId,
        cloudinaryResponse['secure_url'],
      );

      // Server verification result
      final String statusStr = completeResponse['verification_status']?.toLowerCase() ?? 'unverified';
      final VerificationStatus finalStatus = _parseStatus(statusStr);
      _distance = completeResponse['distance_m'];
      
      _updateStatus(finalStatus, completeResponse['verification_reason'] ?? 'Verification complete.');

    } catch (e) {
      _updateStatus(VerificationStatus.rejected, "Upload Failed: ${e.toString()}");
    } finally {
      // Clean up local photo file (Crucial)
      try {
        await File(widget.captureData.photoFile.path).delete();
      } catch (e) {
        // Ignored. Best effort to delete.
      }
    }
  }
  
  VerificationStatus _parseStatus(String status) {
    switch (status) {
      case 'verified': return VerificationStatus.verified;
      case 'low_confidence': return VerificationStatus.lowConfidence;
      case 'unverified': return VerificationStatus.unverified;
      case 'flagged': return VerificationStatus.flagged;
      case 'rejected': return VerificationStatus.rejected;
      default: return VerificationStatus.unverified;
    }
  }
  
  void _updateStatus(VerificationStatus status, String message) {
    if (mounted) {
      setState(() {
        _status = status;
        _message = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Status')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: _getStatusColor(_status),
                child: Icon(
                  _status == VerificationStatus.verified ? Icons.check :
                  _status == VerificationStatus.pending ? Icons.upload :
                  _status == VerificationStatus.rejected ? Icons.error_outline :
                  Icons.warning_amber,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _getStatusText(_status),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(_status),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              if (_distance != null) 
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Distance: ${_distance!.toStringAsFixed(2)} meters',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
              const SizedBox(height: 40),
              if (_status != VerificationStatus.pending) 
                ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Done / Take New Photo'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
