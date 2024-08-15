// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../HomePage.dart';

class AddTreatmentPage extends StatefulWidget {
  final Map<String, dynamic>? selectedPatient;
  final Map<String, dynamic>? selectedTindakan;
  final Map<String, dynamic>? selectedProcedure; // Changed to Map
  final TextEditingController procedureExplanationController;
  final Function(Map<String, dynamic>?) onProcedureChanged;
  final Function() onAddProcedure;

  const AddTreatmentPage({
    super.key,
    required this.selectedPatient,
    required this.selectedTindakan,
    required this.selectedProcedure,
    required this.procedureExplanationController,
    required this.onProcedureChanged,
    required this.onAddProcedure,
  });

  @override
  _AddTreatmentPageState createState() => _AddTreatmentPageState();
}

class _AddTreatmentPageState extends State<AddTreatmentPage> {
  List<Map<String, dynamic>> _procedures = [];

  @override
  void initState() {
    super.initState();
    _fetchProcedures();
  }

  // Fetch procedures from API
  Future<void> _fetchProcedures() async {
    final url = Uri.parse(
        '$FULLURL/pricelist.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        setState(() {
          // Mapping data dari API
          _procedures = data.entries
              .map<Map<String, dynamic>>((entry) => {
            'id': entry.key,
            'name': entry.value['name'] as String,
            'price': entry.value['price'] as int,
          })
              .toList();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch procedures.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPatient == null || widget.selectedTindakan == null) {
      return const Center(child: Text('Pilih pasien untuk melihat detail'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama: ${widget.selectedPatient!['fullName'] ?? ''}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('NIK: ${widget.selectedPatient!['nik'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Alamat: ${widget.selectedPatient!['address'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Tanggal Lahir: ${widget.selectedPatient!['dob'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Jenis Kelamin: ${widget.selectedPatient!['gender'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Nomor Telepon: ${widget.selectedPatient!['phone'] ?? ''}'),
          const SizedBox(height: 16),
          const Text(
            'Tambah Tindakan:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _procedures.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<Map<String, dynamic>>(
            isExpanded: true,
            value: widget.selectedProcedure,
            hint: const Text('Pilih Tindakan'),
            items: _procedures.map((procedure) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: procedure,
                child: Text(procedure['name']),
              );
            }).toList(),
            onChanged: widget.onProcedureChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: widget.procedureExplanationController,
            decoration: InputDecoration(
              labelText: 'Keterangan (opsional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: widget.onAddProcedure,
              child: const Text('Add Treatment'),
            ),
          ),
        ],
      ),
    );
  }
}
