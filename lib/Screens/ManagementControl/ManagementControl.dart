// ignore_for_file: use_build_context_synchronously, empty_catches, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../HomePage.dart';
import '../Page/Receipt/LaporanStokObat.dart';
import 'ManageDoctor.dart';
import 'ManagePricelist.dart';
import 'ManagementStaff.dart';

class ManagementControl extends StatefulWidget {
  const ManagementControl({super.key});

  @override
  State<ManagementControl> createState() => _ManagementControlState();
}

class _ManagementControlState extends State<ManagementControl> {
  bool isSidebarExpanded = true;
  int selectedPageIndex = 0;
  bool isAuthenticated = false;
  final TextEditingController _passwordController = TextEditingController();
  String? managementPassword; // Password fetched from Firebase
  bool isLoading = true;

  // List of page titles for sidebar items

  // List of pages to navigate between

  Map<String, dynamic> clinicData = {};
  // List untuk menyimpan nilai true/false dari Firebase
  List<bool> pageVisibility =
      List.filled(21, false); // Inisialisasi dengan 12 item bernilai false

  @override
  void initState() {
    super.initState();
    _fetchManagementPassword();
    getData();
  }

  Future<void> _fetchManagementPassword() async {
    final String url = '$FULLURL.json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          managementPassword = data['passwordManagement'].toString();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  void _authenticateUser() {
    final String enteredPassword = _passwordController.text.trim();

    if (enteredPassword == managementPassword) {
      setState(() {
        isAuthenticated = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda bukan admin manajemen")),
      );
    }
  }

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
    final List<Widget> pages = [
      (pageVisibility[13]) ? const ManagementDoctorPage() : Container(),
      (pageVisibility[14]) ? const ManagementStaffPage() : Container(),
      (pageVisibility[15]) ? const ManagementPriceListPage() : Container(),
      (pageVisibility[16]) ? const LaporanStokObat() : Container(),
      (pageVisibility[17]) ?  Container() : Container(),
      (pageVisibility[18]) ? Container() : Container(),
    ];
    final List<String> pageTitles = [
      'Management Doctor',
      'Management Staff',
      'Management Price List',
      'Laporan Stok Obat',
      'Sales Page',
      'Purchases Page',
      'Payroll',
    ];

    // Generate visible tiles based on pageVisibility
    List<Widget> visibleTiles = [];
    for (int i = 13; i <= 18; i++) {
      if (pageVisibility[i]) {
        visibleTiles.add(
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.white),
            title: isSidebarExpanded
                ? Text(
                    pageTitles[i - 13], // Disesuaikan dengan pageTitles
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
            onTap: () {
              setState(() {
                selectedPageIndex = i - 13; // Sesuaikan dengan indeks halaman
              });
            },
          ),
        );
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Management Control'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : isAuthenticated
                ? Row(
                    children: [
                      // Sidebar
                      AnimatedContainer(
                        width: isSidebarExpanded ? 250 : 70,
                        duration: const Duration(milliseconds: 300),
                        color: Colors.blueGrey[900],
                        child: Column(
                          children: [
                            // Sidebar items
                            Expanded(
                              child: ListView(
                                children: visibleTiles,
                              ),
                            ),

                            // Toggle button for expanding/shrinking sidebar
                            IconButton(
                              icon: Icon(
                                isSidebarExpanded
                                    ? Icons.arrow_back_ios
                                    : Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  isSidebarExpanded = !isSidebarExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      // Main content
                      Expanded(
                        child: pages[selectedPageIndex],
                      ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: Colors.orange.withOpacity(
                                0.6), // Garis tepi dengan opacity 0.6
                            width: 2, // Ketebalan garis tepi
                          ),
                        ),
                        child: Container(
                          width: 400,
                          height: 300,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(
                                0.1), // Isi dalam dengan opacity 0.1
                            borderRadius: BorderRadius.circular(
                                24), // Menyesuaikan border Card
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Enter Management Password",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                      color: Colors.black.withOpacity(0.7)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _authenticateUser,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ));
  }
}
