// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DaftarTindakanPasien extends StatefulWidget {
  const DaftarTindakanPasien({super.key});

  @override
  _DaftarTindakanPasienState createState() => _DaftarTindakanPasienState();
}

class _DaftarTindakanPasienState extends State<DaftarTindakanPasien> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  List<Map<String, dynamic>> _dentists = [];

  Map<String, dynamic>? _selectedPatient;
  Map<String, dynamic>? _selectedDentist;

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPatients);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      _fetchPatients(),
      _fetchDentists(),
    ]);

    setState(() => _isLoading = false);
  }

  Future<void> _fetchPatients() async {
    try {
      final snapshot = await _firestore.collection('pasien').get();

      final List<Map<String, dynamic>> patients = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      setState(() {
        _patients = patients;
        _filteredPatients = patients;
      });
    } catch (e) {
      _showSnackBar('Gagal mengambil data pasien: ${e.toString()}');
    }
  }

  Future<void> _fetchDentists() async {
    try {
      final snapshot = await _firestore.collection('dokter').get();

      final List<Map<String, dynamic>> dentists = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      setState(() {
        _dentists = dentists;
      });
    } catch (e) {
      _showSnackBar('Gagal mengambil data dokter: ${e.toString()}');
    }
  }

  void _filterPatients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((patient) {
        String fullName = patient['fullName']?.toString().toLowerCase() ?? '';
        String nik = patient['nik']?.toString().toLowerCase() ?? '';
        String phone = patient['phone']?.toString().toLowerCase() ?? '';
        return fullName.contains(query) ||
            nik.contains(query) ||
            phone.contains(query);
      }).toList();

      if (_selectedPatient != null &&
          !_filteredPatients.contains(_selectedPatient)) {
        _selectedPatient = null;
      }
    });
  }

  Future<void> _registerProcedure() async {
    if (_selectedPatient == null || _selectedDentist == null) {
      _showSnackBar('Silakan pilih pasien dan dokter terlebih dahulu');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _firestore.collection('tindakan').add({
        'doctor': _selectedDentist!['name'],
        'doctorId': _selectedDentist!['id'],
        'idpasien': _selectedPatient!['id'],
        'namapasien': _selectedPatient!['fullName'],
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      _showSnackBar('Tindakan berhasil didaftarkan', isError: false);

      // Reset selection after successful submission
      setState(() {
        _selectedPatient = null;
        _selectedDentist = null;
        _searchController.clear();
      });
    } catch (e) {
      _showSnackBar('Gagal mendaftarkan tindakan: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
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

      body: _isLoading ? const _LoadingView() : _buildBody(),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      // Responsive layout adjustment
      final isWideScreen = constraints.maxWidth > 600;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 800 : constraints.maxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSearchField(),
                const SizedBox(height: 16),
                _buildPatientSelection(),
                const SizedBox(height: 24),
                _buildDentistSelection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pendaftaran Tindakan Pasien',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih pasien dan dokter gigi untuk mendaftarkan tindakan baru',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari pasien berdasarkan nama, NIK, atau telepon',
            prefixIcon: Icon(Icons.search,
                color: Theme.of(context).colorScheme.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Pasien',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _filteredPatients.isEmpty
            ? _buildEmptyPatientsList()
            : _buildPatientsList(),
      ],
    );
  }

  Widget _buildEmptyPatientsList() {
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
              Icon(Icons.person_search, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isEmpty
                    ? 'Tidak ada data pasien'
                    : 'Tidak ada pasien yang cocok dengan pencarian',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientsList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedPatient,
        hint: const Text('Pilih pasien'),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        items: _filteredPatients.map((patient) {
          final String name = patient['fullName'] ?? 'Nama tidak tersedia';
          final String nik = patient['nik'] ?? '-';

          return DropdownMenuItem<Map<String, dynamic>>(
            value: patient,
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '$name - NIK: $nik',
                style: const TextStyle(fontWeight: FontWeight.bold),
                softWrap: true,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedPatient = value);
        },
        isDense: false,
        itemHeight: null,
        // Membiarkan item menyesuaikan tinggi konten
        menuMaxHeight: 400, // Menambah ketinggian maksimum menu
      ),
    );
  }

  Widget _buildDentistSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Dokter Gigi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _dentists.isEmpty ? _buildEmptyDentistsList() : _buildDentistsList(),
      ],
    );
  }

  Widget _buildEmptyDentistsList() {
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
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data dokter gigi',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDentistsList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedDentist,
        hint: const Text('Pilih dokter gigi'),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        items: _dentists.map((dentist) {
          final String name = dentist['name'] ?? 'Nama tidak tersedia';
          final String sip = dentist['sip'] ?? '-';

          return DropdownMenuItem<Map<String, dynamic>>(
            value: dentist,
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '$name - SIP: $sip',
                style: const TextStyle(fontWeight: FontWeight.bold),
                softWrap: true,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedDentist = value);
        },
        isDense: false,
        itemHeight: null,
        // Membiarkan item menyesuaikan tinggi konten
        menuMaxHeight: 400, // Menambah ketinggian maksimum menu
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _registerProcedure,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isSubmitting
          ? const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Memproses...'),
              ],
            )
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save),
                SizedBox(width: 12),
                Text(
                  'Daftarkan Tindakan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
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
}
