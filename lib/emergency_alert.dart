import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'resident_provider.dart';

class EmergencyAlertPage extends StatefulWidget {
  const EmergencyAlertPage({super.key});

  @override
  EmergencyAlertPageState createState() => EmergencyAlertPageState();
}

class EmergencyAlertPageState extends State<EmergencyAlertPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  String? _selectedResident;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _sendEmergencyAlert() {
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert'),
        content: Text('Emergency alert has been sent for $_selectedResident!'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    final provider = Provider.of<ResidentProvider>(context, listen: false);
    provider.sendEmergencyAlert(_selectedResident!);

    Future.delayed(const Duration(seconds: 2), () {
      if (kDebugMode) {
        print('Emergency alert sent for $_selectedResident!');
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final residents = Provider.of<ResidentProvider>(context).residents;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'Emergency Alert',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
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
  items: residents.isNotEmpty
      ? residents.map((resident) {
          return DropdownMenuItem<String>(
            value: resident.name,
            child: Text(
              resident.name,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        }).toList()
      : [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'No residents available',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
  onChanged: residents.isNotEmpty
      ? (String? newValue) {
          setState(() {
            _selectedResident = newValue;
          });
        }
      : null,
  dropdownColor: Colors.white,
  icon: residents.isNotEmpty
      ? const Icon(Icons.arrow_drop_down, color: Colors.blueAccent)
      : null,
  iconSize: 30,
),

              const SizedBox(height: 40),
              GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTap: _showConfirmationDialog,
                child: ScaleTransition(
                  scale: _controller,
                  child: AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Container(
                        margin: EdgeInsets.only(bottom: _bounceAnimation.value),
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.red.shade900,
                              Colors.red.shade600,
                              Colors.red.shade400,
                            ],
                            stops: const [0.3, 0.6, 1],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/emergency_icon.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Emergency Button',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
