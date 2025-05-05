// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use, empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AddTreatmentPage.dart';
import 'InvoicePage.dart';
import 'PasienListPage.dart';

class TreatmentsPage extends StatefulWidget {
  const TreatmentsPage({super.key});

  @override
  _TreatmentsPageState createState() => _TreatmentsPageState();
}

class _TreatmentsPageState extends State<TreatmentsPage> {
  Map<String, dynamic>? _selectedPatient;
  Map<String, dynamic>? _selectedTindakan;
  Map<String, dynamic>? _selectedProcedure;
  final TextEditingController _procedureExplanationController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  late final CollectionReference _patientsCollection;
  late final CollectionReference _tindakanCollection;

  @override
  void initState() {
    super.initState();
    _patientsCollection = _firestore.collection('pasien');
    _tindakanCollection = _firestore.collection('tindakan');
  }

  // Add procedure to tindakan
  Future<void> _addProcedure(Map<String, dynamic> soapData) async {
    if (_selectedPatient == null ||
        _selectedProcedure == null ||
        _selectedTindakan == null) {
      return;
    }

    final int price = _selectedProcedure!['price'];
    final String explanation = _procedureExplanationController.text.trim();

    // Create new procedure document
    final newProcedure = {
      'procedure': _selectedProcedure!['name'],
      'price': price,
      'explanation': explanation.isNotEmpty ? explanation : null,
      'timestamp': FieldValue.serverTimestamp(),
      // Add the SOAP data fields
      'soap': soapData,
    };

    try {
      // Add procedure as a subcollection document
      await _tindakanCollection
          .doc(_selectedTindakan!['id'])
          .collection('procedures')
          .add(newProcedure);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Procedure added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _procedureExplanationController.clear();

      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add procedure: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


// Fungsi untuk mengirim invoice
  Future<void> _sendInvoice() async {
    if (_selectedPatient == null || _selectedTindakan == null) return;

    try {
      final String tindakanId = _selectedTindakan!['id'];
      final tindakanSnapshot = await _tindakanCollection.doc(tindakanId).get();
      final tindakanData = tindakanSnapshot.data() as Map<String, dynamic>? ?? {};

      // Get doctor name from the tindakan document
      final doctorName = tindakanData['doctor'] ?? 'Tidak Diketahui';

      // Get patient ID from the tindakan document
      final patientId = tindakanData['idpasien'] as String?;

      if (patientId == null) {
        throw Exception('ID pasien tidak ditemukan pada tindakan');
      }

      // Get the patient's phone number from the patients collection
      final patientSnapshot = await FirebaseFirestore.instance
          .collection('pasien')
          .doc(patientId)
          .get();

      if (!patientSnapshot.exists) {
        throw Exception('Data pasien tidak ditemukan');
      }

      final patientData = patientSnapshot.data() as Map<String, dynamic>;
      final patientPhone = patientData['phone'] as String?;

      if (patientPhone == null || patientPhone.isEmpty) {
        throw Exception('Nomor telepon pasien tidak tersedia');
      }

      // Format phone number for WhatsApp - ensure it starts with country code
      String whatsappNumber = patientPhone;
      if (whatsappNumber.startsWith('0')) {
        whatsappNumber = '62${whatsappNumber.substring(1)}';
      } else if (!whatsappNumber.startsWith('62')) {
        whatsappNumber = '62$whatsappNumber';
      }

      final proceduresSnapshot = await _tindakanCollection
          .doc(tindakanId)
          .collection('procedures')
          .get();

      if (proceduresSnapshot.docs.isNotEmpty) {
        // Get current user's clinic information
        final user = FirebaseAuth.instance.currentUser;
        final userEmail = user?.email;

        String clinicName = 'Klinik Gigi';
        String clinicAddress = 'Alamat tidak tersedia';
        String clinicPhone = '';

        if (userEmail != null) {
          // Query 'clinics' collection to find document with matching email
          final clinicsSnapshot = await FirebaseFirestore.instance
              .collection('clinics')
              .where('email', isEqualTo: userEmail)
              .limit(1)
              .get();

          if (clinicsSnapshot.docs.isNotEmpty) {
            final clinicData = clinicsSnapshot.docs.first.data();
            clinicName = clinicData['name'] ?? clinicName;
            clinicAddress = clinicData['address'] ?? clinicAddress;
            clinicPhone = clinicData['phone'] ?? '';
          }
        }

        // Generate invoice number using timestamp
        final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

        // Build invoice message
        String message = '*${clinicName.toUpperCase()}*\n';
        message += '*INVOICE* #$invoiceNumber\n';
        message += '------------------------------\n\n';

        // Format Date and Time
        final DateTime now = DateTime.now();
        final String formattedDate = _formatDate(now);
        final String formattedTime = _formatTime(now);

        // Invoice and patient information
        message += 'Tanggal: $formattedDate\n';
        message += 'Waktu: $formattedTime\n';
        message += 'Pasien: ${_selectedPatient!['fullName']}\n';
        message += 'Dokter: $doctorName\n\n';

        // Treatment details header
        message += '*RINCIAN TINDAKAN*\n';
        message += '------------------------------\n';

        double totalCost = 0.0;

        // List treatments with formatted prices
        for (var doc in proceduresSnapshot.docs) {
          final procedureData = doc.data();
          final procedureName = procedureData['procedure'] ?? 'Tidak Diketahui';
          final price = procedureData['price'] ?? 0;
          final explanation = procedureData['explanation'] ?? '';

          // Format price with thousand separators
          final formattedPrice = _formatCurrency(price);

          message += '• $procedureName: Rp $formattedPrice\n';
          if (explanation.isNotEmpty) {
            message += '  Keterangan: $explanation\n';
          }

          totalCost += price.toDouble();
        }

        // Total Cost with formatting
        message += '------------------------------\n';
        message += '*Total:* Rp ${_formatCurrency(totalCost.toInt())}\n\n';

        // Thank you note
        message += 'Terima kasih atas kunjungan Anda.\n';
        if (clinicPhone.isNotEmpty) {
          message += 'Untuk informasi lebih lanjut, silakan hubungi kami di $clinicPhone.\n\n';
        } else {
          message += 'Untuk informasi lebih lanjut, silakan hubungi kami.\n\n';
        }
        message += 'Semoga lekas sembuh!\n';
        message += '------------------------------\n';
        message += '*$clinicName*\n';
        message += '$clinicAddress\n';
        message += 'www.CLIMA.co.id';

        // WhatsApp URI
        final Uri whatsappUri = Uri.parse(
            "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}");

        if (await canLaunch(whatsappUri.toString())) {
          await launch(whatsappUri.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka WhatsApp'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada prosedur yang ditemukan untuk pasien ini'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat mengirim invoice: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


// Helper function to format currency with thousand separators
  String _formatCurrency(int amount) {
    // Convert the number to string and split by thousands
    final String amountStr = amount.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < amountStr.length; i++) {
      if (i > 0 && (amountStr.length - i) % 3 == 0) {
        result.write('.');
      }
      result.write(amountStr[i]);
    }

    return result.toString();
  }

// Format date to Indonesian format (e.g., "05 Mei 2025")
  String _formatDate(DateTime date) {
    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

// Format time (e.g., "14:59")
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Helper function to format date in '16 Agustus 2024' format

  Future<void> _fetchTindakanData() async {
    if (_selectedPatient == null) return;

    try {
      final querySnapshot = await _tindakanCollection
          .where('idpasien', isEqualTo: _selectedPatient!['id'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final tindakanDoc = querySnapshot.docs.first;
        setState(() {
          _selectedTindakan = {
            'id': tindakanDoc.id,
            ...tindakanDoc.data() as Map<String, dynamic>
          };
        });
      } else {
        setState(() {
          _selectedTindakan = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching tindakan data: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Stream for today's patients
  Stream<List<Map<String, dynamic>>> _getTodayPatientsStream() {
    final now = DateTime.now();
    DateFormat('yyyy-MM-dd').format(now);

    // Start of day and end of day
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _tindakanCollection
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .asyncMap((tindakanSnapshot) async {
      final List<Map<String, dynamic>> patients = [];

      for (var tindakanDoc in tindakanSnapshot.docs) {
        final tindakanData = tindakanDoc.data() as Map<String, dynamic>;
        final idpasien = tindakanData['idpasien'];

        // Get patient data
        try {
          final patientDoc = await _patientsCollection.doc(idpasien).get();
          if (patientDoc.exists) {
            patients.add(
                {'id': idpasien, ...patientDoc.data() as Map<String, dynamic>});
          }
        } catch (e) {}
      }

      return patients;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MediaQuery.of(context).size.width < 600
          ? _buildMobileLayout()
          : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient List - Left Panel
          Expanded(
            flex: 2,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getTodayPatientsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final patients = snapshot.data ?? [];

                  return PasienListPage(
                    patients: patients,
                    onPatientSelected: (patient) {
                      setState(() {
                        _selectedPatient = patient;
                        _fetchTindakanData();
                      });
                    },
                    selectedPatient: _selectedPatient,
                    onRefresh: () async {}, // Not needed with StreamBuilder
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Treatment Form - Middle Panel
          Expanded(
            flex: 5,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: AddTreatmentPage(
                selectedPatient: _selectedPatient,
                selectedTindakan: _selectedTindakan,
                selectedProcedure: _selectedProcedure,
                procedureExplanationController: _procedureExplanationController,
                onProcedureChanged: (Map<String, dynamic>? procedure) {
                  setState(() {
                    _selectedProcedure = procedure;
                  });
                },
                onAddProcedure: _addProcedure,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Invoice - Right Panel
          Expanded(
            flex: 3,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedTindakan != null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: _tindakanCollection
                          .doc(_selectedTindakan!['id'])
                          .collection('procedures')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return InvoicePage(
                          selectedPatient: _selectedPatient,
                          selectedTindakan: _selectedTindakan,
                          procedures: snapshot.data?.docs
                                  .map((doc) => {
                                        'id': doc.id,
                                        ...doc.data() as Map<String, dynamic>
                                      })
                                  .toList() ??
                              [],
                          onSendInvoice: _sendInvoice,
                          formatCurrency: formatCurrency,
                        );
                      },
                    )
                  : InvoicePage(
                      selectedPatient: _selectedPatient,
                      selectedTindakan: _selectedTindakan,
                      procedures: const [],
                      onSendInvoice: _sendInvoice,
                      formatCurrency: formatCurrency,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.people), text: 'Patients'),
                Tab(icon: Icon(Icons.medical_services), text: 'Treatment'),
                Tab(icon: Icon(Icons.receipt), text: 'Invoice'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Patients Tab
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _getTodayPatientsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final patients = snapshot.data ?? [];

                      return PasienListPage(
                        patients: patients,
                        onPatientSelected: (patient) {
                          setState(() {
                            _selectedPatient = patient;
                            _fetchTindakanData();
                          });
                        },
                        selectedPatient: _selectedPatient,
                        onRefresh: () async {}, // Not needed with StreamBuilder
                      );
                    },
                  ),
                ),

                // Treatment Tab
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AddTreatmentPage(
                    selectedPatient: _selectedPatient,
                    selectedTindakan: _selectedTindakan,
                    selectedProcedure: _selectedProcedure,
                    procedureExplanationController:
                        _procedureExplanationController,
                    onProcedureChanged: (Map<String, dynamic>? procedure) {
                      setState(() {
                        _selectedProcedure = procedure;
                      });
                    },
                    onAddProcedure: _addProcedure,
                  ),
                ),

                // Invoice Tab
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedTindakan != null
                      ? StreamBuilder<QuerySnapshot>(
                          stream: _tindakanCollection
                              .doc(_selectedTindakan!['id'])
                              .collection('procedures')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            return InvoicePage(
                              selectedPatient: _selectedPatient,
                              selectedTindakan: _selectedTindakan,
                              procedures: snapshot.data?.docs
                                      .map((doc) => {
                                            'id': doc.id,
                                            ...doc.data()
                                                as Map<String, dynamic>
                                          })
                                      .toList() ??
                                  [],
                              onSendInvoice: _sendInvoice,
                              formatCurrency: formatCurrency,
                            );
                          },
                        )
                      : InvoicePage(
                          selectedPatient: _selectedPatient,
                          selectedTindakan: _selectedTindakan,
                          procedures: const [],
                          onSendInvoice: _sendInvoice,
                          formatCurrency: formatCurrency,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String formatCurrency(double amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}
