// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../main.dart';

class DaftarTindakanPasien extends StatefulWidget {
  const DaftarTindakanPasien({super.key});

  @override
  _DaftarTindakanPasienState createState() => _DaftarTindakanPasienState();
}

class _DaftarTindakanPasienState extends State<DaftarTindakanPasien> {
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  List<Map<String, dynamic>> _dentists = [];
  Map<String, dynamic>? _selectedPatient;
  Map<String, dynamic>? _selectedDentist;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _initializeDentists();
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
        '$URL/datapasien.json');

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

  void _initializeDentists() {
    _dentists = [
      {'name': 'Drg. Amelia Putri', 'sip': 'SIP-001'},
      {'name': 'Drg. Budi Santoso', 'sip': 'SIP-002'},
      {'name': 'Drg. Chandra Wijaya', 'sip': 'SIP-003'},
      {'name': 'Drg. Dita Arifin', 'sip': 'SIP-004'},
    ];
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

      if (_selectedPatient != null &&
          !_filteredPatients.contains(_selectedPatient)) {
        _selectedPatient = null;
      }
    });
  }

  Future<void> _postData() async {
    if (_selectedPatient == null || _selectedDentist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient and a dentist.')),
      );
      return;
    }

    final url = Uri.parse(
        '$URL/tindakan.json');

    final Map<String, dynamic> data = {
      'doctor': _selectedDentist!['name'],
      'idpasien': _selectedPatient!['id'],
      'namapasien': _selectedPatient!['fullName'],
      'timestamp': DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procedure successfully registered.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register procedure.')),
      );
    }
  }

  void _registerProcedure() {
    _postData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tindakan Pasien'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari & Pilih Pasien',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Map<String, dynamic>>(
              isExpanded: true,
              value: _selectedPatient,
              hint: const Text('Pilih pasien'),
              items: _filteredPatients.map((patient) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: patient,
                  child: Text(patient['fullName']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPatient = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Drg:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Map<String, dynamic>>(
              isExpanded: true,
              value: _selectedDentist,
              hint: const Text('Pilih drg'),
              items: _dentists.map((dentist) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: dentist,
                  child: Text('${dentist['name']} (SIP: ${dentist['sip']})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDentist = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _registerProcedure,
                child: const Text('Daftarkan Tindakan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
