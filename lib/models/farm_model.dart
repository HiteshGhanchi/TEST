import 'package:latlong2/latlong.dart';

// Represents a single farm boundary point [Longitude, Latitude]
typedef GeoJsonCoordinate = List<double>;

// Represents the Farm Boundary GeoJSON structure
class FarmBoundary {
  final String type;
  final List<List<GeoJsonCoordinate>> coordinates;

  FarmBoundary({this.type = "Polygon", required this.coordinates});

  factory FarmBoundary.fromLatLng(List<LatLng> points) {
    if (points.isEmpty) {
      return FarmBoundary(coordinates: [[]]);
    }

    // GeoJSON polygon ring must be closed (start point = end point)
    List<GeoJsonCoordinate> ring = points
        .map((p) => [p.longitude, p.latitude]) // GeoJSON is [Lon, Lat]
        .toList();
    
    if (ring.isNotEmpty) {
      final first = ring.first;
      final last = ring.last;
      // Close the ring if not already closed
      if (first[0] != last[0] || first[1] != last[1]) {
        ring.add(first);
      }
    }

    return FarmBoundary(coordinates: [ring]);
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates
  };

  factory FarmBoundary.fromJson(Map<String, dynamic> json) {
    var coordsList = json['coordinates'] as List?;
    if (coordsList == null || coordsList.isEmpty) {
      return FarmBoundary(coordinates: [[]]);
    }

    // Handle specific GeoJSON structure variations if necessary
    List<List<GeoJsonCoordinate>> parsedCoords = [];
    
    try {
      for (var ring in coordsList) {
        if (ring == null) continue;
        List<GeoJsonCoordinate> parsedRing = [];
        for (var point in ring) {
          if (point is List && point.isNotEmpty) {
            parsedRing.add(
              point
                  .whereType<num>()
                  .map((e) => e.toDouble())
                  .toList()
                  .cast<double>(),
            );
          }
        }
        if (parsedRing.isNotEmpty) {
          parsedCoords.add(parsedRing);
        }
      }
    } catch (e) {
      // Fallback to empty boundary if parsing fails
      return FarmBoundary(coordinates: [[]]);
    }

    return FarmBoundary(
      type: json['type'] ?? "Polygon",
      coordinates: parsedCoords.isEmpty ? [[]] : parsedCoords,
    );
  }
}

class Farm {
  final String id;
  final String name;
  final String address;
  final FarmBoundary boundary;
  final String? cropId;
  final LatLng? center;

  Farm({
    required this.id,
    required this.name,
    required this.address,
    required this.boundary,
    this.cropId,
    this.center,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    // Parse Center Point if available
    LatLng? centerPoint;
    if (json['center'] is Map) {
      final center = json['center'] as Map<String, dynamic>;
      final lat = center['lat'];
      final lon = center['lon'];
      if (lat != null && lon != null) {
        try {
          centerPoint = LatLng(
            (lat as num).toDouble(),
            (lon as num).toDouble(),
          );
        } catch (_) {
          // If conversion fails, skip center
          centerPoint = null;
        }
      }
    }

    return Farm(
      id: json['id']?.toString() ?? 'unknown',
      name: json['name']?.toString() ?? 'Unnamed Farm',
      address: json['address']?.toString() ?? "Farm Location",
      boundary: json['boundary'] != null
          ? FarmBoundary.fromJson(json['boundary'])
          : FarmBoundary(coordinates: [[]]),
      cropId: json['current_crop_id']?.toString() ?? json['cropId']?.toString(),
      center: centerPoint,
    );
  }
}

/// Request model used when creating a new farm via API.
class CreateFarmRequest {
  final String name;
  final String address;
  final List<LatLng> boundaryPoints;
  final String? cropId;

  CreateFarmRequest({
    required this.name,
    required this.address,
    required this.boundaryPoints,
    this.cropId,
  });

  Map<String, dynamic> toJson() {
    final boundary = FarmBoundary.fromLatLng(boundaryPoints);
    return {
      'name': name,
      'address': address,
      'boundary': boundary.toJson(),
      if (cropId != null) 'cropId': cropId,
    };
  }
}