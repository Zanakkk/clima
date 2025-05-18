// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/Validator.dart';

class DaftarDoktor extends StatefulWidget {
  const DaftarDoktor({super.key});

  @override
  _DaftarDoktorState createState() => _DaftarDoktorState();
}

class _DaftarDoktorState extends State<DaftarDoktor> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _doctors = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bidangController = TextEditingController();
  final TextEditingController _sipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bidangController.dispose();
    _sipController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    try {
      final QuerySnapshot snapshot =
      await _firestore.collection('dokter').get();

      setState(() {
        _doctors = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'bidang': data['bidang'] ?? '',
            'sip': data['sip'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      _showSnackBar('Gagal memuat data dokter: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addDoctor() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        // Buat dokumen baru
        await _firestore.collection('dokter').doc().set({
          'name': _nameController.text.trim(),
          'bidang': _bidangController.text.trim(),
          'sip': _sipController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        _showSnackBar('Dokter berhasil ditambahkan', isError: false);
        _resetForm();
        _fetchDoctors();
      } catch (e) {
        _showSnackBar('Gagal menambahkan dokter: ${e.toString()}');
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteDoctor(String doctorId) async {
    try {
      await _firestore.collection('dokter').doc(doctorId).delete();
      _showSnackBar('Dokter berhasil dihapus', isError: false);
      _fetchDoctors();
    } catch (e) {
      _showSnackBar('Gagal menghapus dokter: ${e.toString()}');
    }
  }

  void _resetForm() {
    _nameController.clear();
    _bidangController.clear();
    _sipController.clear();
    _formKey.currentState?.reset();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDoctorDialog(),
        tooltip: 'Tambah Dokter',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      final isWideScreen = constraints.maxWidth > 600;

      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isWideScreen ? 800 : constraints.maxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Dokter Gigi',
                      style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daftar semua dokter gigi yang terdaftar di sistem',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _doctors.isEmpty
                    ? _buildEmptyDoctorsList()
                    : _buildDoctorsList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyDoctorsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada dokter yang terdaftar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Tambah Dokter'),
            onPressed: () => _showAddDoctorDialog(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doctor = _doctors[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['name'] ?? 'Nama tidak tersedia',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            doctor['bidang'] ?? 'Bidang tidak tersedia',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade700,
                      onPressed: () =>
                          _showDeleteConfirmationDialog(doctor['id']),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'SIP: ${doctor['sip'] ?? '-'}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDoctorDialog() {
    // Import the validators if needed
    // import 'path_to_your_validators.dart';

    // Define the specialization options
    final List<String> specializations = [
      'General Practicioner',
      'Bedah Mulut',
      'Orthodontia',
      'Periodontia',
      'Konservasi Gigi',
      'Ilmu Kedokteran Gigi Anak',
      'Penyakit Mulut',
      'Prosthodontia'
    ];

    // Initialize dropdown value if empty
    if (_bidangController.text.isEmpty && specializations.isNotEmpty) {
      _bidangController.text = specializations[0];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Dokter Baru'),
        content: SizedBox(
          width: 500, // Set specific width to make dialog wider
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Dokter',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    validator: (value) => Validators.validateName(value ?? ''),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _bidangController.text.isEmpty
                        ? specializations[0]
                        : _bidangController.text,
                    decoration: const InputDecoration(
                      labelText: 'Bidang/Spesialisasi',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    items: specializations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _bidangController.text = newValue;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bidang harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _sipController,
                    decoration: const InputDecoration(
                      labelText: 'SIP (Surat Izin Praktik)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.card_membership),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'SIP harus diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop();
                      _addDoctor();
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Simpan'),
          ),
        ],
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String doctorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus dokter ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDoctor(doctorId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Tambahkan dummy data untuk testing
void addDummyDoctors(FirebaseFirestore firestore) async {
  final dummyDoctors = [
    {
      'name': 'Dr. Andi Wijaya',
      'bidang': 'Orthodonti',
      'sip': 'SIP/2024/ORT/001',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Dr. Budi Santoso',
      'bidang': 'Endodonti',
      'sip': 'SIP/2024/END/002',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Dr. Citra Dewi',
      'bidang': 'Bedah Mulut',
      'sip': 'SIP/2024/BDM/003',
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  for (var doctor in dummyDoctors) {
    await firestore.collection('dokter').add(doctor);
  }
}