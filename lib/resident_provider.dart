import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'resident.dart';

class ResidentProvider extends ChangeNotifier {
  final List<Resident> _residents = [];
  final List<DateTime> _emergencyAlerts = [];
  
  List<Resident> get residents => _residents;

  List<int> get alertsPerMonth {
    List<int> monthlyAlerts = List.generate(12, (index) => 0);
    for (var alert in _emergencyAlerts) {
      monthlyAlerts[alert.month - 1]++;
    }
    return monthlyAlerts;
  }

  /// Fetch residents from the API and update the provider's list
  Future<void> fetchResidents() async {
    final url = Uri.parse('http://localhost:5000/api/patient/list'); // Replace with your API endpoint
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Resident> loadedResidents = data.map((item) {
          return Resident(
            id: item['_id']['\$oid'] ?? '',
            name: item['name'] ?? '',
            age: 0, // Default values for unused fields
            gender: '',
            contact: '',
            emergencyContactName: '',
            emergencyContactPhone: '',
          );
        }).toList();
        setResidents(loadedResidents);
      } else {
        throw Exception('Failed to load residents');
      }
    } catch (error) {
      print('Error fetching residents: $error');
    }
  }

  /// Updates a resident's health data in the list
  void updateResidentHealthData(Resident updatedResident) {
    final index = _residents
        .indexWhere((resident) => resident.name == updatedResident.name);
    if (index != -1) {
      _residents[index] = updatedResident;
      notifyListeners();
    }
  }

  /// Sends an emergency alert and logs the alert timestamp
  void sendEmergencyAlert(String residentName) {
    final alertTime = DateTime.now();
    _emergencyAlerts.add(alertTime);
    notifyListeners();
  }

  /// Sets the list of residents and notifies listeners
  void setResidents(List<Resident> initialResidents) {
    _residents.clear();
    _residents.addAll(initialResidents);
    notifyListeners();
  }
}
