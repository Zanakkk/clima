// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, avoid_print

import 'package:clima/Screens/Page/Receipt/Receipt.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import 'odontogram/odontogram.dart';

class MedicalRecord extends StatefulWidget {
  const MedicalRecord({required this.idpasien, super.key});

  final String idpasien;
  @override
  _MedicalRecordState createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> procedures = [];
  String selectedPatientId = '';
  bool isLoading = false;
  String patientName = '';
  String namadokter = '';

  @override
  void initState() {
    super.initState();
    print(widget.idpasien);
    _fetchPatientsForToday();
  }

  // Format timestamp to readable date

  // Format timestamp to readable time

  // Fetch patients for today
  Future<void> _fetchPatientsForToday() async {
    setState(() => isLoading = true);

    try {
      // Get today's date in YYYY-MM-DD format
      DateFormat('yyyy-MM-dd').format(DateTime.now());

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tindakan')
          .where('idpasien', isEqualTo: widget.idpasien)
          .get();

      final List<Map<String, dynamic>> fetchedPatients = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'idpasien': doc['idpasien'],
                'namapasien': doc['namapasien'],
                'doctor': doc['doctor'],
                'timestamp': doc['timestamp'],
              })
          .toList();

      fetchedPatients.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

      setState(() {
        patients = fetchedPatients;

        // Select first patient by default if available
        if (patients.isNotEmpty && selectedPatientId.isEmpty) {
          selectedPatientId = patients.first['idpasien'];
          patientName = patients.first['namapasien'];
          namadokter = patients.first['doctor'];
          _fetchProcedures(selectedPatientId);
        }
      });
    } catch (e) {
      _showErrorSnackbar('Error fetching patients: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Fetch procedures for a specific patient
  Future<void> _fetchProcedures(String patientId) async {
    setState(() => isLoading = true);

    try {
      // First, find all tindakan documents for this patient
      final QuerySnapshot tindakanSnapshot = await FirebaseFirestore.instance
          .collection('tindakan')
          .where('idpasien', isEqualTo: patientId)
          .get();

      List<Map<String, dynamic>> allProcedures = [];

      // For each tindakan document, fetch its procedures subcollection
      for (var tindakanDoc in tindakanSnapshot.docs) {
        final String tindakanId = tindakanDoc.id;

        final QuerySnapshot proceduresSnapshot = await FirebaseFirestore
            .instance
            .collection('tindakan')
            .doc(tindakanId)
            .collection('procedures')
            .get();

        // Map each procedure document to our format
        final procedures = proceduresSnapshot.docs.map((procedureDoc) {
          final data = procedureDoc.data() as Map<String, dynamic>;

          // Extract SOAP data safely
          Map<String, dynamic> soap = {};
          if (data.containsKey('soap') && data['soap'] is Map) {
            soap = data['soap'] as Map<String, dynamic>;
          }

          // Get signature from soap object if it exists there
          String signature = '';
          if (soap.containsKey('signature') && soap['signature'] != null) {
            signature = soap['signature'] as String;
          } else if (data.containsKey('signature') &&
              data['signature'] != null) {
            signature = data['signature'] as String;
          }

          String gigi = '';
          if (soap.containsKey('gigi') && soap['gigi'] != null) {
            gigi = soap['gigi'] as String;
          } else if (data.containsKey('gigi') && data['gigi'] != null) {
            gigi = data['gigi'] as String;
          }

          return {
            'id': procedureDoc.id,
            'tindakanId': tindakanId,
            'procedure': data['procedure'] ?? '',
            'explanation': data['explanation'] ?? '',
            'price': data['price'] ?? 0,
            'signature': signature, // Use the properly extracted signature
            'timestamp': data['timestamp'] ?? '',
            'gigi': gigi,
            'subjective': data['subjective'] ?? soap['subjective'] ?? '',
            'objective': data['objective'] ?? soap['objective'] ?? '',
            'assessment': data['assessment'] ?? soap['assessment'] ?? '',
            'plan': data['plan'] ?? soap['plan'] ?? '',
          };
        }).toList();

        allProcedures.addAll(procedures);
      }

      // Sort all procedures by timestamp (newest first)
      allProcedures.sort(
          (a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));

      setState(() {
        procedures = allProcedures;
      });
    } catch (e) {
      _showErrorSnackbar('Error fetching procedures: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Rekam Medis - ${patientName.isNotEmpty ? patientName : "Pasien"}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchPatientsForToday();
              if (selectedPatientId.isNotEmpty) {
                _fetchProcedures(selectedPatientId);
              }
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(LineIcons.pills),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ResepObat()));
            },
            tooltip: 'Resep Obat',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Odontogram()));
            },
            tooltip: 'Odontogram',
          ),
        ],
      ),
      body: Column(
        children: [
          // Patient Info Card
          if (patientName.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: $selectedPatientId',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${procedures.length} Rekam Medis',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Loading indicator
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Empty state message
          if (!isLoading && procedures.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_information_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada catatan medis untuk pasien ini',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Medical records column headers
          if (!isLoading && procedures.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Tanggal & Gigi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'SOAP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Tindakan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Tanda Tangan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Medical record list
          if (!isLoading && procedures.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: procedures.length,
                itemBuilder: (context, index) {
                  final procedure = procedures[index];
                  return MedicalRecordCard(
                    procedure: procedure,
                    index: index + 1,
                    dokter: namadokter,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class MedicalRecordCard extends StatelessWidget {
  final String dokter;
  final Map<String, dynamic> procedure;
  final int index;

  const MedicalRecordCard({
    super.key,
    required this.procedure,
    required this.index,
    required this.dokter,
  });

  @override
  Widget build(BuildContext context) {
    final Timestamp timestamp = procedure['timestamp'];
    final DateTime dateTime = timestamp.toDate();
    final String formattedDate = DateFormat('d MMMM yyyy').format(dateTime);
    final String formattedTime = DateFormat('HH:mm').format(dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Rekam Medis',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column 1: Date and Gigi
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnHeader('Tanggal'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildColumnHeader('Gigi'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            procedure['gigi'] ?? '-',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Column 2: SOAP
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnHeader('SOAP'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (procedure['subjective']?.isNotEmpty ?? false)
                                _buildSoapItem('S (Subjektif)',
                                    procedure['subjective'], Colors.green),
                              if (procedure['objective']?.isNotEmpty ?? false)
                                _buildSoapItem('O (Objektif)',
                                    procedure['objective'], Colors.blue),
                              if (procedure['assessment']?.isNotEmpty ?? false)
                                _buildSoapItem('A (Assessment)',
                                    procedure['assessment'], Colors.orange),
                              if (procedure['plan']?.isNotEmpty ?? false)
                                _buildSoapItem('P (Plan)', procedure['plan'],
                                    Colors.purple),
                              if (!_hasAnySoapData(procedure))
                                const Text('-', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Column 3: Procedure and Explanation
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnHeader('Tindakan'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (procedure['procedure']?.isNotEmpty ?? false)
                                _buildSoapItem('Prosedur',
                                    procedure['procedure'], Colors.red),
                              if (procedure['explanation']?.isNotEmpty ?? false)
                                _buildSoapItem('Penjelasan',
                                    procedure['explanation'], Colors.teal),
                              if ((procedure['procedure']?.isEmpty ?? true) &&
                                  (procedure['explanation']?.isEmpty ?? true))
                                const Text('-', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Column 4: Signature
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildColumnHeader('Tanda Tangan'),
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: procedure['signature']?.isNotEmpty ?? false
                              ? Image.memory(
                                  base64Decode(procedure['signature']),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Text('-')),
                                )
                              : const Center(child: Text('-')),
                        ),
                        const SizedBox(height: 8),
                        _buildColumnHeader('Dokter'),
                        const SizedBox(height: 8),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Text(dokter),
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
    );
  }

  bool _hasAnySoapData(Map<String, dynamic> procedure) {
    return (procedure['subjective']?.isNotEmpty ?? false) ||
        (procedure['objective']?.isNotEmpty ?? false) ||
        (procedure['assessment']?.isNotEmpty ?? false) ||
        (procedure['plan']?.isNotEmpty ?? false);
  }

  Widget _buildColumnHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSoapItem(String title, String content, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          if (title != 'P (Plan)' && title != 'Penjelasan')
            Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
