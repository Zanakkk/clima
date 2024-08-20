// ignore_for_file: non_constant_identifier_names, empty_catches

import 'package:clima/UserView/ManagementPage/ManagementControl/ManagementControl.dart';
import 'package:flutter/material.dart';
import '../RegisterLogin/LogOut.dart';
import 'CLIMACONTROL/ClimaClinicPageControl.dart';
import 'Page/CustomerSupportPage.dart';
import 'Page/Dashboard.dart';
import 'Page/MedicalRecord/MedicalRecord.dart';
import 'Page/PatientsPage/PatientsPage.dart';
import 'Page/PeripheralPage.dart';
import 'Page/Receipt/Receipt.dart';
import 'Page/AbsenPage.dart';
import 'Page/ReservationPage.dart';
import 'Page/StaffListPage.dart';
import 'Page/StocksPage.dart';
import 'Page/TreatmentPage/TreatmentPage.dart';
import 'SideBar/SideBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  Map<String, dynamic> clinicData = {};
  // List untuk menyimpan nilai true/false dari Firebase
  List<bool> pageVisibility =
      List.filled(21, false); // Inisialisasi dengan 12 item bernilai false

  @override
  void initState() {
    super.initState();
    FULLURL =
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/${widget.id}';
    getData();
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

  // Fungsi untuk mengambil data dari Firebase dan mengontrol tampilan halaman
  Future<void> getData() async {
    final url = Uri.parse('$FULLURL/CLIMA/controllerclinic.json');

    try {
      // Mengirim GET request ke Firebase
      final response = await http.get(url);

      // Mengecek apakah response sukses
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          // Pastikan semua item dalam list adalah bool
          setState(() {
            pageVisibility =
                data.map((item) => item is bool ? item : false).toList();
          });
        } else {}
      } else {}
    } catch (error) {}
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
                    pageVisibility: pageVisibility,
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
              child: (selectedIndex == 100)
                  ? const ClimaClinicPageControl()
                  : IndexedStack(
                      index: selectedIndex,
                      children: [
                        (pageVisibility[0])
                            ? const DashboardPage()
                            : Container(),
                        (pageVisibility[1])
                            ? const ReservationsPage()
                            : Container(),
                        (pageVisibility[2])
                            ? const PatientsPage()
                            : Container(),
                        (pageVisibility[3])
                            ? const TreatmentsPage()
                            : Container(),
                        (pageVisibility[4])
                            ? const MedicalRecord()
                            : Container(),
                        (pageVisibility[5]) ? const Receipt() : Container(),
                        const ManagementControl(),
                        (pageVisibility[7])
                            ? const StaffListPage()
                            : Container(),
                        (pageVisibility[8]) ? const StocksPage() : Container(),
                        (pageVisibility[9])
                            ? const PeripheralsPage()
                            : Container(),
                        (pageVisibility[10]) ? const Absen() : Container(),
                        (pageVisibility[11])
                            ? const CustomerSupportPage()
                            : Container(),
                        const LogOut(),
                        // Ensure CLIMA page appears here when selectedIndex == 100
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
