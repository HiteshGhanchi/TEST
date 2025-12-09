import 'package:latlong2/latlong.dart';

enum BlockStatus { pending, completed }

class SamplingBlock {
  final String id;
  final LatLng center; // The target location
  final List<LatLng> boundary; // The polygon (visual only)
  BlockStatus status;
  
  SamplingBlock({
    required this.id,
    required this.center,
    required this.boundary,
    this.status = BlockStatus.pending,
  });
}