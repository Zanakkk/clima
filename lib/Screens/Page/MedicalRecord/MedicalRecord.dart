// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../HomePage.dart';
import 'OHI.dart';

class MedicalRecord extends StatefulWidget {
  const MedicalRecord({super.key});

  @override
  _MedicalRecordState createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  List<Map<String, dynamic>> records = [];
  List<Map<String, dynamic>> patients = [];
  String selectedPatientId = '';
  bool isLoading = false;
  bool hasError = false;
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

          // Jika ada pasien, pilih yang pertama secara default
          if (patients.isNotEmpty && selectedPatientId.isEmpty) {
            selectedPatientId = patients.first['id'];
            _fetchMedicalRecord(selectedPatientId);
          }
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
                'id': entry.key,
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
              final index = (entry.key + 1).toString();
              final record = entry.value;

              // Mengubah format tanggal dan waktu
              final DateTime dateTime = DateTime.parse(record['timestamp']);
              final String formattedDate = dateFormat.format(dateTime);
              final String formattedTime = timeFormat.format(dateTime);

              return {
                'id': record['id'],
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
              hasError = false;
              // Reset page controller to first page
              if (_pageController.hasClients) {
                _pageController.jumpToPage(0);
              }
              currentPage = 0;
            });
          } else {
            setState(() {
              records = [];
              selectedPatientId = patientId;
              hasError = false;
            });
          }
        } else {
          setState(() {
            records = [];
            selectedPatientId = patientId;
            hasError = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    setState(() => isLoading = true);

    try {
      final response = await http.delete(Uri.parse(
          "$FULLURL/datapasien/$selectedPatientId/medicalrecord/$recordId.json"));

      if (response.statusCode == 200) {
        // Sukses dihapus, refresh data
        await _fetchMedicalRecord(selectedPatientId);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan berhasil dihapus')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus catatan')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showDeleteConfirmation(String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord(recordId);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showPatientSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Pasien'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return ListTile(
                  title: Text(patient['namapasien']),
                  subtitle: Text('ID: ${patient['idpasien']}'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      selectedPatientId = patient['id'];
                      _fetchMedicalRecord(selectedPatientId);
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _openEditForm(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.33,
            child: Material(
              color: Colors.white,
              elevation: 5,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: MedicalFormPage(
                selectedPatientId: selectedPatientId,
                isEditing: true,
                recordId: record['id'],
                initialData: {
                  's': record['s'],
                  'o': record['o'],
                  'a': record['a'],
                  'p': record['p'],
                  'treatment': record['treatment'],
                  'keterangan': record['keterangan'],
                },
                onSuccess: () {
                  refresh();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patients.isNotEmpty && selectedPatientId.isNotEmpty
            ? 'Medical Record - ${patients.firstWhere((p) => p['id'] == selectedPatientId, orElse: () => {
                  'namapasien': 'Tidak ada'
                })['namapasien']}'
            : 'Medical Record'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showPatientSelector,
            tooltip: 'Pilih Pasien',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tombol navigasi antar modul
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Odontogram()));
                    },
                    child: const Text('Odontogram')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const OHI()));
                    },
                    child: const Text('OHI')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OHIPage()));
                    },
                    child: const Text('OHI-PAGE')),
              ],
            ),
          ),

          // Indikator halaman
          if (records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: currentPage > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                  Text('${currentPage + 1} / ${records.length}'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: currentPage < records.length - 1
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                ],
              ),
            ),

          // Loading indicator
          if (isLoading) const Center(child: CircularProgressIndicator()),

          // Error message
          if (hasError)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Terjadi kesalahan saat memuat data. Silakan coba lagi.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),

          // Empty state
          if (!isLoading && !hasError && records.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Belum ada catatan medis untuk pasien ini',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

          // Medical record book view
          if (!isLoading && !hasError && records.isNotEmpty)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return MedicalRecordPage(
                    record: record,
                    onEdit: () => _openEditForm(record),
                    onDelete: () => _showDeleteConfirmation(record['id']),
                  );
                },
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
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.33,
                  child: Material(
                    color: Colors.white,
                    elevation: 5,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: MedicalFormPage(
                      selectedPatientId: selectedPatientId,
                      onSuccess: () {
                        refresh();
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget khusus untuk menampilkan halaman catatan medis seperti buku
class MedicalRecordPage extends StatelessWidget {
  final Map<String, dynamic> record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicalRecordPage({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Efek binding buku di sisi kiri
          Container(
            width: 20,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
              ),
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Isi catatan medis
          Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 16.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan tanggal dan waktu
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom:
                          BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No. ${record['no']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${record['tanggal']} | ${record['waktu']}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: onEdit,
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: onDelete,
                            tooltip: 'Hapus',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Konten catatan medis
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('S (Subjektif)', record['s']),
                        _buildSection('O (Objektif)', record['o']),
                        _buildSection('A (Assessment)', record['a']),
                        _buildSection('P (Plan)', record['p']),
                        _buildSection('Treatment', record['treatment']),
                        _buildSection('Keterangan', record['keterangan']),

                        // Tanda tangan
                        if (record['urlTandaTangan'] != null &&
                            record['urlTandaTangan'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanda Tangan:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: Image.network(
                                      record['urlTandaTangan'],
                                      height: 80,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Text(
                                              'Tanda tangan tidak tersedia'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// Widget form untuk menambah atau mengedit catatan medis
class MedicalFormPage extends StatefulWidget {
  final String selectedPatientId;
  final bool isEditing;
  final String? recordId;
  final Map<String, dynamic>? initialData;
  final VoidCallback? onSuccess;

  const MedicalFormPage({
    super.key,
    required this.selectedPatientId,
    this.isEditing = false,
    this.recordId,
    this.initialData,
    this.onSuccess,
  });

  @override
  _MedicalFormPageState createState() => _MedicalFormPageState();
}

class _MedicalFormPageState extends State<MedicalFormPage> {
  final TextEditingController sController = TextEditingController();
  final TextEditingController oController = TextEditingController();
  final TextEditingController aController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  bool isLoading = false;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    // Inisialisasi data jika mode edit
    if (widget.isEditing && widget.initialData != null) {
      sController.text = widget.initialData!['s'] ?? '';
      oController.text = widget.initialData!['o'] ?? '';
      aController.text = widget.initialData!['a'] ?? '';
      pController.text = widget.initialData!['p'] ?? '';
      treatmentController.text = widget.initialData!['treatment'] ?? '';
      keteranganController.text = widget.initialData!['keterangan'] ?? '';
    }
  }

  @override
  void dispose() {
    sController.dispose();
    oController.dispose();
    aController.dispose();
    pController.dispose();
    treatmentController.dispose();
    keteranganController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (widget.selectedPatientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Silakan pilih pasien terlebih dahulu')));
      return;
    }

    setState(() => isLoading = true);

    try {
      // Convert tanda tangan menjadi PNG
      final signatureImage = await _signatureController.toPngBytes();
      String signatureUrl = '';

      // Upload tanda tangan (implementasi sesuai dengan backend Anda)
      // Ini hanya contoh dan perlu disesuaikan dengan cara upload file di aplikasi Anda
      // Untuk sederhananya, kita asumsikan ada endpoint API untuk upload file
      if (signatureImage != null) {
        // Upload logika di sini
        // signatureUrl = await uploadSignature(signatureImage);

        // Contoh sementara (mock)
        signatureUrl = 'https://example.com/signatures/signature.png';
      }

      final Map<String, dynamic> recordData = {
        'tanggal': DateTime.now().toIso8601String(),
        's': sController.text,
        'o': oController.text,
        'a': aController.text,
        'p': pController.text,
        'treatment': treatmentController.text,
        'keterangan': keteranganController.text,
        'urlTandaTangan': signatureUrl,
      };

      final Uri uri = widget.isEditing
          ? Uri.parse(
              "$FULLURL/datapasien/${widget.selectedPatientId}/medicalrecord/${widget.recordId}.json")
          : Uri.parse(
              "$FULLURL/datapasien/${widget.selectedPatientId}/medicalrecord.json");

      final http.Response response = widget.isEditing
          ? await http.put(uri, body: json.encode(recordData))
          : await http.post(uri, body: json.encode(recordData));

      if (response.statusCode == 200) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.isEditing
                ? 'Catatan berhasil diperbarui'
                : 'Catatan berhasil ditambahkan')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan catatan')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isEditing ? 'Edit Catatan Medis' : 'Tambah Catatan Medis'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form fields
              _buildTextField(sController, 'S (Subjektif)', 'Keluhan pasien'),
              _buildTextField(oController, 'O (Objektif)', 'Hasil pemeriksaan'),
              _buildTextField(
                  aController, 'A (Assessment)', 'Diagnosis/penilaian'),
              _buildTextField(pController, 'P (Plan)', 'Rencana perawatan'),
              _buildTextField(
                  treatmentController, 'Treatment', 'Tindakan yang dilakukan'),
              _buildTextField(
                  keteranganController, 'Keterangan', 'Catatan tambahan'),

              // Signature Pad
              const SizedBox(height: 16),
              const Text(
                'Tanda Tangan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _signatureController.clear(),
                    child: const Text('Clear'),
                  ),
                ],
              ),

              // Save button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.isEditing ? 'Update' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 3,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}

// Placeholder classes for navigasi antara modul
class Odontogram extends StatelessWidget {
  const Odontogram({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odontogram'),
      ),
      body: const Center(
        child: Text('Halaman Odontogram'),
      ),
    );
  }
}

class OHI extends StatelessWidget {
  const OHI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('OHI'),
        ),
        body: const Center(
          child: Text('Halaman OHI'),
        ));
  }
}
