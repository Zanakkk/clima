// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../main.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Map<String, dynamic> _data = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse(
        '$URL/.json'));
    if (response.statusCode == 200) {
      setState(() {
        _data = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('Summary Report'),
            _buildSummaryReport(),
            const SizedBox(height: 20),
            _buildSectionTitle('Inventory Report'),
            _buildInventoryReport(),
            const SizedBox(height: 20),
            _buildSectionTitle('Patient Report'),
            _buildPatientReport(),
            const SizedBox(height: 20),
            _buildSectionTitle('Procedures Report'),
            _buildProceduresReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSummaryReport() {
    int totalPatients = _data['datapasien']?.length ?? 0;
    int totalInventoryItems = _data['stokbarang']?.length ?? 0;
    int totalProcedures = _data['tindakan']?.length ?? 0;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryItem('Total Patients', totalPatients.toString()),
            _buildSummaryItem('Total Inventory Items', totalInventoryItems.toString()),
            _buildSummaryItem('Total Procedures', totalProcedures.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInventoryReport() {
    List<Widget> inventoryItems = [];
    if (_data['stokbarang'] != null) {
      _data['stokbarang'].forEach((key, value) {
        inventoryItems.add(
          ListTile(
            title: Text(value['name']),
            subtitle: Text('Category: ${value['category']} | Expiry: ${value['expiryDate']}'),
            trailing: Text('Qty: ${value['quantity']} ${value['unit']}'),
          ),
        );
      });
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: inventoryItems,
        ),
      ),
    );
  }

  Widget _buildPatientReport() {
    List<Widget> patientItems = [];
    if (_data['datapasien'] != null) {
      _data['datapasien'].forEach((key, value) {
        patientItems.add(
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(value['imageUrl']),
            ),
            title: Text(value['fullName']),
            subtitle: Text('NIK: ${value['nik']} | Phone: ${value['phone']}'),
          ),
        );
      });
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: patientItems,
        ),
      ),
    );
  }

  Widget _buildProceduresReport() {
    List<Widget> procedureItems = [];
    if (_data['tindakan'] != null) {
      _data['tindakan'].forEach((key, value) {
        int totalPrice = 0;
        List<Widget> procedures = [];
        for (var procedure in value['procedures']) {
          procedures.add(
            ListTile(
              title: Text(procedure['procedure']),
              subtitle: Text(procedure['explanation'] ?? ''),
              trailing: Text('Price: ${procedure['price']}'),
            ),
          );
          totalPrice += (procedure['price'] as num).toInt();  // Convert 'num' to 'int'
        }
        procedureItems.add(
          ExpansionTile(
            title: Text('${value['namapasien']} | Dr. ${value['doctor']}'),
            subtitle: Text('Total: $totalPrice'),
            children: procedures,
          ),
        );
      });
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: procedureItems,
        ),
      ),
    );
  }
}
