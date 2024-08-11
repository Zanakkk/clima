// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';

class TreatmentsPage extends StatefulWidget {
  const TreatmentsPage({super.key});

  @override
  _TreatmentsPageState createState() => _TreatmentsPageState();
}

class _TreatmentsPageState extends State<TreatmentsPage> {
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _selectedPatient;
  List<Map<String, dynamic>> _tindakanData = [];
  Map<String, dynamic>? _selectedTindakan;
  String? _selectedProcedure;
  final TextEditingController _procedureExplanationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    final url = Uri.parse(
        '$URL/datapasien.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        final patients = data.entries
            .map<Map<String, dynamic>>(
                (entry) => {'id': entry.key, ...entry.value})
            .toList();

        setState(() {
          _patients = patients;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch patients.')),
      );
    }
  }

  Future<void> _fetchTindakanData() async {
    if (_selectedPatient == null) return;

    final url = Uri.parse(
        '$URL/tindakan.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        final tindakanData = data.entries
            .where(
                (entry) => entry.value['idpasien'] == _selectedPatient!['id'])
            .map<Map<String, dynamic>>(
                (entry) => {'id': entry.key, ...entry.value})
            .toList();

        setState(() {
          _tindakanData = tindakanData;
          _selectedTindakan =
              tindakanData.isNotEmpty ? tindakanData.first : null;
        });

        if (tindakanData.isEmpty) {
          await _createNewTindakanEntry();
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch tindakan data.')),
      );
    }
  }

  Future<void> _createNewTindakanEntry() async {
    if (_selectedPatient == null) return;

    final url = Uri.parse(
        '$URL/tindakan.json');

    final newTindakan = {
      'idpasien': _selectedPatient!['id'],
      'namapasien': _selectedPatient!['fullName'],
      'doctor': 'Drg. Amelia Putri', // Example doctor name, adjust as needed
      'timestamp': DateTime.now().toIso8601String(),
      'procedures': [],
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newTindakan),
    );

    if (response.statusCode == 200) {
      _fetchTindakanData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create tindakan entry.')),
      );
    }
  }

  Future<void> _addProcedure() async {
    if (_selectedPatient == null ||
        _selectedProcedure == null ||
        _selectedTindakan == null) return;

    final int price = _getProcedurePrice(_selectedProcedure!);
    final String explanation = _procedureExplanationController.text.trim();

    final updatedProcedures = [
      ...(_selectedTindakan!['procedures'] as List<dynamic>),
      {
        'procedure': _selectedProcedure,
        'price': price,
        'explanation': explanation.isNotEmpty ? explanation : null,
      },
    ];

    final url = Uri.parse(
        '$URL/tindakan/${_selectedTindakan!['id']}.json');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'procedures': updatedProcedures}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procedure added successfully.')),
      );
      _fetchTindakanData(); // Refresh the data
      _procedureExplanationController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add procedure.')),
      );
    }
  }

  int _getProcedurePrice(String procedure) {
    switch (procedure) {
      case 'Tambal':
        return 50000;
      case 'Scaling':
        return 100000;
      case 'Cabut':
        return 200000;
      default:
        return 0;
    }
  }

  double _calculateTotalCost() {
    if (_selectedTindakan == null || _selectedTindakan!['procedures'] == null) {
      return 0;
    }
    return (_selectedTindakan!['procedures'] as List<dynamic>)
        .map<double>((procedure) => (procedure['price'] as num).toDouble())
        .fold(0, (a, b) => a + b);
  }

  Future<void> _sendInvoice() async {
    if (_selectedPatient == null || _selectedTindakan == null) return;

    // Header
    String message = '🧾 *Invoice* 🧾\n\n';

    // Patient Information
    message += '👤 *Nama Pasien:* ${_selectedPatient!['fullName']}\n';
    message += '👨‍⚕️ *Dokter:* ${_selectedTindakan!['doctor']}\n';
    message += '📅 *Tanggal:* ${_selectedTindakan!['timestamp']}\n\n';

    // Procedures List
    message += '📝 *Detail Tindakan:*\n';
    for (var procedure in _selectedTindakan!['procedures']) {
      message +=
          '🔹 *${procedure['procedure']}*: Rp${procedure['price'].toString()}';
      if (procedure['explanation'] != null) {
        message += ' _(💬 Keterangan: ${procedure['explanation']})_';
      }
      message += '\n';
    }

    // Total Cost
    message +=
        '\n💵 *Total Biaya:* Rp${_calculateTotalCost().toStringAsFixed(0)}\n';

    // WhatsApp URI
    final Uri whatsappUri = Uri.parse(
        "https://wa.me/6282387696487?text=${Uri.encodeComponent(message)}");

    if (await canLaunch(whatsappUri.toString())) {
      await launch(whatsappUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatments Page'),
        centerTitle: true,
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: Row(
        children: [
          // Left Section: List of Patients
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return ListTile(
                  title: Text(patient['fullName']),
                  subtitle: Text('NIK: ${patient['nik']}'),
                  onTap: () {
                    setState(() {
                      _selectedPatient = patient;
                      _fetchTindakanData();
                    });
                  },
                  selected: _selectedPatient == patient,
                );
              },
            ),
          ),
          // Middle Section: Patient Details and Treatments
          Expanded(
            flex: 5,
            child: _selectedPatient != null && _selectedTindakan != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama: ${_selectedPatient!['fullName'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('NIK: ${_selectedPatient!['nik'] ?? ''}'),
                        const SizedBox(height: 8),
                        Text('Alamat: ${_selectedPatient!['address'] ?? ''}'),
                        const SizedBox(height: 8),
                        Text(
                            'Tanggal Lahir: ${_selectedPatient!['dob'] ?? ''}'),
                        const SizedBox(height: 8),
                        Text(
                            'Jenis Kelamin: ${_selectedPatient!['gender'] ?? ''}'),
                        const SizedBox(height: 8),
                        Text(
                            'Nomor Telepon: ${_selectedPatient!['phone'] ?? ''}'),
                        const SizedBox(height: 16),
                        const Text(
                          'Tindakan yang Sudah Dilakukan:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _tindakanData.length,
                            itemBuilder: (context, index) {
                              final tindakan = _tindakanData[index];
                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(
                                      'Dokter: ${tindakan['doctor']} - ${tindakan['timestamp']}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: (tindakan['procedures']
                                            as List<dynamic>)
                                        .map<Widget>((procedure) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${procedure['procedure']} - Rp${procedure['price']}'),
                                          if (procedure['explanation'] != null)
                                            Text(
                                              'Keterangan: ${procedure['explanation']}',
                                              style: const TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tambah Tindakan:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedProcedure,
                          hint: const Text('Pilih Tindakan'),
                          items:
                              ['Tambal', 'Scaling', 'Cabut'].map((procedure) {
                            return DropdownMenuItem<String>(
                              value: procedure,
                              child: Text(procedure),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProcedure = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _procedureExplanationController,
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
                            onPressed: _addProcedure,
                            child: const Text('Add Treatment'),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text('Pilih pasien untuk melihat detail'),
                  ),
          ),
// Right Section: Full Invoice
// Right Section: Full Invoice
          Expanded(
            flex: 3,
            child: _selectedPatient != null && _selectedTindakan != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Nama Pasien:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _selectedPatient!['fullName'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Dokter:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _selectedTindakan!['doctor'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tanggal:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _selectedTindakan!['timestamp'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            const Text(
                              'Detail Tindakan:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (_selectedTindakan!['procedures']
                                          as List<dynamic>)
                                      .map<Widget>((procedure) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  procedure['procedure'] ?? ''),
                                              Text(
                                                  'Rp${procedure['price'].toString()}'),
                                            ],
                                          ),
                                          if (procedure['explanation'] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2.0),
                                              child: Text(
                                                'Keterangan: ${procedure['explanation']}',
                                                style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp${_calculateTotalCost().toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _sendInvoice,
                                icon: const Icon(
                                  LineIcons.whatSApp,
                                  color: Colors.white,
                                ),
                                label: const Text('Send to WhatsApp'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                      0xFF25D366), // WhatsApp green color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Text('Pilih pasien untuk melihat invoice'),
                  ),
          )
        ],
      ),
    );
  }
}
