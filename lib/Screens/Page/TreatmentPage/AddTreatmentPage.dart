// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

import '../MedicalRecord/MedicalRecord.dart';

class AddTreatmentPage extends StatefulWidget {
  final Map<String, dynamic>? selectedPatient;
  final Map<String, dynamic>? selectedTindakan;
  final Map<String, dynamic>? selectedProcedure;
  final TextEditingController procedureExplanationController;
  final Function(Map<String, dynamic>?) onProcedureChanged;
  final Function onAddProcedure;

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
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for SOAP fields
  final TextEditingController _subjectiveController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _assessmentController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  @override
  void initState() {
    super.initState();
    _fetchProcedureList();
  }

  @override
  void dispose() {
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    super.dispose();
  }

  Future<void> _fetchProcedureList() async {
    try {
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching procedures: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('pricelist').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final procedures = snapshot.data?.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'name': data['name'] as String,
                'price': data['price'] as int,
              };
            }).toList() ??
            [];

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: widget.selectedPatient == null
              ? _buildEmptyState()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Patient information header
                        _buildPatientHeader(),
                        const SizedBox(height: 24),

                        // SOAP Form
                        _buildSOAPForm(),
                        const SizedBox(height: 24),
                        // Procedure dropdown
                        const Text(
                          'Add Procedure',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProcedureDropdown(procedures),
                        const SizedBox(height: 16),

                        // Explanation field
                        _buildExplanationField(),

                        const SizedBox(height: 24),
                        _buildSignatureSection(),

                        const SizedBox(height: 24),
                        // Submit button
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 24),
          Text(
            'Select a patient to add treatment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    int? calculateAge(String? dob) {
      if (dob == null) return null;
      try {
        final parts = dob.split('/');
        final birthDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final today = DateTime.now();
        int age = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        return age;
      } catch (e) {
        return null;
      }
    }

    final int? age = calculateAge(widget.selectedPatient?['dob']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedPatient?['fullName'] ?? 'No Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (widget.selectedPatient?['phoneNumber'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${widget.selectedPatient?['phoneNumber']}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (age != null || widget.selectedPatient?['address'] != null) ...[
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (age != null)
                      Chip(
                        backgroundColor: Colors.grey.shade100,
                        label: Text(
                          '$age years',
                          style: const TextStyle(fontSize: 13),
                        ),
                        avatar: const Icon(Icons.cake_outlined, size: 16),
                      ),
                    const SizedBox(width: 8),
                    if (widget.selectedPatient?['address'] != null)
                      Chip(
                        backgroundColor: Colors.grey.shade100,
                        label: Text(
                          widget.selectedPatient?['address'] ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        avatar: const Icon(Icons.home_outlined, size: 16),
                      ),
                  ],
                ),
                const SizedBox(
                  width: 24,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MedicalRecord()));
                    },
                    child: const Text('Medical Record'))
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcedureDropdown(List<Map<String, dynamic>> procedures) {
    // First check if the selected procedure still exists in the procedures list
    bool procedureExists = false;
    if (widget.selectedProcedure != null) {
      procedureExists = procedures
          .any((proc) => proc['id'] == widget.selectedProcedure!['id']);
      if (!procedureExists) {
        // If the selected procedure doesn't exist in the list, we need to handle this case
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onProcedureChanged(null);
        });
      }
    }

    return DropdownButtonFormField<String>(
      value: procedureExists ? widget.selectedProcedure!['id'] : null,
      decoration: InputDecoration(
        labelText: 'Select Procedure',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
      elevation: 2,
      onChanged: (String? selectedId) {
        if (selectedId != null) {
          // Find the full procedure object by ID
          Map<String, dynamic>? selectedProc;

          try {
            selectedProc = procedures.firstWhere(
              (proc) => proc['id'] == selectedId,
            );
          } catch (e) {
            // If not found, provide a default map directly
            selectedProc = {
              'id': selectedId,
              'name': 'Unknown',
              'price': 0,
            };
          }

          widget.onProcedureChanged(selectedProc);
        } else {
          widget.onProcedureChanged(null);
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a procedure';
        }
        return null;
      },
      items: procedures.map<DropdownMenuItem<String>>((procedure) {
        return DropdownMenuItem<String>(
          value: procedure['id'],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  procedure['name'],
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Rp ${procedure['price']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExplanationField() {
    return TextFormField(
      controller: widget.procedureExplanationController,
      decoration: InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional notes or explanations',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: const Icon(Icons.note_outlined),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSOAPForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medical Record (SOAP)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // S - Subjective
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'S/ Subjective',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectiveController,
                decoration: InputDecoration(
                  hintText: 'Enter patient complaints and symptoms',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // O - Objective
        Container(
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.science_outlined, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'O/ Objective',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _objectiveController,
                decoration: InputDecoration(
                  hintText: 'Enter examination findings and vital signs',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // A - Assessment
        Container(
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.assessment_outlined, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'A/ Assessment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _assessmentController,
                decoration: InputDecoration(
                  hintText: 'Enter diagnosis and assessment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Assessment is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // P - Plan
        Container(
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.list_alt_outlined, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(
                    'P/ Plan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _planController,
                decoration: InputDecoration(
                  hintText: 'Enter treatment plan and follow-up',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 1. First, let's enhance the signature area UI
  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doctor\'s Signature',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _signatureController.clear();
                      },
                      icon: const Icon(Icons.refresh, color: Colors.red),
                      label: const Text('Clear',
                          style: TextStyle(color: Colors.red)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: const Text(
                        'Sign above',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Uint8List?> _getSignatureBytes() async {
    if (_signatureController.isEmpty) {
      return null;
    }
    final image = await _signatureController.toPngBytes();
    return image;
  }

// 4. Update the submit button function to include signature data
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Check if signature is provided
            if (_signatureController.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please add your signature before submitting'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );

            try {
              // Get signature image bytes
              final signatureBytes = await _getSignatureBytes();

              // Prepare SOAP data with signature
              final soapData = {
                'subjective': _subjectiveController.text.trim(),
                'objective': _objectiveController.text.trim(),
                'assessment': _assessmentController.text.trim(),
                'plan': _planController.text.trim(),
                'signature': signatureBytes != null
                    ? base64Encode(signatureBytes)
                    : null,
                'timestamp': DateTime.now().toIso8601String(),
              };

              // Pass SOAP data to parent widget along with procedure data
              widget.onAddProcedure(soapData);

              _subjectiveController.clear();
              _objectiveController.clear();
              _assessmentController.clear();
              _planController.clear();
              _signatureController.clear();
            } catch (e) {
              // Close loading dialog
              Navigator.pop(context);
              print(e);
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline),
            SizedBox(width: 8),
            Text(
              'Add Procedure & Save SOAP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TindakanListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TindakanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Using a stream for real-time updates
        stream: _firestore
            .collection('tindakan')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorView(context, 'Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return _buildEmptyView(context);
          }

          return _buildTindakanList(context, snapshot.data!.docs);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add treatment page
          Navigator.pushNamed(context, '/add-treatment');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTindakanList(
      BuildContext context, List<QueryDocumentSnapshot> docs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLargeScreen
              ? _buildGridView(context, docs)
              : _buildListView(context, docs),
        );
      },
    );
  }

  Widget _buildGridView(
      BuildContext context, List<QueryDocumentSnapshot> docs) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        return _buildTindakanCard(context, data, docs[index].id);
      },
    );
  }

  Widget _buildListView(
      BuildContext context, List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildTindakanCard(context, data, docs[index].id),
        );
      },
    );
  }

  Widget _buildTindakanCard(
      BuildContext context, Map<String, dynamic> data, String docId) {
    // Parse timestamp
    DateTime createdAt;
    try {
      if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
        createdAt = (data['timestamp'] as Timestamp).toDate();
      } else if (data['createdAt'] != null && data['createdAt'] is String) {
        createdAt = DateTime.parse(data['createdAt']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(createdAt);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to detail page
          Navigator.pushNamed(
            context,
            '/tindakan-detail',
            arguments: {'docId': docId, 'data': data},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data['namapasien'] ?? 'Unnamed Patient',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Dokter: ${data['doctor'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      // Edit action
                      _editTindakan(context, docId, data);
                    },
                    tooltip: 'Edit',
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      // Delete action
                      _deleteTindakan(context, docId);
                    },
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Selesai',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada tindakan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan tindakan baru dengan menekan tombol +',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/add-treatment');
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Tindakan'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Refresh
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyegarkan data...')),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _editTindakan(
      BuildContext context, String docId, Map<String, dynamic> data) {
    // Navigate to edit page
    Navigator.pushNamed(
      context,
      '/edit-tindakan',
      arguments: {'docId': docId, 'data': data},
    );
  }

  void _deleteTindakan(BuildContext context, String docId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus tindakan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('tindakan').doc(docId).delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tindakan berhasil dihapus')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class TreatmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all patients from Firestore
  Future<List<Map<String, dynamic>>> getPatients() async {
    final QuerySnapshot snapshot = await _firestore.collection('pasien').get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'fullName': data['fullName'] ?? 'Unknown',
        'nik': data['nik'],
        'dob': data['dob'],
        'gender': data['gender'],
        'phone': data['phone'],
        'address': data['address'],
      };
    }).toList();
  }

  // Get stream of all treatments for real-time updates
  Stream<QuerySnapshot> getAllTreatmentsStream() {
    return _firestore
        .collection('tindakan')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Add a new treatment
  Future<bool> addTreatment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String procedureId,
    String? explanation,
  }) async {
    try {
      // Get the procedure details
      final procedureDoc =
          await _firestore.collection('pricelist').doc(procedureId).get();
      final procedureData = procedureDoc.data();

      if (procedureData == null) {
        return false;
      }

      // Create treatment record
      await _firestore.collection('tindakan').add({
        'patientId': patientId,
        'namapasien': patientName,
        'doctorId': doctorId,
        'doctor': doctorName,
        'procedureId': procedureId,
        'procedureName': procedureData['name'],
        'price': procedureData['price'],
        'explanation': explanation,
        'status': 'Selesai',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete a treatment
  Future<bool> deleteTreatment(String id) async {
    try {
      await _firestore.collection('tindakan').doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get a specific treatment by ID
  Future<Map<String, dynamic>?> getTreatmentById(String id) async {
    try {
      final doc = await _firestore.collection('tindakan').doc(id).get();
      if (!doc.exists) {
        return null;
      }
      final data = doc.data();
      return data;
    } catch (e) {
      return null;
    }
  }

  // Update a treatment
  Future<bool> updateTreatment(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('tindakan').doc(id).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all procedures (price list)
  Future<List<Map<String, dynamic>>> getAllProcedures() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('pricelist').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Procedure',
          'price': data['price'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
