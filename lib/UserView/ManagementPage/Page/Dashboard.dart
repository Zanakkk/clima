// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../HomePage.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(
        '$FULLURL/.json'));

    if (response.statusCode == 200) {
      setState(() {
        _data = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false, // Nonaktifkan tombol kembali
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            // For larger screens, show items in a grid with 4 columns
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildDashboardCard(
                                    title: 'Total Patients',
                                    value: _data!['datapasien']
                                            ?.length
                                            .toString() ??
                                        '0',
                                    color: Colors.blue[100],
                                    icon: Icons.people,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDashboardCard(
                                    title: 'Total Reservations',
                                    value: _data!['reservation']
                                            ?.length
                                            .toString() ??
                                        '0',
                                    color: Colors.blue[200],
                                    icon: Icons.calendar_today,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDashboardCard(
                                    title: 'Total Stock Items',
                                    value: _data!['stokbarang']
                                            ?.length
                                            .toString() ??
                                        '0',
                                    color: Colors.blue[300],
                                    icon: Icons.inventory,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDashboardCard(
                                    title: 'Total Procedures',
                                    value:
                                        _data!['tindakan']?.length.toString() ??
                                            '0',
                                    color: Colors.blue[400],
                                    icon: Icons.medical_services,
                                  ),
                                ),
                              ],
                            );
                          } else if (constraints.maxWidth > 400) {
                            // For medium screens, show items in a grid with 2 columns
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDashboardCard(
                                        title: 'Total Patients',
                                        value: _data!['datapasien']
                                                ?.length
                                                .toString() ??
                                            '0',
                                        color: Colors.blue[100],
                                        icon: Icons.people,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDashboardCard(
                                        title: 'Total Reservations',
                                        value: _data!['reservation']
                                                ?.length
                                                .toString() ??
                                            '0',
                                        color: Colors.blue[200],
                                        icon: Icons.calendar_today,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDashboardCard(
                                        title: 'Total Stock Items',
                                        value: _data!['stokbarang']
                                                ?.length
                                                .toString() ??
                                            '0',
                                        color: Colors.blue[300],
                                        icon: Icons.inventory,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDashboardCard(
                                        title: 'Total Procedures',
                                        value: _data!['tindakan']
                                                ?.length
                                                .toString() ??
                                            '0',
                                        color: Colors.blue[400],
                                        icon: Icons.medical_services,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            // For small screens, show items in a single column
                            return Column(
                              children: [
                                _buildDashboardCard(
                                  title: 'Total Patients',
                                  value:
                                      _data!['datapasien']?.length.toString() ??
                                          '0',
                                  color: Colors.blue[100],
                                  icon: Icons.people,
                                ),
                                const SizedBox(height: 16),
                                _buildDashboardCard(
                                  title: 'Total Reservations',
                                  value: _data!['reservation']
                                          ?.length
                                          .toString() ??
                                      '0',
                                  color: Colors.blue[200],
                                  icon: Icons.calendar_today,
                                ),
                                const SizedBox(height: 16),
                                _buildDashboardCard(
                                  title: 'Total Stock Items',
                                  value:
                                      _data!['stokbarang']?.length.toString() ??
                                          '0',
                                  color: Colors.blue[300],
                                  icon: Icons.inventory,
                                ),
                                const SizedBox(height: 16),
                                _buildDashboardCard(
                                  title: 'Total Procedures',
                                  value:
                                      _data!['tindakan']?.length.toString() ??
                                          '0',
                                  color: Colors.blue[400],
                                  icon: Icons.medical_services,
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPatientsSection(),
                      const SizedBox(height: 20),
                      _buildReservationsSection(),
                    ],
                  ),
                )
              : const Center(child: Text('Failed to load data')),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required Color? color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsSection() {
    List<Widget> patientCards = [];
    if (_data!['datapasien'] != null) {
      _data!['datapasien'].forEach((key, value) {
        patientCards.add(
          SizedBox(
            width: MediaQuery.of(context).size.width / 2 -
                24, // Adjust the width to make it rectangular
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(value['imageUrl']),
                ),
                title: Text(value['fullName']),
                subtitle: Text(
                    'Phone: ${value['phone']}\nAddress: ${value['address']}'),
              ),
            ),
          ),
        );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Patients',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16.0, // Space between cards
          runSpacing: 16.0, // Space between rows
          children: patientCards,
        ),
      ],
    );
  }

  Widget _buildReservationsSection() {
    List<Widget> reservationCards = [];
    if (_data!['reservation'] != null) {
      _data!['reservation'].forEach((key, value) {
        reservationCards.add(
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('${value['name']} - ${value['date']}'),
              subtitle:
                  Text('Time: ${value['time']}\nPurpose: ${value['purpose']}'),
            ),
          ),
        );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reservations',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16.0, // Space between cards
          runSpacing: 16.0, // Space between rows
          children: reservationCards,
        ),
      ],
    );
  }
}
