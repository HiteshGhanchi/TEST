import 'package:flutter/material.dart';

// Simple model for a Farmer
class Farmer {
  final String id;
  final String name;
  final String phone;

  Farmer({required this.id, required this.name, required this.phone});
}

// Simple model for a Farm
class Farm {
  final String id;
  final String name;
  final String address;
  final List<dynamic> boundaryPoints; // List of {lat, lng} maps

  Farm({
    required this.id,
    required this.name,
    required this.address,
    required this.boundaryPoints,
  });
}

class MockDatabase extends ChangeNotifier {
  // Singleton pattern to access this anywhere
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  // --- MOCK DATA STORAGE ---
  Farmer? _currentUser;

  // Pre-filled mock data
  final List<Farmer> _mockUsers = [
    Farmer(id: "u1", name: "Ramesh Farmer", phone: "9999999999"),
    Farmer(id: "u2", name: "Suresh Field Officer", phone: "8888888888"),
  ];

  final List<Farm> _farms = [
    Farm(
      id: "f1",
      name: "Green Valley",
      address: "Village A, Plot 20",
      boundaryPoints: [], // Add mock coords if needed
    )
  ];

  // --- GETTERS ---
  List<Farm> get farms => _farms;
  Farmer? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // --- ACTIONS ---

  // Mock Login: Checks if phone matches a mock user. 
  // If not, it creates a temporary session for testing.
  Future<bool> login(String phone, String otp) async {
    // Mock network delay
    await Future.delayed(const Duration(seconds: 1));

    if (otp == "1234") { // Hardcoded OTP for simplicity
      // Find user or create new one for the session
      var user = _mockUsers.firstWhere(
        (u) => u.phone == phone,
        orElse: () => Farmer(id: "u", name: "New Farmer", phone: phone),
      );

      if (user.id == "u") {
        user = Farmer(id: "u${DateTime.now().millisecondsSinceEpoch}", name: "New Farmer", phone: phone);
      }

      _currentUser = user;
      notifyListeners(); // Update UI if listeners are attached
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void addFarm(String name, String address, List<dynamic> points) {
    final newFarm = Farm(
      id: "f${_farms.length + 1}",
      name: name,
      address: address,
      boundaryPoints: points,
    );
    _farms.add(newFarm);
    notifyListeners();
  }
}
