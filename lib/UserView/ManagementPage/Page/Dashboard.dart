import 'package:flutter/material.dart';

import '../CLIMACONTROL/PricingTableApp.dart';
import 'Dashboard/ClimaLandingPage.dart';

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> clinicData;

  const DashboardPage({super.key, required this.clinicData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 4, // 3 columns
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          DashboardBox(
            title: "Total Patients",
            value: clinicData['datapasien'] != null
                ? clinicData['datapasien'].length.toString()
                : '0',
            color: Colors.blue,
          ),
          DashboardBox(
            title: "Address",
            value: clinicData['address'] ?? 'Unknown',
            color: Colors.green,
          ),
          DashboardBox(
            title: "Doctors",
            value: clinicData['dokter'] != null
                ? clinicData['dokter'].length.toString()
                : '0',
            color: Colors.orange,
          ),
          DashboardBox(
            title: "Scaling Price",
            value: clinicData['pricelist'] != null &&
                    clinicData['pricelist']["-O4MVZ1mVnZ606Wxc2UG"] != null
                ? clinicData['pricelist']["-O4MVZ1mVnZ606Wxc2UG"]["price"]
                    .toString()
                : 'N/A',
            color: Colors.red,
          ),
          DashboardBox(
            title: "Management Password",
            value: clinicData['managementpassword'].toString(),
            color: Colors.purple,
          ),
          DashboardBox(
            title: "Total Procedures",
            value: clinicData['tindakan'] != null
                ? clinicData['tindakan'].length.toString()
                : '0',
            color: Colors.teal,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PricingTableApp()));
              },
              child: const Text('pricing')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ClimaLandingPage()));
              },
              child: const Text('Landing Page')),
          // Add more boxes with other insights from the data
        ],
      ),
    );
  }
}

class DashboardBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const DashboardBox({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
