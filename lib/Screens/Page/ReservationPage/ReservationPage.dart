// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
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
  String? _clinicId;

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      _loadClinicId(),
      _fetchDoctors(),
      _fetchProcedures(),
    ]);

    setState(() => _isLoading = false);
  }

  // Get the clinic ID
  Future<void> _loadClinicId() async {
    try {
      // Memuat ID Klinik dari URL atau sistem
      // Contoh sederhana: mengambil klinik pertama dari database
      final querySnapshot =
          await _firestore.collection('clinics').limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _clinicId = querySnapshot.docs.first.id;
        });
      }
    } catch (e) {
      _showSnackBar('Error loading clinic data: ${e.toString()}');
    }
  }

  // Fetch list of doctors from firestore
  Future<void> _fetchDoctors() async {
    try {
      final snapshot = await _firestore.collection('dokter').get();

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

  // Fetch list of procedures/treatments from firestore
  Future<void> _fetchProcedures() async {
    try {
      final snapshot = await _firestore.collection('pricelist').get();

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

  // Submit reservation to firestore
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

      if (_clinicId == null) {
        _showSnackBar('Data klinik tidak ditemukan');
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        // Generate reservation number
        final DateTime now = DateTime.now();
        final String reservationCode =
            'RES${now.millisecondsSinceEpoch.toString().substring(5)}';

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
          'clinicId': _clinicId,
          'reservationCode': reservationCode,
          'status': 'pending', // Default status
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

  // Check reservation by phone number
  Future<void> _checkReservation(String phoneNumber) async {
    setState(() => _isCheckingReservation = true);

    try {
      final snapshot = await _firestore
          .collection('reservasi')
          .where('phone', isEqualTo: phoneNumber)
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
        _showSnackBar('Tidak ada reservasi dengan nomor telepon tersebut');
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('Reservasi Berhasil',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reservasi Anda telah berhasil dibuat dengan kode:',
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
              'Silakan simpan kode reservasi ini untuk referensi Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
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

  void _showReservationDetails() {
    if (_foundReservation == null) return;

    final DateTime reservationDateTime =
        (_foundReservation!['reservationDateTime'] as Timestamp).toDate();
    final String formattedDate =
        DateFormat('dd MMMM yyyy').format(reservationDateTime);
    final String formattedTime =
        DateFormat('HH:mm').format(reservationDateTime);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue, size: 40),
            SizedBox(height: 8),
            Text('Detail Reservasi',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailItem(
                  'Kode Reservasi', _foundReservation!['reservationCode']),
              _detailItem('Nama', _foundReservation!['name']),
              _detailItem('Telepon', _foundReservation!['phone']),
              _detailItem('Dokter', _foundReservation!['doctorName']),
              _detailItem('Perawatan', _foundReservation!['procedureName']),
              _detailItem('Tanggal', formattedDate),
              _detailItem('Waktu', formattedTime),
              _detailItem('Status', _foundReservation!['status']),
            ],
          ),
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

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      // Validate time (9:00 AM - 9:00 PM)
      if (picked.hour < 9 ||
          (picked.hour >= 21 && picked.minute > 0) ||
          picked.hour > 21) {
        _showSnackBar('Jam operasional klinik adalah 09:00 - 21:00');
        return;
      }

      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Replace ResponsiveWrapper with MediaQuery for responsiveness
  @override
  Widget build(BuildContext context) {
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

// Helper method to determine if device is tablet based on width
  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800;
  }

  Widget _buildReservationForm() {
    return Container(
      margin: EdgeInsets.only(right: _isTablet(context) ? 16 : 0, bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form Reservasi',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Silakan isi formulir di bawah ini untuk melakukan reservasi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
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
                  return 'Nama tidak boleh kosong';
                } else if (value.length < 3) {
                  return 'Nama minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nomor HP
            _buildFormField(
              label: 'Nomor HP',
              controller: _phoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor HP tidak boleh kosong';
                } else if (!RegExp(r'^[0-9]{10,13}$').hasMatch(value)) {
                  return 'Nomor HP tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Pilih Dokter
            _buildDoctorSelection(),
            const SizedBox(height: 24),

            // Keluhan
            _buildFormField(
              label: 'Keluhan',
              controller: _complaintController,
              icon: Icons.notes_outlined,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Keluhan tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildDateTimeSelectors(),
            const SizedBox(height: 24),
            // Perawatan yang diinginkan
            _buildTreatmentSelection(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      margin: EdgeInsets.only(left: _isTablet(context) ? 16 : 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cek Status Reservasi',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan nomor HP yang Anda gunakan saat reservasi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),

          // Form cek reservasi
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _checkPhoneNumber = value),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Nomor HP',
                    prefixIcon: Icon(Icons.phone, color: Colors.blue.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _checkPhoneNumber != null &&
                        _checkPhoneNumber!.isNotEmpty &&
                        !_isCheckingReservation
                    ? () => _checkReservation(_checkPhoneNumber!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isCheckingReservation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Cek'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Hasil cek reservasi
          if (_foundReservation != null) _buildReservationResult(),

          const SizedBox(height: 40),

          // Info jam operasional
          _buildOperationalHoursInfo(),

          const SizedBox(height: 30),

          // Info reservasi sukses
          if (_reservationNumber != null) _buildReservationSuccessInfo(),
        ],
      ),
    );
  }
// Add these four methods in the _ReservationsPageState class, wherever appropriate

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: Colors.blue.shade800,
      child: Column(
        children: [
          Text(
            '© ${DateTime.now().year} SISTEM INFORMASI MANAJEMEN KLINIK',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Hubungi kami di 021-5525999',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  } // Add these four methods in the _ReservationsPageState class, wherever appropriate

  Widget _buildOperationalHoursInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Jam Operasional',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOperationalHourItem('Senin - Jumat', '09:00 - 21:00'),
          const SizedBox(height: 6),
          _buildOperationalHourItem('Sabtu', '09:00 - 18:00'),
          const SizedBox(height: 6),
          _buildOperationalHourItem('Minggu', '10:00 - 16:00'),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reservasi dapat dilakukan minimal 1 hari sebelumnya',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalHourItem(String day, String hours) {
    return Row(
      children: [
        const SizedBox(width: 4),
        SizedBox(
          width: 100,
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Text(
          ': ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          hours,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildReservationSuccessInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reservasi Berhasil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Reservasi Anda telah berhasil dibuat dengan kode:',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _reservationNumber!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _reservationNumber!));
                    _showSnackBar('Kode reservasi disalin ke clipboard');
                  },
                  icon:
                      Icon(Icons.copy, size: 18, color: Colors.green.shade700),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Salin kode',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Silahkan simpan kode reservasi ini. Kami akan mengirimkan konfirmasi lebih lanjut melalui nomor telepon yang Anda berikan.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
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

  Widget _buildDateTimeSelectors() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanggal Reservasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue.shade400),
                      const SizedBox(width: 16),
                      Text(
                        DateFormat('dd MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jam Reservasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue.shade400),
                      const SizedBox(width: 16),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReservation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.blue.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Memproses...')
                ],
              )
            : const Text(
                'Kirim Reservasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildReservationResult() {
    final DateTime reservationDateTime =
        (_foundReservation!['reservationDateTime'] as Timestamp).toDate();
    final String formattedDate =
        DateFormat('dd MMMM yyyy').format(reservationDateTime);
    final String formattedTime =
        DateFormat('HH:mm').format(reservationDateTime);
    final String status = _foundReservation!['status'] ?? 'pending';

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'rescheduled':
        statusColor = Colors.orange;
        statusIcon = Icons.update;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
      default:
        statusColor = Colors.amber;
        statusIcon = Icons.pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Reservasi Ditemukan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReservationInfoItem(
              'Kode', _foundReservation!['reservationCode']),
          _buildReservationInfoItem('Nama', _foundReservation!['name']),
          _buildReservationInfoItem('Dokter', _foundReservation!['doctorName']),
          _buildReservationInfoItem('Tanggal', formattedDate),
          _buildReservationInfoItem('Jam', formattedTime),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _showReservationDetails,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Lihat Detail'),
            ),
          ),
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

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data...'),
        ],
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
          Text(
            'SISTEM INFORMASI MANAJEMEN KLINIK',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
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
        ],
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
