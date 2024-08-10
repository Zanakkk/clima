// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

import 'Page/AccountsPage.dart';
import 'Page/CustomerSupportPage.dart';
import 'Page/Dashboard.dart';
import 'Page/PatientsPage/PatientsPage.dart';
import 'Page/PaymentMethodPage.dart';
import 'Page/PeripheralPage.dart';
import 'Page/PurchasePage.dart';
import 'Page/ReportsPage.dart';
import 'Page/ReservationPage.dart';
import 'Page/Sales/SalesAnalysis.dart';
import 'Page/Sales/SalesPage.dart';
import 'Page/StaffListPage.dart';
import 'Page/StocksPage.dart';
import 'Page/TreatmentsPage.dart';
import 'SideBar/SideBar.dart';
import 'odontogram/odontogram.dart';

class PatientDetailPage extends StatefulWidget {
  const PatientDetailPage({super.key});

  @override
  _PatientDetailPageState createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  bool isExpanded = true;
  int selectedIndex = 0;

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void selectPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isExpanded ? 250 : 72,
            color: Colors.white,
            child: Column(
              children: [
                IconButton(
                  icon:
                      Icon(isExpanded ? Icons.arrow_back : Icons.arrow_forward),
                  onPressed: toggleSidebar,
                ),
                Expanded(
                  child: Sidebar(
                    isExpanded: isExpanded,
                    onItemSelected: selectPage,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IndexedStack(
                index: selectedIndex,
                children:  const [
                  DashboardPage(),
                  ReservationsPage(),
                  PatientsPage(),
                  TreatmentsPage(),
                  StaffListPage(),
                  AccountsPage(),
                  SalesPage(),
                  SalesAnalysisPage(),
                  PurchasesPage(),
                  PaymentMethodPage(),
                  StocksPage(),
                  PeripheralsPage(),
                  ReportPage(),
                  CustomerSupportPage(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Patient List > Patient Detail',
      style: TextStyle(color: Colors.grey),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Patient',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Create Appointment'),
        ),
      ],
    );
  }
}

class PatientInfo extends StatelessWidget {
  const PatientInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Willie Jennie',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Have uneven jawline',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Patient Information'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Appointment History'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Medical Record'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            OutlinedButton(
              onPressed: () {},
              child: const Text('Medical'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Cosmetic'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Odontogram',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      // Add Odontogram content here
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()));
                          },
                          child: const Text('odontogram'))
                    ],
                  ),
                ),
              ),
              Card(
                color: Colors.grey[100],
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Maxillary Left Lateral Incisor',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      MedicalRecordItem(
                          date: 'May 03',
                          condition: 'Caries',
                          treatment: 'Tooth filling',
                          status: 'Done'),
                      SizedBox(height: 8),
                      MedicalRecordItem(
                          date: 'April 12',
                          condition: 'Caries',
                          treatment: 'Tooth filling',
                          status: 'Pending',
                          reason: 'Not enough time'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MedicalRecordItem extends StatelessWidget {
  final String date;
  final String condition;
  final String treatment;
  final String status;
  final String? reason;

  const MedicalRecordItem(
      {super.key,
      required this.date,
      required this.condition,
      required this.treatment,
      required this.status,
      this.reason});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date, style: const TextStyle(color: Colors.grey)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(condition,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(treatment, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Text(status,
                style: TextStyle(
                    color: status == 'Done' ? Colors.green : Colors.orange)),
          ],
        ),
        if (reason != null)
          Text('Reason: $reason', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
