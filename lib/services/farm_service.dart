// lib/services/farm_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm_model.dart';
import 'dart:developer';

class FarmService {
  final String baseUrl =
      "http://localhost:4000/api"; // Replace with your actual base URL
  final String _accessToken; // Assumes you pass the user's access token

  FarmService(this._accessToken);

  Future<Farm> createFarm(CreateFarmRequest request) async {
    final url = Uri.parse('$baseUrl/farms');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
    final body = jsonEncode(request.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        return Farm.fromJson(data);
      } else {
        // Handle API errors based on your documentation
        final errorBody = jsonDecode(response.body)['error'];
        throw Exception(
          'Failed to create farm. Code: ${response.statusCode}. Message: ${errorBody['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e, s) {
      // Handle network or parsing errors
      log('Error creating farm: $e', stackTrace: s, name: 'FarmService');
      rethrow;
    }
  }

  // You would add getFarms, getFarm, updateFarm, deleteFarm methods here
}
