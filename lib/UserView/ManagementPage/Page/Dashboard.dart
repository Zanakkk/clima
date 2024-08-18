// ignore_for_file: library_private_types_in_public_api, empty_catches

import 'package:flutter/material.dart';
import '../CLIMACONTROL/PricingTableApp.dart';
import 'Dashboard/ClimaLandingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Map<String, dynamic> clinicData = {};

  @override
  void initState() {
    super.initState();
    _fetchClinicData();
  }

  Future<void> _fetchClinicData() async {
    final url = Uri.parse(
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/klinikdaffa4775.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          clinicData = json.decode(response.body) as Map<String, dynamic>;
        });
      } else {}
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 4, // Number of columns
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          DashboardBox(
            title: "Clinic Name",
            value: clinicData.isNotEmpty && clinicData['name'] != null
                ? clinicData['name']
                : 'N/A',
            color: Colors.blue,
          ),
          if (clinicData.isNotEmpty && clinicData['logo'] != null)
            Image.network(
              clinicData['logo'],
              height: 100,
              fit: BoxFit.cover,
            ),
          DashboardBox(
            title: "Address",
            value: clinicData.isNotEmpty && clinicData['address'] != null
                ? clinicData['address']
                : 'Unknown',
            color: Colors.green,
          ),
          DashboardBox(
            title: "Total Patients",
            value: clinicData.isNotEmpty && clinicData['datapasien'] != null
                ? clinicData['datapasien'].length.toString()
                : '0',
            color: Colors.blue,
          ),
          DashboardBox(
            title: "Doctors",
            value: clinicData.isNotEmpty && clinicData['dokter'] != null
                ? clinicData['dokter'].length.toString()
                : '0',
            color: Colors.orange,
          ),
          DashboardBox(
            title: "Total Procedures",
            value: clinicData.isNotEmpty && clinicData['tindakan'] != null
                ? clinicData['tindakan'].length.toString()
                : '0',
            color: Colors.teal,
          ),
          DashboardBox(
            title: "Pricelist Count",
            value: clinicData.isNotEmpty && clinicData['pricelist'] != null
                ? clinicData['pricelist'].length.toString()
                : '0',
            color: Colors.purple,
          ),
          const DashboardBox(
            title: "Plan CLIMA",
            value: "Basic", // Placeholder since the plan info is not available
            color: Colors.grey,
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
