// ignore_for_file: library_private_types_in_public_api, file_names, non_constant_identifier_names

import 'package:flutter/material.dart';

import '../RegisterLogin/LogOut.dart';
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
import 'Page/TreatmentPage/TreatmentPage.dart';
import 'SideBar/SideBar.dart';

String FULLURL = '';

class HomePage extends StatefulWidget {
  const HomePage({required this.id, super.key});
  final String id;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isExpanded = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Gabungkan id dengan URL dasar
    setState(() {

    });
    FULLURL =
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/${widget.id}';
    // Debugging output to check the URL
  }

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
                Expanded(
                  child: Sidebar(
                    isExpanded: isExpanded,
                    onItemSelected: selectPage,
                  ),
                ),
                IconButton(
                  icon:
                      Icon(isExpanded ? Icons.arrow_back : Icons.arrow_forward),
                  onPressed: toggleSidebar,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IndexedStack(
                index: selectedIndex,
                children:const [
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
                  LogOut(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
