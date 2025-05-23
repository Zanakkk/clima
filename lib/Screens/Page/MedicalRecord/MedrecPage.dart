// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'MedicalRecord.dart';

class MedRecPage extends StatefulWidget {
  const MedRecPage({super.key});

  @override
  State<MedRecPage> createState() => _MedRecPageState();
}

class _MedRecPageState extends State<MedRecPage> {
  Map<String, dynamic>? _selectedPatient;
  final TextEditingController _procedureExplanationController =
      TextEditingController();

  // Firebase instances - cached for reuse
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references - cached for reuse
  late final CollectionReference _patientsCollection;
  late final CollectionReference _clinicsCollection;

  // Cached clinic data
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _patientsCollection = _firestore.collection('pasien');
    _clinicsCollection = _firestore.collection('clinics');
    _fetchClinicData(); // Pre-fetch clinic data on init
  }

  @override
  void dispose() {
    _procedureExplanationController.dispose();
    super.dispose();
  }

  // Pre-fetch clinic data once to avoid repeated queries
  Future<void> _fetchClinicData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user?.email != null) {
        final clinicsSnapshot = await _clinicsCollection
            .where('email', isEqualTo: user!.email)
            .limit(1)
            .get();

        if (clinicsSnapshot.docs.isNotEmpty) {}
      }
    } catch (e) {
      debugPrint('Error fetching clinic data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Improved stream for getting patients with error handling
  Stream<List<Map<String, dynamic>>> _getAllPatientsStream() {
    try {
      return _patientsCollection.snapshots().map((snapshot) {
        final patients = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        }).toList();

        // Cache the patients for use elsewhere
        return patients;
      }).handleError((error) {
        debugPrint('Error in patient stream: $error');
        return <Map<String, dynamic>>[];
      });
    } catch (e) {
      debugPrint('Error setting up patient stream: $e');
      // Return an empty stream in case of error
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  // Refreshes the data (can be called from child widgets)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : MediaQuery.of(context).size.width < 600
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
                stream: _getAllPatientsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final patients = snapshot.data ?? [];

                  return _buildPatientList(patients);
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Medical Record Panel - Right Panel
          Expanded(
            flex: 5,
            child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedPatient != null
                    ? MedicalRecord(
                        key: ValueKey(_selectedPatient![
                            'id']), // Force rebuild when patient changes
                        idpasien: _selectedPatient!['id'],
                      )
                    : const Center(
                        child:
                            Text('Select a patient to view medical record'))),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.people), text: 'Patients'),
                Tab(icon: Icon(Icons.medical_services), text: 'Medical Record'),
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
                    stream: _getAllPatientsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final patients = snapshot.data ?? [];

                      return _buildPatientList(
                        patients,
                        onPatientTap: (patient) {
                          // Auto-navigate to medical record tab when patient is selected on mobile
                          DefaultTabController.of(context).animateTo(1);
                        },
                      );
                    },
                  ),
                ),

                // Medical Record Tab
                Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedPatient != null
                      ? MedicalRecord(
                          key: ValueKey(_selectedPatient![
                              'id']), // Force rebuild when patient changes
                          idpasien: _selectedPatient!['id'],
                        )
                      : const Center(
                          child:
                              Text('Select a patient to view medical record')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Unified patient list builder for both mobile and desktop
  Widget _buildPatientList(List<Map<String, dynamic>> patients,
      {Function(Map<String, dynamic>)? onPatientTap}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Daftar Pasien',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          patients.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada data',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      final isSelected = _selectedPatient != null &&
                          _selectedPatient!['id'] == patient['id'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isSelected ? 4 : 1,
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color:
                                isSelected ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPatient = patient;
                            });
                            if (onPatientTap != null) {
                              onPatientTap(patient);
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient['fullName'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_outlined,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      patient['phone'] ?? 'No Phone',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                if (patient['age'] != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${patient['age']} years',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
