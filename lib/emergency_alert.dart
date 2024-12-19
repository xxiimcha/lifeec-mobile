import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'resident_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyAlertPage extends StatefulWidget {
  const EmergencyAlertPage({super.key});

  @override
  EmergencyAlertPageState createState() => EmergencyAlertPageState();
}

class EmergencyAlertPageState extends State<EmergencyAlertPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  String? _selectedResident;
  List<Map<String, String>> _residents = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 25.0)
        .chain(CurveTween(curve: Curves.elasticInOut))
        .animate(_controller);

    _controller.forward();

    _fetchResidents();
  }

  Future<void> _fetchResidents() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/patient/list'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _residents = data.map<Map<String, String>>((resident) {
            return {
              "id": resident["_id"].toString(),
              "name": resident["name"].toString(),
            };
          }).toList();
        });
        if (kDebugMode) {
          print('Residents fetched: $_residents');
        }
      } else {
        throw Exception('Failed to load residents');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching residents: $e');
      }
    }
  }

  void _sendEmergencyAlert() async {
    if (_selectedResident == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please select a resident before sending an alert.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final selectedResident = _residents
        .firstWhere((resident) => resident['name'] == _selectedResident);

    final alertData = {
      "residentId": selectedResident['id'],
      "residentName": selectedResident['name'],
      "message": "Emergency alert triggered for ${selectedResident['name']}",
      "timestamp": DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/emergency-alerts'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(alertData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(
                'Emergency alert has been sent for ${selectedResident['name']}!'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to send emergency alert');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to send alert: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Alert'),
        content: const Text('Are you sure you want to send an emergency alert?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              children: [
                Image.asset('assets/images/cancel_icon.png', width: 24),
                const SizedBox(width: 8),
                const Text('Cancel'),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendEmergencyAlert();
            },
            child: Row(
              children: [
                Image.asset('assets/images/confirm_icon.png', width: 24),
                const SizedBox(width: 8),
                const Text('Send'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
      _controller.reverse();
    }

    void _onTapUp(TapUpDetails details) {
      _controller.forward();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alert'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'CODE RED',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedResident,
                hint: const Text('Select Resident'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                items: _residents.map((resident) {
                  return DropdownMenuItem<String>(
                    value: resident['name'],
                    child: Text(
                      resident['name']!,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedResident = newValue;
                  });
                },
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTap: _showConfirmationDialog,
                child: ScaleTransition(
                  scale: _controller,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Colors.red, Colors.redAccent],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Emergency Button',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
