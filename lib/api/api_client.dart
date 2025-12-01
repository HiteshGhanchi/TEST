import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import '../data/capture_data.dart';
import '../models/farm_model.dart';
import 'package:latlong2/latlong.dart';

// IMPORTANT: Use 10.0.2.2 for Android emulator to reach localhost on host machine
const String _baseUrl = 'http://10.0.2.2:3000/api';

class ApiClient {
  String? _accessToken;

  void setAuthToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // --- AUTHENTICATION ---
  Future<Map<String, dynamic>> requestOtp(String phone, String fullName, String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/request-otp'),
      headers: _headers,
      body: jsonEncode({
        'phone': phone,
        'purpose': 'signup',
        'metadata': {
          'fullName': fullName,
          'email': email,
        },
        'clientNonce': 'mock-nonce' // In a real app, generate a secure nonce
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to request OTP: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String sessionId, String otp) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/verify-otp'),
      headers: _headers,
      body: jsonEncode({
        'sessionId': sessionId,
        'otp': otp,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['tokens'] != null && data['tokens']['accessToken'] != null) {
        setAuthToken(data['tokens']['accessToken']);
      }
      return data;
    } else {
      throw Exception('Failed to verify OTP: ${response.body}');
    }
  }

  Future<void> setPassword(String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/set-password'),
      headers: _headers,
      body: jsonEncode({'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set password: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login-password'),
      headers: _headers,
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['accessToken'] != null) {
        setAuthToken(data['accessToken']);
      }
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }


  // --- FARMS ---
  Future<Farm> addFarm(String name, String address, List<LatLng> boundary) async {
    final coordinates = boundary.map((p) => [p.longitude, p.latitude]).toList();
    // Close the polygon by adding the first point at the end
    coordinates.add(coordinates.first);

    final response = await http.post(
      Uri.parse('$_baseUrl/farms'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'address': address,
        'boundary': {
          'type': 'Polygon',
          'coordinates': [coordinates],
        },
      }),
    );

    if (response.statusCode == 201) {
      return Farm.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add farm: ${response.body}');
    }
  }


  // --- UPLOADS (Existing Code) ---
  Future<Map<String, dynamic>> presignUpload(CaptureData data) async {
    final file = File(data.photoFile.path);
    final response = await http.post(
      Uri.parse('$_baseUrl/uploads/presign'),
      headers: _headers,
      body: jsonEncode({
        "localUploadId": data.localUploadId,
        "filename": data.photoFile.name,
        "filesize": await file.length(),
        "captureTimestamp": data.captureTimestamp.toIso8601String(),
        "hasCaptureCoords": data
            .isExifDataPresent, // Should always be true here, or capture wouldn't happen
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get presigned URL: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> uploadToCloudinary(
    XFile file,
    Map<String, dynamic> signedParams,
  ) async {
    final uploadUrl = signedParams['uploadUrl'] as String;
    final Map<String, dynamic> uploadFields = signedParams['uploadParams'];

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    uploadFields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Cloudinary upload failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> completeUpload(
    CaptureData data,
    String publicId,
    String storageUrl,
  ) async {
    final uploadLat = data.captureLat + 0.0001;
    final uploadLon = data.captureLon + 0.0001;

    final response = await http.post(
      Uri.parse('$_baseUrl/uploads/complete'),
      headers: _headers,
      body: jsonEncode({
        "uploadId": data.uploadId,
        "publicId": publicId,
        "localUploadId": data.localUploadId,
        "captureLat": data.captureLat,
        "captureLon": data.captureLon,
        "captureTimestamp": data.captureTimestamp.toIso8601String(),
        "uploadLat": uploadLat,
        "uploadLon": uploadLon,
        "uploadTimestamp": DateTime.now().toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(
        'Failed to complete upload: ${body['reason'] ?? response.statusCode}',
      );
    }
  }
}
