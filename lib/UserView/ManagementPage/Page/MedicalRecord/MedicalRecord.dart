// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
  late String selectedPatientId;
  bool isLoading = false;
  bool hasError = false;

  final String baseUrl =
      "https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/klinikdaffa4775";

  // Signature Controller
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _signatureController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse("$baseUrl/tindakan.json"));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          List<Map<String, dynamic>> fetchedPatients = [];
          String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

          data.forEach((key, value) {
            String timestamp = value['timestamp'];
            String date =
                timestamp.split('T')[0]; // Ambil tanggal dari timestamp

            // Filter hanya untuk data yang sesuai dengan hari ini
            if (date == today) {
              fetchedPatients.add({
                'id': key,
                'idpasien': value['idpasien'],
                'namapasien': value['namapasien'],
                'doctor': value['doctor'],
                'timestamp': timestamp,
              });
            }
          });

          // Urutkan berdasarkan timestamp secara ascending
          fetchedPatients.sort((a, b) {
            return a['timestamp'].compareTo(b['timestamp']);
          });

          setState(() {
            patients = fetchedPatients;
          });
        }
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMedicalRecord(String patientId) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http
          .get(Uri.parse("$baseUrl/datapasien/$patientId/medicalrecord.json"));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> fetchedRecords = [];

        data.forEach((key, value) {
          fetchedRecords.add({
            'no': value['no'],
            'tanggal': value['tanggal'],
            's': value['s'],
            'o': value['o'],
            'a': value['a'],
            'p': value['p'],
            'treatment': value['treatment'],
            'urlTandaTangan': value['urlTandaTangan'],
            'keterangan': value['keterangan'],
          });
        });

        setState(() {
          records = fetchedRecords;
          selectedPatientId = patientId;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addRecord() async {
    if (selectedPatientId.isEmpty) return;

    try {
      // Ambil nomor baru (increment dari nomor terakhir)
      final int newNo = records.isEmpty ? 1 : records.length + 1;

      // Ambil timestamp saat ini
      final String timestamp = DateTime.now().toIso8601String();

      // Simpan tanda tangan sebagai PNG bytes
      var signature = await _signatureController.toPngBytes();

      final response = await http.post(
        Uri.parse("$baseUrl/datapasien/$selectedPatientId/medicalrecord.json"),
        body: json.encode({
          'no': newNo.toString(),
          'tanggal': timestamp,
          's': sController.text,
          'o': oController.text,
          'a': aController.text,
          'p': pController.text,
          'treatment': treatmentController.text,
          'urlTandaTangan': signature != null
              ? base64Encode(signature)
              : null, // Simpan dalam format base64
          'keterangan': keteranganController.text,
        }),
      );

      if (response.statusCode == 200) {
        _fetchMedicalRecord(selectedPatientId);
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    }

    // Clear the text fields and signature after adding the record
    sController.clear();
    oController.clear();
    aController.clear();
    pController.clear();
    treatmentController.clear();
    keteranganController.clear();
    _signatureController.clear(); // Clear signature after saving
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
          appBar: AppBar(
            title: const Text('Medical Record'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
      body:Row(
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
                              subtitle:
                                  Text('Dokter: ${patients[index]['doctor']}'),
                              onTap: () {
                                _fetchMedicalRecord(
                                    patients[index]['idpasien']);
                              },
                            );
                          },
                        ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          _buildDataCell('No', width: 50),
                          _buildDataCell('Tanggal', width: 150),
                          _buildDataCell('S/O/A/P Tindakan', width: 320),
                          _buildDataCell('Perawatan', width: 200),
                          _buildDataCell('Tanda Tangan', width: 150),
                          _buildDataCell('Keterangan', width: 150),
                        ],
                      ),
                      // Data Rows
                      ...records.map((record) {
                        return Row(
                          children: [
                            _buildDataCell(record['no'], width: 50),
                            _buildDataCell(record['tanggal'], width: 150),
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
                                  ? Image.memory(base64Decode(
                                      record['urlTandaTangan'] ?? ''))
                                  : const Text(''),
                              width: 150,
                            ),
                            _buildDataCell(record['keterangan'], width: 150),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: sController,
                        decoration: const InputDecoration(labelText: 'S'),
                      ),
                      TextFormField(
                        controller: oController,
                        decoration: const InputDecoration(labelText: 'O'),
                      ),
                      TextFormField(
                        controller: aController,
                        decoration: const InputDecoration(labelText: 'A'),
                      ),
                      TextFormField(
                        controller: pController,
                        decoration: const InputDecoration(labelText: 'P'),
                      ),
                      TextFormField(
                        controller: treatmentController,
                        decoration:
                            const InputDecoration(labelText: 'Treatment'),
                      ),
                      TextFormField(
                        controller: keteranganController,
                        decoration:
                            const InputDecoration(labelText: 'Keterangan'),
                      ),
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
                            onPressed: () {
                              _signatureController.clear();
                            },
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

  Widget _buildDataCell(dynamic content, {required double width}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: width,
      child: content is String ? Text(content) : content,
    );
  }
}
