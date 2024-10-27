import 'package:flutter/material.dart';
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

  void updateResidentHealthData(Resident updatedResident) {
    final index = _residents
        .indexWhere((resident) => resident.name == updatedResident.name);
    if (index != -1) {
      _residents[index] = updatedResident;
      notifyListeners();
    }
  }

  void sendEmergencyAlert(String residentName) {
    final alertTime = DateTime.now();
    _emergencyAlerts.add(alertTime);
    notifyListeners();
  }

  void setResidents(List<Resident> initialResidents) {
    _residents.clear();
    _residents.addAll(initialResidents);
    notifyListeners();
  }
}
