// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  Map<String, dynamic>? _selectedPatient;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPatients);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    final url = Uri.parse(
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/datapasien.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        final List<Map<String, dynamic>> patients = [];
        data.forEach((id, patientData) {
          patients.add({
            'id': id,
            ...patientData,
          });
        });
        setState(() {
          _patients = patients;
          _filteredPatients = patients;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch patients.')),
      );
    }
  }

  void _filterPatients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((patient) {
        String fullName = patient['fullName'].toLowerCase();
        String nik = patient['nik']?.toLowerCase() ?? '';
        String phone = patient['phone']?.toLowerCase() ?? '';
        return fullName.contains(query) ||
            nik.contains(query) ||
            phone.contains(query);
      }).toList();
    });
  }

  String _calculateAge(String dob) {
    try {
      final parts = dob.split('/');
      if (parts.length != 3) throw const FormatException('Invalid date format');

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final birthDate = DateTime(year, month, day);
      final currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month &&
              currentDate.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by Name, NIK, or Phone',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              // Sidebar pasien
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: _filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _filteredPatients[index];
                    return ListTile(
                      leading: patient['imageUrl'] != null
                          ? Image.network(patient['imageUrl'],
                              width: 50, height: 50)
                          : const Icon(Icons.person, size: 50),
                      title: Text(patient['fullName']),
                      subtitle: Text('Umur: ${_calculateAge(patient['dob'])}'),
                      onTap: () {
                        setState(() {
                          _selectedPatient = patient;
                        });
                      },
                    );
                  },
                ),
              ),
              // Detail pasien
              Expanded(
                flex: 2,
                child: _selectedPatient != null
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          if (_selectedPatient!['imageUrl'] !=
                                              null)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                _selectedPatient!['imageUrl'],
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _selectedPatient!['fullName'],
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Nomor Rekam Medis: ${_selectedPatient!['medicalRecordNumber']}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildDetailItem(
                                            icon: Icons.badge,
                                            label: 'NIK',
                                            value: _selectedPatient!['nik'],
                                          ),
                                          _buildDetailItem(
                                            icon: Icons.cake,
                                            label: 'Umur',
                                            value:
                                                '${_calculateAge(_selectedPatient!['dob'])} Tahun',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildDetailItem(
                                            icon: Icons.wc,
                                            label: 'Jenis Kelamin',
                                            value: _selectedPatient!['gender'],
                                          ),
                                          _buildDetailItem(
                                            icon: Icons.calendar_today,
                                            label: 'Tanggal Lahir',
                                            value: _selectedPatient!['dob'],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailItem(
                                        icon: Icons.email,
                                        label: 'Email',
                                        value: _selectedPatient!['email'],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDetailItem(
                                        icon: Icons.phone,
                                        label: 'Nomor Telepon',
                                        value: _selectedPatient!['phone'],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDetailItem(
                                        icon: Icons.location_on,
                                        label: 'Alamat',
                                        value: _selectedPatient!['address'],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDetailItem(
                                        icon: Icons.location_city,
                                        label: 'Agama',
                                        value: _selectedPatient!['religion'],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDetailItem(
                                        icon: Icons.group,
                                        label: 'Suku',
                                        value: _selectedPatient!['suku'],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Pilih pasien untuk melihat detail',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
