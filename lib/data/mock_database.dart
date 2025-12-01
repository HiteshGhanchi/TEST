import 'package:flutter/material.dart';

class Farmer {
  final String id;
  final String name;
  final String phone;
  final String photoUrl; // Added photo URL

  Farmer({
    required this.id, 
    required this.name, 
    required this.phone,
    this.photoUrl = 'assets/farmer.png',
  });
}

class Farm {
  final String id;
  final String name;
  final String address;
  final String crop;
  final DateTime sowingDate; // NEW: Added this
  final List<dynamic> boundaryPoints; 

  Farm({
    required this.id, 
    required this.name, 
    required this.address, 
    required this.crop,
    required this.sowingDate,
    required this.boundaryPoints
  });
  
  // Helper to get current week
  int get currentWeek {
    final days = DateTime.now().difference(sowingDate).inDays;
    return (days / 7).ceil();
  }
}
class MockDatabase extends ChangeNotifier {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  Farmer? _currentUser;
  
  // --- MOCK DATA ---
  final List<String> _availableCrops = [
    "Wheat",
    "Rice (Paddy)",
    "Corn (Maize)",
    "Sugarcane",
    "Cotton",
    "Soybean",
    "Tomato",
    "Potato"
  ];

  final List<Farmer> _mockUsers = [
    Farmer(id: "u1", name: "Ramesh Kumar", phone: "9999999999"),
  ];

  final List<Farm> _farms = [
    Farm(
      id: "f1", 
      name: "Green Valley Plot", 
      address: "Village Rampur", 
      crop: "Wheat",
      sowingDate: DateTime.now().subtract(const Duration(days: 35)),
      boundaryPoints: [{19.196732, 72.896804}, {19.197000, 72.897000}, {19.198000, 72.896500}, {19.196500, 72.895500}] 
    )
  ];

  // --- GETTERS ---
  List<Farm> get farms => _farms;
  List<String> get availableCrops => _availableCrops;
  Farmer? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // --- ACTIONS ---
  Future<bool> login(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp == "1234") { 
      _currentUser = _mockUsers.firstWhere(
        (u) => u.phone == phone, 
        orElse: () => Farmer(id: "u_new", name: "Kisan Bhai", phone: phone)
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void addFarm(String name, String address, String crop, List<dynamic> points) {
    final newFarm = Farm(
      id: "f${_farms.length + 1}",
      name: name,
      address: address,
      crop: crop,
      sowingDate: DateTime.now(), // Defaults to today for new farms
      boundaryPoints: points,
    );
    _farms.add(newFarm);
    notifyListeners();
  }
}