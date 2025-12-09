import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:latlong2/latlong.dart';
import '../data/capture_data.dart';
import '../models/farm_model.dart';

// Ensure this matches your backend IP (LAN IP for physical device testing)
const String _baseUrl = 'http://172.20.10.2:4000/api';

class ApiClient {
  // Singleton Pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _accessToken;
  String? _refreshToken;

  // --- GETTERS & SETTERS ---

  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;

  // Set token manually (e.g., after loading from storage on app start)
  void setAuthToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // ===========================================================================
  // 1. AUTHENTICATION
  // ===========================================================================

  /// Request OTP for phone number
  Future<String> requestOtp(String phone) async {
    final url = Uri.parse('$_baseUrl/auth/request-otp');
    log("Requesting OTP for $phone at $url");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": phone,
          "purpose": "login"
        }),
      );

      log("OTP Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Expected: { status: "ok", data: { sessionId: "<uuid>", ttlSeconds: 600 } }
        return data['data']['sessionId'];
      } else {
        throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      log("Network Error: $e");
      rethrow;
    }
  }

  /// Verify OTP and store tokens
  Future<Map<String, dynamic>> verifyOtp(String sessionId, String otp) async {
    final url = Uri.parse('$_baseUrl/auth/verify-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "sessionId": sessionId,
        "otp": otp
      }),
    );

    log("Verify Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final tokens = body['data']['tokens'];

      _accessToken = tokens['accessToken'];
      _refreshToken = tokens['refreshToken'];

      return body['data']['user']; // Returns user profile data
    } else {
      throw Exception('Invalid OTP or Session Expired');
    }
  }

  /// Refresh Access Token
  Future<void> refreshToken() async {
    if (_refreshToken == null) throw Exception("No refresh token available");

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({ "refreshToken": _refreshToken }),
    );

    if (response.statusCode == 200) {
       final body = jsonDecode(response.body);
       if (body['accessToken'] != null) {
         _accessToken = body['accessToken'];
         if (body['refreshToken'] != null) {
           _refreshToken = body['refreshToken'];
         }
       }
    } else {
      // Refresh failed, force logout
      _accessToken = null;
      _refreshToken = null;
      throw Exception("Session expired, please login again");
    }
  }

  /// Get Current User Profile
  Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  /// Logout
  Future<void> logout() async {
    if (_refreshToken != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({ "refreshToken": _refreshToken }),
        );
      } catch (e) {
        log("Logout API call failed, clearing local tokens anyway.");
      }
    }
    _accessToken = null;
    _refreshToken = null;
  }

  // ===========================================================================
  // 2. FARM MANAGEMENT
  // ===========================================================================

  /// Get List of Available Crops
  Future<List<Map<String, dynamic>>> getCrops() async {
    final url = Uri.parse('$_baseUrl/crops');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      
      // Handle various response structures
      List<dynamic> cropList = [];
      
      if (body is List) {
        // Direct list response
        cropList = body;
      } else if (body is Map) {
        // Wrapped in object with 'data', 'crops', or similar key
        if (body['data'] is List) {
          cropList = body['data'];
        } else if (body['crops'] is List) {
          cropList = body['crops'];
        } else if (body['data'] is Map && body['data']['crops'] is List) {
          cropList = body['data']['crops'];
        }
      }
      
      return List<Map<String, dynamic>>.from(cropList);
    } else {
      throw Exception('Failed to fetch crops: ${response.statusCode}');
    }
  }

  /// Get List of Farms
  Future<List<Farm>> getFarms() async {
    final url = Uri.parse('$_baseUrl/farms?page=1&perPage=50');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      List<dynamic> farmList = [];

      // Various API shapes: list, { data: { farms: [...] } }, { farms: [...] }, { data: [...] }
      if (body is List) {
        farmList = body;
      } else if (body is Map<String, dynamic>) {
        if (body['data'] is List) {
          farmList = body['data'];
        } else if (body['data'] is Map && body['data']['farms'] is List) {
          farmList = body['data']['farms'];
        } else if (body['farms'] is List) {
          farmList = body['farms'];
        } else if (body['data'] is Map && body['data']['data'] is List) {
          farmList = body['data']['data'];
        } else {
          // Try to find the first list value in the response map
          for (final v in body.values) {
            if (v is List) {
              farmList = v;
              break;
            }
          }
        }
      }

      // If still empty, return empty list
      if (farmList.isEmpty) return <Farm>[];

      return farmList.map<Farm>((item) {
        if (item is Map<String, dynamic>) {
          // Some APIs wrap the farm under 'farm' or 'item'
          if (item['farm'] is Map<String, dynamic>) {
            return Farm.fromJson(item['farm']);
          }
          return Farm.fromJson(item);
        } else if (item is String || item is num) {
          return Farm(
            id: item.toString(),
            name: 'Unnamed Farm',
            address: 'Farm Location',
            boundary: FarmBoundary(coordinates: [[]]),
          );
        } else {
          return Farm(
            id: 'unknown',
            name: 'Unnamed Farm',
            address: 'Farm Location',
            boundary: FarmBoundary(coordinates: [[]]),
          );
        }
      }).toList();
    } else {
      throw Exception('Failed to fetch farms: ${response.statusCode}');
    }
  }

  /// Get Single Farm by ID
  Future<Farm> getFarmById(String id) async {
    final url = Uri.parse('$_baseUrl/farms/$id');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      Map<String, dynamic> farmJson = {};
      
      // Handle nested structures like { data: { farm: ... } } or { farm: ... }
      if (body is Map<String, dynamic>) {
        if (body['data'] != null && body['data'] is Map && body['data']['farm'] != null) {
          farmJson = body['data']['farm'];
        } else if (body['farm'] != null && body['farm'] is Map) {
          farmJson = body['farm'];
        } else if (body['data'] != null && body['data'] is Map) {
          farmJson = body['data'];
        } else {
          farmJson = body;
        }
      }
      return Farm.fromJson(farmJson);
    } else {
      throw Exception('Failed to load farm details');
    }
  }

  /// Create a New Farm
  /// Uses FarmBoundary helper and includes cropId
  Future<Farm> createFarm({
    required String name,
    required String address,
    required List<LatLng> boundaryPoints,
    required String cropId
  }) async {
    // Ensure FarmBoundary is defined in your farm_model.dart
    final boundary = FarmBoundary.fromLatLng(boundaryPoints);

    final body = jsonEncode({
      "name": name,
      "address": address,
      "boundary": boundary.toJson(),
      "cropId": cropId
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/farms'),
      headers: _headers,
      body: body,
    );

    log("Create Farm Response: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);

      Map<String, dynamic>? farmJson;

      if (json is Map<String, dynamic>) {
        if (json['data'] is Map && json['data']['farm'] is Map) {
          farmJson = Map<String, dynamic>.from(json['data']['farm']);
        } else if (json['farm'] is Map) {
          farmJson = Map<String, dynamic>.from(json['farm']);
        } else if (json['data'] is Map && json['data']['id'] != null) {
          farmJson = Map<String, dynamic>.from(json['data']);
        } else if (json['id'] != null) {
          farmJson = Map<String, dynamic>.from(json);
        }
      }

      // If we couldn't parse a farm object from the response, try to refresh farms and find one matching name/address
      if (farmJson != null) {
        return Farm.fromJson(farmJson);
      }

      try {
        final farms = await getFarms();
        // Try to find by name+address or by recent insertion
        final match = farms.firstWhere(
          (f) => f.name == name || f.address == address,
          orElse: () => farms.isNotEmpty ? farms.first : throw Exception('Created farm not found'),
        );
        return match;
      } catch (e) {
        throw Exception('Failed to create farm or parse response: ${response.body}');
      }
    } else {
      throw Exception('Failed to create farm: ${response.body}');
    }
  }

  // ===========================================================================
  // 3. UPLOAD MANAGEMENT
  // ===========================================================================

  /// Step 1: Presign Upload (Get URL from Backend)
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
        "hasCaptureCoords": data.isExifDataPresent,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get presigned URL: ${response.body}');
    }
  }

  /// Step 2: Upload to Cloudinary (Directly from Device)
  Future<Map<String, dynamic>> uploadToCloudinary(
    XFile file,
    Map<String, dynamic> signedParams,
  ) async {
    final uploadUrl = signedParams['uploadUrl'] as String;
    final Map<String, dynamic> uploadFields = signedParams['uploadParams'];

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    // Add all fields required by Cloudinary (signature, timestamp, api_key, etc.)
    uploadFields.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add the actual file
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

  /// Step 3: Complete Upload (Notify Backend)
  Future<Map<String, dynamic>> completeUpload(
    CaptureData data,
    String publicId,
    String storageUrl,
  ) async {
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