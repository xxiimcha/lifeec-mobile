import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'resident_provider.dart';
import 'emergency_alert.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class DashboardContent extends StatelessWidget {
  final Function(BuildContext, Widget) navigateToPage;
  final String userType;

  const DashboardContent({
    super.key,
    required this.navigateToPage,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileLayout(context);
        } else {
          return _buildTabletLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              userType == 'Nurse' ? 'Resident Health Stats' : 'Notifications',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            if (userType == 'Nurse')
              Container(
                height: 300,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const BarChartSample7(),
              )
            else
              Container(
                height: 300,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Notification List',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (userType == 'Nurse')
              Center(
                child: GestureDetector(
                  onTap: () {
                    navigateToPage(context, const EmergencyAlertPage());
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(8.0),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      height: 70,
                      width: 250,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.red, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Emergency Alert',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  userType == 'Nurse' ? 'Resident Health Stats' : 'Notifications',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                if (userType == 'Nurse')
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(3, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const BarChartSample7(),
                  )
                else
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(3, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Notification List',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          if (userType == 'Nurse')
            Expanded(
              child: Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        navigateToPage(context, const EmergencyAlertPage());
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          height: 70,
                          width: 250,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.red, Colors.redAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.red, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Emergency Alert',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class BarChartSample7 extends StatelessWidget {
  const BarChartSample7({super.key});

  @override
  Widget build(BuildContext context) {
    final alertsPerMonth =
        Provider.of<ResidentProvider>(context).alertsPerMonth;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: AspectRatio(
        aspectRatio: 1.4,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            borderData: FlBorderData(
              show: true,
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    final months = [
                      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                    ];
                    final index = value.toInt();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Transform.rotate(
                          angle: -math.pi / 4,
                          child: Text(
                            months[index % months.length],
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            barGroups: _buildBarGroups(alertsPerMonth),
            maxY: (alertsPerMonth.reduce(math.max) + 5).toDouble(),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<int> alertsPerMonth) {
    return alertsPerMonth.asMap().entries.map((e) {
      final index = e.key;
      final data = e.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.toDouble(),
            color: Colors.blue,
            width: 6,
          ),
        ],
      );
    }).toList();
  }
}