// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'ReservationPage.dart'; // Atau package routing yang Anda gunakan

class PublicReservationsPage extends StatefulWidget {
  final String? clinicId; // Parameter dari URL atau route

  const PublicReservationsPage({super.key, this.clinicId});

  @override
  State<PublicReservationsPage> createState() => _PublicReservationsPageState();
}

class _PublicReservationsPageState extends State<PublicReservationsPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  // Selected values
  Map<String, dynamic>? _selectedDoctor;
  Map<String, dynamic>? _selectedProcedure;

  // Clinic data
  Map<String, dynamic>? _clinicData;

  // Data lists
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _procedures = [];

  // Status indicators
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isCheckingReservation = false;
  String? _reservationNumber;
  String? _checkPhoneNumber;
  Map<String, dynamic>? _foundReservation;
  bool _clinicNotFound = false;

  @override
  void initState() {
    super.initState();
    _initializeClinic();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _initializeClinic() async {
    setState(() => _isLoading = true);

    // Jika tidak ada clinicId dari parameter, tampilkan error
    if (widget.clinicId == null || widget.clinicId!.isEmpty) {
      setState(() {
        _clinicNotFound = true;
        _isLoading = false;
      });
      return;
    }

    await _loadClinicData();

    if (_clinicData != null) {
      await Future.wait([
        _fetchDoctors(),
        _fetchProcedures(),
      ]);
    }

    setState(() => _isLoading = false);
  }

  // Load clinic data berdasarkan ID
  Future<void> _loadClinicData() async {
    try {
      // Coba ambil berdasarkan document ID
      DocumentSnapshot doc =
          await _firestore.collection('clinics').doc(widget.clinicId!).get();

      if (doc.exists) {
        setState(() {
          _clinicData = {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          };
        });
        return;
      }

      // Jika tidak ditemukan berdasarkan ID, coba cari berdasarkan slug/code
      QuerySnapshot querySnapshot = await _firestore
          .collection('clinics')
          .where('endpointId', isEqualTo: widget.clinicId!)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _clinicData = {
            'id': querySnapshot.docs.first.id,
            ...querySnapshot.docs.first.data() as Map<String, dynamic>,
          };
        });
      } else {
        setState(() {
          _clinicNotFound = true;
        });
      }
    } catch (e) {
      _showSnackBar('Error loading clinic data: ${e.toString()}');
      setState(() {
        _clinicNotFound = true;
      });
    }
  }

  // Fetch doctors yang bekerja di klinik ini
  Future<void> _fetchDoctors() async {
    try {
      // Ambil dokter berdasarkan clinic ID
      final snapshot = await _firestore
          .collection('dokter')
          .where('clinicId', isEqualTo: _clinicData!['id'])
          .get();

      final List<Map<String, dynamic>> doctors = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      setState(() {
        _doctors = doctors;
      });
    } catch (e) {
      _showSnackBar('Gagal mengambil data dokter: ${e.toString()}');
    }
  }

  // Fetch procedures yang tersedia di klinik ini
  Future<void> _fetchProcedures() async {
    try {
      // Ambil pricelist berdasarkan clinic ID
      final snapshot = await _firestore
          .collection('pricelist')
          .where('clinicId', isEqualTo: _clinicData!['id'])
          .get();

      final List<Map<String, dynamic>> procedures = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] as String,
          'price': data['price'] as int,
        };
      }).toList();

      setState(() {
        _procedures = procedures;
      });
    } catch (e) {
      _showSnackBar('Gagal mengambil data perawatan: ${e.toString()}');
    }
  }

  // Submit reservation dengan clinic ID yang tepat
  Future<void> _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDoctor == null) {
        _showSnackBar('Silakan pilih dokter terlebih dahulu');
        return;
      }

      if (_selectedProcedure == null) {
        _showSnackBar('Silakan pilih jenis perawatan terlebih dahulu');
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        // Generate reservation number dengan prefix clinic
        final DateTime now = DateTime.now();
        final String clinicPrefix = _clinicData!['code'] ?? 'CLI';
        final String reservationCode =
            '$clinicPrefix${now.millisecondsSinceEpoch.toString().substring(5)}';

        // Combine date and time
        final DateTime reservationDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        // Create reservation data
        final Map<String, dynamic> reservationData = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'doctorId': _selectedDoctor!['id'],
          'doctorName': _selectedDoctor!['name'],
          'complaint': _complaintController.text.trim(),
          'procedureId': _selectedProcedure!['id'],
          'procedureName': _selectedProcedure!['name'],
          'procedurePrice': _selectedProcedure!['price'],
          'reservationDateTime': Timestamp.fromDate(reservationDateTime),
          'createdAt': Timestamp.fromDate(now),
          'clinicId': _clinicData!['id'], // Pastikan clinic ID yang benar
          'clinicName': _clinicData!['name'],
          'reservationCode': reservationCode,
          'status': 'pending',
          'source': 'public', // Tandai bahwa ini dari public reservation
        };

        // Save to firestore
        await _firestore.collection('reservasi').add(reservationData);

        // Reset form
        _formKey.currentState!.reset();
        _nameController.clear();
        _phoneController.clear();
        _complaintController.clear();
        setState(() {
          _selectedDoctor = null;
          _selectedProcedure = null;
          _selectedDate = DateTime.now();
          _selectedTime = const TimeOfDay(hour: 9, minute: 0);
          _reservationNumber = reservationCode;
        });

        _showSuccessDialog(reservationCode);
      } catch (e) {
        _showSnackBar('Gagal membuat reservasi: ${e.toString()}');
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Check reservation dengan filter clinic ID
  Future<void> _checkReservation(String phoneNumber) async {
    setState(() => _isCheckingReservation = true);

    try {
      final snapshot = await _firestore
          .collection('reservasi')
          .where('phone', isEqualTo: phoneNumber)
          .where('clinicId',
              isEqualTo: _clinicData!['id']) // Filter berdasarkan clinic
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _foundReservation = {
            'id': snapshot.docs.first.id,
            ...snapshot.docs.first.data(),
          };
        });
      } else {
        setState(() {
          _foundReservation = null;
        });
        _showSnackBar(
            'Tidak ada reservasi dengan nomor telepon tersebut di klinik ini');
      }
    } catch (e) {
      _showSnackBar('Gagal mengecek reservasi: ${e.toString()}');
    } finally {
      setState(() => _isCheckingReservation = false);
    }
  }

  void _showSuccessDialog(String reservationCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(
              'Reservasi Berhasil',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reservasi Anda di ${_clinicData!['name']} telah berhasil dibuat dengan kode:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                reservationCode,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Silakan simpan kode reservasi ini untuk referensi Anda. Kami akan menghubungi Anda untuk konfirmasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            // Informasi kontak klinik
            if (_clinicData!['phone'] != null)
              Text(
                'Kontak: ${_clinicData!['phone']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan error jika klinik tidak ditemukan
  Widget _buildClinicNotFoundView() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Klinik Tidak Ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ID Klinik "${widget.clinicId}" tidak valid atau tidak ditemukan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Silakan periksa kembali link yang Anda gunakan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_clinicNotFound) {
      return _buildClinicNotFoundView();
    }

    return Scaffold(
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: _isLoading
          ? _buildLoadingView()
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _isTablet(context)
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildReservationForm(),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildSidePanel(),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildReservationForm(),
                              _buildSidePanel(),
                            ],
                          ),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Nama Klinik
          if (_clinicData != null)
            Text(
              _clinicData!['name']?.toString().toUpperCase() ?? 'KLINIK',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Text(
            'RESERVASI ONLINE',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Alamat klinik jika ada
          if (_clinicData != null && _clinicData!['address'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _clinicData!['address'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: Colors.blue.shade800,
      child: Column(
        children: [
          if (_clinicData != null) ...[
            Text(
              '© ${DateTime.now().year} ${_clinicData!['name']?.toString().toUpperCase()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            if (_clinicData!['phone'] != null)
              Text(
                'Hubungi kami di ${_clinicData!['phone']}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
          ] else ...[
            Text(
              '© ${DateTime.now().year} SISTEM RESERVASI KLINIK',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to determine if device is tablet based on width
  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data klinik...'),
        ],
      ),
    );
  }

  Widget _buildReservationInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProceduresList() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.healing_outlined,
                  size: 36, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'Tidak ada data perawatan',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProceduresList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedProcedure,
        hint: const Text('Pilih jenis perawatan'),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.healing, color: Colors.blue.shade400),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        items: _procedures.map((procedure) {
          final String name = procedure['name'] ?? 'Nama tidak tersedia';
          final int price = procedure['price'] ?? 0;
          final formatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return DropdownMenuItem<Map<String, dynamic>>(
            value: procedure,
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    softWrap: true,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatter.format(price),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedProcedure = value);
        },
        isDense: false,
        itemHeight: null,
        menuMaxHeight: 400,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Dokter',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        _doctors.isEmpty ? _buildEmptyDoctorsList() : _buildDoctorsList(),
      ],
    );
  }

  Widget _buildDoctorsList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedDoctor,
        hint: const Text('Pilih dokter'),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.medical_services, color: Colors.blue.shade400),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        items: _doctors.map((doctor) {
          final String name = doctor['name'] ?? 'Nama tidak tersedia';
          final String sip = doctor['sip'] ?? '-';

          return DropdownMenuItem<Map<String, dynamic>>(
            value: doctor,
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '$name - SIP: $sip',
                style: const TextStyle(fontWeight: FontWeight.w500),
                softWrap: true,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedDoctor = value);
        },
        isDense: false,
        itemHeight: null,
        menuMaxHeight: 400,
      ),
    );
  }

  Widget _buildEmptyDoctorsList() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.medical_services_outlined,
                  size: 36, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'Tidak ada data dokter',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTreatmentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Perawatan yang Diinginkan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        _procedures.isEmpty
            ? _buildEmptyProceduresList()
            : _buildProceduresList(),
      ],
    );
  }
}
// ========== CLINIC URL GENERATOR ==========

class ClinicUrlGenerator {
  static const String baseUrl =
      'https://yourdomain.com'; // Ganti dengan domain Anda

  // Generate URL untuk reservasi public
  static String generateReservationUrl(String clinicId) {
    return '$baseUrl/reservasi?clinic=$clinicId';
  }

  // Generate URL berdasarkan clinic slug (lebih user friendly)
  static String generateReservationUrlBySlug(String clinicSlug) {
    return '$baseUrl/reservasi?clinic=$clinicSlug';
  }

  // Method untuk membuat slug dari nama klinik
  static String createSlugFromName(String clinicName) {
    return clinicName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Hapus karakter khusus
        .replaceAll(RegExp(r'\s+'), '-') // Ganti spasi dengan dash
        .replaceAll(
            RegExp(r'-+'), '-'); // Ganti multiple dash dengan single dash
  }

  // Batch update untuk menambahkan slug ke semua klinik yang sudah ada
  static Future<void> generateSlugsForExistingClinics() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Ambil semua klinik
      final snapshot = await firestore.collection('clinics').get();

      final batch = firestore.batch();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final clinicName = data['name'] as String?;

        if (clinicName != null && data['slug'] == null) {
          final slug = createSlugFromName(clinicName);
          batch.update(doc.reference, {'slug': slug});
        }
      }

      await batch.commit();
      print('Slug berhasil ditambahkan ke semua klinik');
    } catch (e) {
      print('Error generating slugs: $e');
    }
  }
}

// ========== ROUTE SETUP (untuk Flutter Web) ==========

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      // Route untuk admin (yang sudah ada)
      GoRoute(
        path: '/admin/reservations',
        builder: (context, state) =>
            const ReservationsPage(), // Page admin yang lama
      ),

      // Route untuk public reservation
      GoRoute(
        path: '/reservasi',
        builder: (context, state) {
          final clinicId = state.uri.queryParameters['clinic'];
          return PublicReservationsPage(clinicId: clinicId);
        },
      ),

      // Alternative route dengan path parameter (opsional)
      GoRoute(
        path: '/klinik/:clinicSlug/reservasi',
        builder: (context, state) {
          final clinicSlug = state.pathParameters['clinicSlug'];
          return PublicReservationsPage(clinicId: clinicSlug);
        },
      ),
    ],
  );
}

// ========== DATABASE SETUP HELPER ==========
class DatabaseSetupHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tambahkan field slug ke collection clinics
  static Future<void> addSlugFieldToClinics() async {
    try {
      final snapshot = await _firestore.collection('clinics').get();

      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final clinicName = data['name'] as String?;

        if (clinicName != null) {
          final slug = ClinicUrlGenerator.createSlugFromName(clinicName);
          batch.update(doc.reference, {
            'slug': slug,
            'publicReservationEnabled':
                true, // Flag untuk enable/disable public reservation
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      print('Slug field berhasil ditambahkan');
    } catch (e) {
      print('Error: $e');
    }
  }

  // Update collection dokter untuk menambahkan clinicId reference
  static Future<void> linkDoctorsToClinic() async {
    try {
      // Contoh: jika Anda perlu link dokter ke klinik tertentu
      final doctorsSnapshot = await _firestore.collection('dokter').get();
      final clinicsSnapshot = await _firestore.collection('clinics').get();

      if (clinicsSnapshot.docs.isNotEmpty) {
        final firstClinicId = clinicsSnapshot.docs.first.id;

        final batch = _firestore.batch();

        for (var doc in doctorsSnapshot.docs) {
          // Jika dokter belum punya clinicId, assign ke klinik pertama
          final data = doc.data();
          if (data['clinicId'] == null) {
            batch.update(doc.reference, {
              'clinicId': firstClinicId,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        await batch.commit();
        print('Doctors linked to clinic');
      }
    } catch (e) {
      print('Error linking doctors: $e');
    }
  }

  // Update collection pricelist untuk menambahkan clinicId reference
  static Future<void> linkPricelistToClinic() async {
    try {
      final pricelistSnapshot = await _firestore.collection('pricelist').get();
      final clinicsSnapshot = await _firestore.collection('clinics').get();

      if (clinicsSnapshot.docs.isNotEmpty) {
        final firstClinicId = clinicsSnapshot.docs.first.id;

        final batch = _firestore.batch();

        for (var doc in pricelistSnapshot.docs) {
          final data = doc.data();
          if (data['clinicId'] == null) {
            batch.update(doc.reference, {
              'clinicId': firstClinicId,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        await batch.commit();
        print('Pricelist linked to clinic');
      }
    } catch (e) {
      print('Error linking pricelist: $e');
    }
  }
}

// ========== ADMIN PANEL UNTUK GENERATE URLS ==========
class ClinicUrlManagementPage extends StatefulWidget {
  const ClinicUrlManagementPage({super.key});

  @override
  State<ClinicUrlManagementPage> createState() =>
      _ClinicUrlManagementPageState();
}

class _ClinicUrlManagementPageState extends State<ClinicUrlManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _clinics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    try {
      final snapshot = await _firestore.collection('clinics').get();

      final clinics = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      setState(() {
        _clinics = clinics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic URL Management'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _clinics.length,
              itemBuilder: (context, index) {
                final clinic = _clinics[index];
                final clinicId = clinic['id'];
                final clinicName = clinic['name'] ?? 'Unnamed Clinic';
                final slug = clinic['slug'];

                // Generate URLs
                final urlById =
                    ClinicUrlGenerator.generateReservationUrl(clinicId);
                final urlBySlug = slug != null
                    ? ClinicUrlGenerator.generateReservationUrlBySlug(slug)
                    : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clinicName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('ID: $clinicId'),
                        if (slug != null) Text('Slug: $slug'),
                        const SizedBox(height: 16),

                        // URL by ID
                        const Text('URL by ID:',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        SelectableText(
                          urlById,
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: urlById));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('URL copied to clipboard')),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copy'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                // Launch URL in browser (untuk testing)
                                // launch(urlById); // Uncomment jika menggunakan url_launcher
                              },
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Test'),
                            ),
                          ],
                        ),

                        if (urlBySlug != null) ...[
                          const SizedBox(height: 16),
                          const Text('URL by Slug (User Friendly):',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          SelectableText(
                            urlBySlug,
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: urlBySlug));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('URL copied to clipboard')),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 16),
                                label: const Text('Copy'),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // Launch URL in browser (untuk testing)
                                  // launch(urlBySlug); // Uncomment jika menggunakan url_launcher
                                },
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('Test'),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),
                        // QR Code untuk URL (opsional)
                        ElevatedButton.icon(
                          onPressed: () => _showQRCodeDialog(
                              context, urlBySlug ?? urlById, clinicName),
                          icon: const Icon(Icons.qr_code),
                          label: const Text('Generate QR Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await DatabaseSetupHelper.addSlugFieldToClinics();
          _loadClinics();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Update Slugs'),
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context, String url, String clinicName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code - $clinicName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder untuk QR Code
            // Anda bisa menggunakan package seperti qr_flutter
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 48, color: Colors.grey.shade600),
                  const SizedBox(height: 8),
                  Text(
                    'QR Code\n(Install qr_flutter package)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scan QR code untuk akses reservasi',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            SelectableText(
              url,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ========== MELENGKAPI PublicReservationsPage (bagian yang hilang) ==========

// Method yang hilang dari PublicReservationsPage
extension PublicReservationsPageExtension on _PublicReservationsPageState {
  Widget _buildReservationForm() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Formulir Reservasi',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 24),

              // Nama Lengkap
              _buildFormField(
                label: 'Nama Lengkap',
                controller: _nameController,
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nomor Telepon
              _buildFormField(
                label: 'Nomor Telepon',
                controller: _phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon wajib diisi';
                  }
                  if (value.length < 10) {
                    return 'Nomor telepon minimal 10 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pilih Dokter
              _buildDoctorSelection(),
              const SizedBox(height: 16),

              // Pilih Perawatan
              _buildTreatmentSelection(),
              const SizedBox(height: 16),

              // Tanggal dan Waktu
              Row(
                children: [
                  Expanded(child: _buildDatePicker()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePicker()),
                ],
              ),
              const SizedBox(height: 16),

              // Keluhan
              _buildFormField(
                label: 'Keluhan (Opsional)',
                controller: _complaintController,
                icon: Icons.note_alt,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'BUAT RESERVASI',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue.shade600,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != _selectedDate) {
              setState(() => _selectedDate = picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue.shade400),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Waktu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue.shade600,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != _selectedTime) {
              setState(() => _selectedTime = picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue.shade400),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidePanel() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Column(
        children: [
          _buildReservationStatus(),
          const SizedBox(height: 24),
          _buildCheckReservation(),
        ],
      ),
    );
  }

  Widget _buildReservationStatus() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Informasi Reservasi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem('📅', 'Jam Operasional', '08:00 - 17:00'),
            _buildInfoItem('⏰', 'Konfirmasi', 'Maks 2 jam sebelum jadwal'),
            _buildInfoItem('📞', 'Kontak', _clinicData?['phone'] ?? '-'),
            _buildInfoItem('📍', 'Alamat', _clinicData?['address'] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckReservation() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Cek Reservasi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Masukkan nomor telepon',
                prefixIcon: Icon(Icons.phone, color: Colors.green.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.green.shade400, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) => _checkPhoneNumber = value,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCheckingReservation
                    ? null
                    : () {
                        if (_checkPhoneNumber != null &&
                            _checkPhoneNumber!.isNotEmpty) {
                          _checkReservation(_checkPhoneNumber!);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCheckingReservation
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('CEK RESERVASI'),
              ),
            ),
            if (_foundReservation != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reservasi Ditemukan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildReservationInfoItem(
                        'Kode', _foundReservation!['reservationCode'] ?? '-'),
                    _buildReservationInfoItem(
                        'Nama', _foundReservation!['name'] ?? '-'),
                    _buildReservationInfoItem(
                        'Dokter', _foundReservation!['doctorName'] ?? '-'),
                    _buildReservationInfoItem(
                        'Status',
                        (_foundReservation!['status'] ?? 'pending')
                            .toUpperCase()),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ========== UTILITY FUNCTIONS ==========

// Helper untuk setup database initial
class DatabaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Setup initial data untuk testing
  static Future<void> setupInitialData() async {
    try {
      // Create sample clinic
      final clinicRef = await _firestore.collection('clinics').add({
        'name': 'Klinik Sehat Bersama',
        'address': 'Jl. Kesehatan No. 123, Jakarta',
        'phone': '021-12345678',
        'slug': 'klinik-sehat-bersama',
        'code': 'KSB',
        'publicReservationEnabled': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final clinicId = clinicRef.id;

      // Create sample doctors
      await _firestore.collection('dokter').add({
        'name': 'Dr. Ahmad Prakasa',
        'sip': '123456789',
        'specialization': 'Umum',
        'clinicId': clinicId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('dokter').add({
        'name': 'Dr. Sari Dewi',
        'sip': '987654321',
        'specialization': 'Gigi',
        'clinicId': clinicId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create sample procedures
      await _firestore.collection('pricelist').add({
        'name': 'Konsultasi Umum',
        'price': 100000,
        'clinicId': clinicId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('pricelist').add({
        'name': 'Pemeriksaan Gigi',
        'price': 150000,
        'clinicId': clinicId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('pricelist').add({
        'name': 'Cabut Gigi',
        'price': 200000,
        'clinicId': clinicId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Initial data setup completed');
    } catch (e) {
      print('Error setting up initial data: $e');
    }
  }
}

// ========== TESTING UTILITIES ==========

class ReservationTestHelper {
  // Generate test URL
  static void printTestUrls() {
    const clinicId = 'your-clinic-id-here';
    const clinicSlug = 'klinik-sehat-bersama';

    print('=== TEST URLS ===');
    print('By ID: ${ClinicUrlGenerator.generateReservationUrl(clinicId)}');
    print(
        'By Slug: ${ClinicUrlGenerator.generateReservationUrlBySlug(clinicSlug)}');
    print('================');
  }

  // Validate reservation data
  static bool validateReservationData(Map<String, dynamic> data) {
    final requiredFields = [
      'name',
      'phone',
      'doctorId',
      'procedureId',
      'reservationDateTime',
      'clinicId'
    ];

    for (String field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        print('Missing required field: $field');
        return false;
      }
    }

    return true;
  }
}
