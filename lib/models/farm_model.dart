
// lib/models/farm_model.dart

import 'package:latlong2/latlong.dart';

// Represents a single farm boundary point (Longitude, Latitude)
// GeoJSON uses [Longitude, Latitude] order.
typedef GeoJsonCoordinate = List<double>;

// Represents the Farm Boundary GeoJSON structure
class FarmBoundary {
  final String type = "Polygon";
  // The structure is: [[ [lon, lat], [lon, lat], ... ]]
  // A Polygon is an array of LinearRings (outer boundary, then holes).
  final List<List<GeoJsonCoordinate>> coordinates;

  FarmBoundary({required this.coordinates});

  factory FarmBoundary.fromLatLng(List<LatLng> points) {
    if (points.isEmpty) {
      return FarmBoundary(coordinates: [[]]);
    }

    // GeoJSON polygon ring must be closed (start point = end point)
    List<GeoJsonCoordinate> ring = points
        .map((p) => [p.longitude, p.latitude])
        .toList();
    if (ring.isNotEmpty &&
        (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1])) {
      ring.add(ring.first);
    }

    // We only support one outer boundary for simplicity
    return FarmBoundary(coordinates: [ring]);
  }

  Map<String, dynamic> toJson() => {"type": type, "coordinates": coordinates};
}

// Model for sending farm creation data to the API
class CreateFarmRequest {
  final String name;
  final String address;
  final FarmBoundary boundary;

  CreateFarmRequest({
    required this.name,
    required this.address,
    required this.boundary,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "address": address,
    "boundary": boundary.toJson(),
  };
}

// Model for the response Farm data (optional, for completeness)
class Farm {
  final String id;
  final String name;
  final String address;
  final FarmBoundary boundary;

  Farm({
    required this.id,
    required this.name,
    required this.address,
    required this.boundary,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    final boundaryData = json['boundary'] as Map<String, dynamic>;
    final coordinatesData = boundaryData['coordinates'] as List<dynamic>;

    final coordinates = coordinatesData.map<List<GeoJsonCoordinate>>((ring) {
      return (ring as List<dynamic>).map<GeoJsonCoordinate>((point) {
        return (point as List<dynamic>).map<double>((coord) => (coord as num).toDouble()).toList();
      }).toList();
    }).toList();

    return Farm(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      boundary: FarmBoundary(coordinates: coordinates),
    );
  }
}
