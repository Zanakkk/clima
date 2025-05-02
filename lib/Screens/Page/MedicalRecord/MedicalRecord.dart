// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../HomePage.dart';
import 'OHI.dart';
import 'odontogram/odontogram.dart' show Odontogram;

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
    _fetchPatients(); // Memuat data pasien saat pertama kali aplikasi dibuka
  }

  // Fungsi untuk refresh data
  Future<void> refresh() async {
    await _fetchPatients();
    if (selectedPatientId.isNotEmpty) {
      await _fetchMedicalRecord(selectedPatientId);
    }
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
          Container(
            color: Colors.grey[100],
            width: 260, // Background yang lebih ringan
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daftar Pasien',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: refresh,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        child: ListTile(
                          title: Text(patients[index]['namapasien']),
                          subtitle:
                              Text('Dokter: ${patients[index]['doctor']}'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            setState(() {
                              selectedPatientId = patients[index]['idpasien'];
                              _fetchMedicalRecord(patients[index]['idpasien']);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Odontogram()));
                      }, child: const Text('Odontogram')),
                      ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OHI()));
                      }, child: const Text('OHI')),
                      ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OHIPage()));
                      }, child: const Text('OHI-PAGE')),
                    ],
                  ),
                  _buildRecordTable(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Align(
                alignment:
                    Alignment.centerRight, // Menempatkan form di kanan layar
                child: FractionallySizedBox(
                  widthFactor:
                      0.33, // Mengatur form menjadi sepertiga lebar layar
                  child: Material(
                    color: Colors.white, // Warna background form
                    elevation: 5,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: MedicalFormPage(
                        selectedPatientId: selectedPatientId), // Halaman form
                  ),
                ),
              );
            },
          );
        }, // Ikon tambah (+)
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecordTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTableHeader(),
              ...records.map((record) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildDataCell(record['no'], width: 50),
                        _buildDataCell(
                            '${record['tanggal']} ${record['waktu']}',
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
                    ),
                    const Divider(),
                  ],
                );
              }),
            ],
          ),
        ),
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

  Widget _buildDataCell(dynamic content, {required double width}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: width,
      child: content is String ? Text(content) : content,
    );
  }
}

class MedicalFormPage extends StatefulWidget {
  const MedicalFormPage({required this.selectedPatientId, super.key});

  final String selectedPatientId;
  @override
  State<MedicalFormPage> createState() => _MedicalFormPageState();
}

class _MedicalFormPageState extends State<MedicalFormPage> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final TextEditingController sController = TextEditingController();
  final TextEditingController oController = TextEditingController();
  final TextEditingController aController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  Map<String, dynamic>? _selectedDentist;
  List<Map<String, dynamic>> _dentists = [];
  String selectedPatientId = '';

  bool isLoading = false;
  bool hasError = false;

  List<Map<String, dynamic>> records = [];
  @override
  void initState() {
    super.initState();
    _fetchDentists(); // Mengambil data dokter dari API
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
    if (widget.selectedPatientId.isEmpty) return;

    final String timestamp = DateTime.now().toIso8601String();
    final signature = await _signatureController.toPngBytes();

    try {
      final response = await http.post(
        Uri.parse("$FULLURL/datapasien/${widget.selectedPatientId}/medicalrecord.json"),
        headers: {'Content-Type': 'application/json'},  // Pastikan header benar
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

      // Debugging response

      if (response.statusCode == 200) {
        _fetchMedicalRecord(widget.selectedPatientId); // Refresh the records
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      setState(() => hasError = true);
    }

    _clearFields();
  }


  Future<void> _fetchDentists() async {
    final url = Uri.parse('$FULLURL/dokter.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        final List<Map<String, dynamic>> dentists = [];
        data.forEach((id, dentistData) {
          dentists.add({
            'id': id,
            ...dentistData,
          });
        });
        setState(() {
          _dentists = dentists;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch dentists.')),
      );
    }
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
        title: const Text('Tambah Rekam Medis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            _buildTextField(controller: sController, label: 'S'),
            _buildTextField(controller: oController, label: 'O'),
            _buildTextField(controller: aController, label: 'A'),
            _buildTextField(
                controller: treatmentController, label: 'Treatment'),
            _buildTextField(controller: pController, label: 'P'),
            _buildTextField(
                controller: keteranganController, label: 'Keterangan'),
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
                  onPressed: () {
                    if (widget.selectedPatientId.isEmpty) {
                      return;
                    }

                    _addRecord();  // Panggil fungsi untuk post data
                    // Debugging selectedPatientId
                  },

                  child: const Text('Tambah Rekam Medis'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
