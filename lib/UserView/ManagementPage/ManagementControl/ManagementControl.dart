// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../HomePage.dart';
import '../Page/AccountsPage.dart';
import '../Page/PaymentMethodPage.dart';
import '../Page/PurchasePage.dart';
import '../Page/Sales/SalesPage.dart';
import 'ManageDoctor.dart';
import 'ManagePricelist.dart';

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
  final List<String> pageTitles = [
    'Management Doctor',
    'Management Price List',
    'Account Page',
    'Sales Page',
    'Purchase Page',
    'Payment Method Page',
  ];

  // List of pages to navigate between
  final List<Widget> pages = [
    const ManagementDoctorPage(),
    const ManagementPriceListPage(),
    const AccountsPage(),
    const SalesPage(),
    const PurchasesPage(),
    const PaymentMethodPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchManagementPassword();
  }

  Future<void> _fetchManagementPassword() async {
    final String url = '$FULLURL.json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          managementPassword = data['managementpassword'].toString();
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

  @override
  Widget build(BuildContext context) {
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
                          // Sidebar items
                          Expanded(
                            child: ListView.builder(
                              itemCount: pageTitles.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(Icons.dashboard,
                                      color: Colors.white),
                                  title: isSidebarExpanded
                                      ? Text(
                                          pageTitles[index],
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      selectedPageIndex = index;
                                    });
                                  },
                                );
                              },
                            ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Enter Management Password",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _authenticateUser,
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
