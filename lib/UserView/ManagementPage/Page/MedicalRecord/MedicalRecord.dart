// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../HomePage.dart';

class MedicalRecord extends StatefulWidget {
  const MedicalRecord({super.key});

  @override
  _MedicalRecordState createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  final TextEditingController sController = TextEditingController();
  final TextEditingController oController = TextEditingController();
  final TextEditingController aController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  List<Map<String, dynamic>> records = [];
  List<Map<String, dynamic>> patients = [];
  String selectedPatientId = '';
  bool isLoading = false;
  bool hasError = false;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    sController.dispose();
    oController.dispose();
    aController.dispose();
    pController.dispose();
    treatmentController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse("$FULLURL/tindakan.json"));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

        final fetchedPatients = data.entries
            .where((entry) => entry.value['timestamp'].split('T')[0] == today)
            .map((entry) {
          return {
            'id': entry.key,
            'idpasien': entry.value['idpasien'],
            'namapasien': entry.value['namapasien'],
            'doctor': entry.value['doctor'],
            'timestamp': entry.value['timestamp'],
          };
        }).toList();

        fetchedPatients
            .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        setState(() {
          patients = fetchedPatients;
          hasError = false;
        });
      }
    } catch (e) {
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchMedicalRecord(String patientId) async {
    setState(() => isLoading = true);

    try {
      final response = await http
          .get(Uri.parse("$FULLURL/datapasien/$patientId/medicalrecord.json"));

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data.isNotEmpty) {
            // Memetakan setiap entry ke dalam list records
            final List<Map<String, dynamic>> fetchedRecords =
                data.entries.map((entry) {
              final procedureData = entry.value as Map<String, dynamic>;

              return {
                'timestamp': procedureData['tanggal'],
                's': procedureData['s'],
                'o': procedureData['o'],
                'a': procedureData['a'],
                'p': procedureData['p'],
                'treatment': procedureData['treatment'],
                'keterangan': procedureData['keterangan'],
                'urlTandaTangan': procedureData['urlTandaTangan'],
              };
            }).toList();

            // Urutkan berdasarkan timestamp
            fetchedRecords
                .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

            // Format tanggal dan waktu
            final DateFormat dateFormat = DateFormat('d MMMM yyyy');
            final DateFormat timeFormat = DateFormat('HH : mm');

            // Tambahkan nomor urut
            final List<Map<String, dynamic>> numberedRecords =
                fetchedRecords.asMap().entries.map((entry) {
              final index = (entry.key + 1)
                  .toString(); // Menambahkan 1 agar mulai dari 1, bukan 0
              final record = entry.value;

              // Mengubah format tanggal dan waktu
              final DateTime dateTime = DateTime.parse(record['timestamp']);
              final String formattedDate = dateFormat.format(dateTime);
              final String formattedTime = timeFormat.format(dateTime);

              return {
                'no': index,
                'tanggal': formattedDate,
                'waktu': formattedTime,
                's': record['s'],
                'o': record['o'],
                'a': record['a'],
                'p': record['p'],
                'treatment': record['treatment'],
                'keterangan': record['keterangan'],
                'urlTandaTangan': record['urlTandaTangan'],
              };
            }).toList();

            setState(() {
              records = numberedRecords;
              selectedPatientId = patientId;
              hasError = false; // Tidak ada error karena data valid
            });
          } else {
            // Data kosong, kosongkan records
            setState(() {
              records = [];
              selectedPatientId = patientId;
              hasError = false; // Tidak ada data, tapi bukan error
            });
          }
        } else {
          // Jika respons kosong, kosongkan records
          setState(() {
            records = [];
            selectedPatientId = patientId;
            hasError = false; // Respons kosong, bukan error
          });
        }
      } else {
        // Jika status bukan 200, anggap sebagai error
        setState(() {
          hasError = true;
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addRecord() async {
    if (selectedPatientId.isEmpty) return;

    final String timestamp = DateTime.now().toIso8601String();
    final signature = await _signatureController.toPngBytes();

    try {
      final response = await http.post(
        Uri.parse("$FULLURL/datapasien/$selectedPatientId/medicalrecord.json"),
        body: json.encode({
          'tanggal': timestamp,
          's': sController.text,
          'o': oController.text,
          'a': aController.text,
          'p': pController.text,
          'treatment': treatmentController.text,
          'urlTandaTangan': signature != null ? base64Encode(signature) : null,
          'keterangan': keteranganController.text,
        }),
      );

      if (response.statusCode == 200) {
        _fetchMedicalRecord(selectedPatientId); // Refresh the records
      }
    } catch (e) {
      setState(() => hasError = true);
    }

    _clearFields();
  }

  void _clearFields() {
    sController.clear();
    oController.clear();
    aController.clear();
    pController.clear();
    treatmentController.clear();
    keteranganController.clear();
    _signatureController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Medical Record'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Row(
          children: [
            SizedBox(
              width: 240,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(child: Text("Gagal memuat data."))
                      : patients.isEmpty
                          ? const Center(child: Text("Tidak ada data pasien."))
                          : ListView.builder(
                              itemCount: patients.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(patients[index]['namapasien']),
                                  subtitle: Text(
                                      'Dokter: ${patients[index]['doctor']}'),
                                  onTap: () {
                                    setState(() {
                                      selectedPatientId =
                                          patients[index]['idpasien'];

                                      _fetchMedicalRecord(
                                          patients[index]['idpasien']);
                                    });
                                  },
                                );
                              },
                            ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildRecordTable(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildTextField(controller: sController, label: 'S'),
                          _buildTextField(controller: oController, label: 'O'),
                          _buildTextField(controller: aController, label: 'A'),
                          _buildTextField(controller: pController, label: 'P'),
                          _buildTextField(
                              controller: treatmentController,
                              label: 'Treatment'),
                          _buildTextField(
                              controller: keteranganController,
                              label: 'Keterangan'),
                          const SizedBox(height: 20),
                          const Text("Tanda Tangan:"),
                          Signature(
                            controller: _signatureController,
                            height: 300,
                            width: 300,
                            backgroundColor: Colors.grey[200]!,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: _signatureController.clear,
                                child: const Text("Hapus Tanda Tangan"),
                              ),
                              ElevatedButton(
                                onPressed: _addRecord,
                                child: const Text('Tambah Rekam Medis'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildRecordTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(),
          ...records.map((record) {
            return Row(
              children: [
                _buildDataCell(record['no'], width: 50),
                _buildDataCell('${record['tanggal']} ${record['waktu']}',
                    width: 150),
                _buildDataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('S: ${record['s']}'),
                      Text('O: ${record['o']}'),
                      Text('A: ${record['a']}'),
                      Text('P: ${record['p']}'),
                    ],
                  ),
                  width: 320,
                ),
                _buildDataCell(record['treatment'], width: 200),
                _buildDataCell(
                  record['urlTandaTangan'] != null
                      ? Image.memory(
                          base64Decode(record['urlTandaTangan'] ?? ''))
                      : const Text(''),
                  width: 150,
                ),
                _buildDataCell(record['keterangan'], width: 150),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        _buildDataCell('No', width: 50),
        _buildDataCell('Tanggal', width: 150),
        _buildDataCell('S/O/A/P Tindakan', width: 320),
        _buildDataCell('Perawatan', width: 200),
        _buildDataCell('Tanda Tangan', width: 150),
        _buildDataCell('Keterangan', width: 150),
      ],
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildDataCell(dynamic content, {required double width}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: width,
      child: content is String ? Text(content) : content,
    );
  }
}
