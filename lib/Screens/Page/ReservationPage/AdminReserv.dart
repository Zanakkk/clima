// ignore_for_file: deprecated_member_use, unused_field, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminReservationsPage extends StatefulWidget {
  const AdminReservationsPage({super.key});

  @override
  State<AdminReservationsPage> createState() => _AdminReservationsPageState();
}

class _AdminReservationsPageState extends State<AdminReservationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? clinicId;
  bool _isLoading = true;
  // Status filters
  final List<String> _statusOptions = [
    'Semua',
    'Pending',
    'Confirmed',
    'Cancelled',
    'Rescheduled',
    'Completed'
  ];
  String _selectedStatusFilter = 'Semua';

  // Date filters
  DateTimeRange? _dateRange;

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sorting
  String _sortField = 'reservationDateTime';
  bool _sortAscending = false;

  // Loading state

  @override
  void initState() {
    super.initState();
    // Set initial date range to current week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _dateRange = DateTimeRange(
      start: startOfWeek,
      end: startOfWeek.add(const Duration(days: 6)),
    );

    fetchClinicId();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchClinicId() async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('clinics')
          .where('email', isEqualTo: currentUser.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          clinicId = querySnapshot.docs.first.id;
        });
        print('ini $clinicId');
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Gagal memuat data klinik: ${e.toString()}');
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data klinik: ${e.toString()}');
    }
  }

  Query<Map<String, dynamic>> _buildQuery() {
    try {
      if (clinicId == null) {
        throw Exception('clinicId tidak boleh null');
      }

      Query<Map<String, dynamic>> query = _firestore
          .collection('reservasipublik')
          .where('clinicId', isEqualTo: clinicId);

      // Filter berdasarkan status
      if (_selectedStatusFilter != 'Semua') {
        final status = _selectedStatusFilter.toLowerCase();
        query = query.where('status', isEqualTo: status);

        if (kDebugMode) {
          print('Filter status: $status');
        }
      }

      // Filter berdasarkan rentang tanggal
      if (_dateRange != null) {
        final start = Timestamp.fromDate(
            _dateRange!.start.copyWith(hour: 0, minute: 0, second: 0));
        final end = Timestamp.fromDate(_dateRange!.end
            .copyWith(hour: 23, minute: 59, second: 59, millisecond: 999));

        query = query
            .where('reservationDateTime', isGreaterThanOrEqualTo: start)
            .where('reservationDateTime', isLessThanOrEqualTo: end);

        if (kDebugMode) {
          print('Filter tanggal: dari $start sampai $end');
        }
      }

      // Urutkan hasil
      query = query.orderBy(_sortField, descending: !_sortAscending);

      if (kDebugMode) {
        print('Sort by $_sortField, ascending: $_sortAscending');
      }

      return query;
    } catch (e, stackTrace) {
      print('Gagal membangun query reservasi: $e');
      if (kDebugMode) {
        print('Gagal membangun query reservasi: $e');
        print(stackTrace);
      }

      // Mengembalikan query kosong (tidak akan menghasilkan dokumen)
      return _firestore
          .collection('reservasipublik')
          .where('clinicId', isEqualTo: '__invalid__');
    }
  }

  Future<void> _updateReservationStatus(
      String documentId, String newStatus) async {
    try {
      await _firestore.collection('reservasipublik').doc(documentId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
        'updatedBy': _auth.currentUser?.email ?? 'admin',
      });
      _showSnackBar('Status berhasil diperbarui');
    } catch (e) {
      _showSnackBar('Gagal memperbarui status: ${e.toString()}');
    } finally {}
  }

  Future<void> _showDeleteConfirmation(
      String documentId, String reservationCode) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus reservasi $reservationCode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteReservation(documentId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReservation(String documentId) async {
    try {
      await _firestore.collection('reservasi').doc(documentId).delete();
      _showSnackBar('Reservasi berhasil dihapus');
    } catch (e) {
      _showSnackBar('Gagal menghapus reservasi: ${e.toString()}');
    } finally {}
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
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

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        title: Text(
          'Admin Reservasi',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFiltersBar(),
          Expanded(
            child: _buildReservationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar() {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: isSmallScreen
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBox(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatusFilter()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDateRangeSelector()),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSortDropdown(),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 2, child: _buildSearchBox()),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusFilter()),
                const SizedBox(width: 16),
                Expanded(child: _buildDateRangeSelector()),
                const SizedBox(width: 16),
                Expanded(child: _buildSortDropdown()),
              ],
            ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nama, telepon, kode...',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
          });
        },
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatusFilter,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          isExpanded: true,
          hint: const Text('Status'),
          items: _statusOptions.map((String status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedStatusFilter = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    String dateText = 'Pilih Tanggal';
    if (_dateRange != null) {
      final formatter = DateFormat('dd/MM/yyyy');
      dateText =
          '${formatter.format(_dateRange!.start)} - ${formatter.format(_dateRange!.end)}';
    }

    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.date_range, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dateText,
                style: const TextStyle(color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.sort, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortField,
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'reservationDateTime',
                    child: Text('Tanggal Reservasi'),
                  ),
                  DropdownMenuItem(
                    value: 'createdAt',
                    child: Text('Tanggal Dibuat'),
                  ),
                  DropdownMenuItem(
                    value: 'name',
                    child: Text('Nama'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      if (_sortField == newValue) {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortField = newValue;
                        _sortAscending = true;
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> reservations = snapshot.data!.docs;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          reservations = reservations.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String name = data['name'] ?? '';
            final String phone = data['phone'] ?? '';
            final String reservationCode = data['reservationCode'] ?? '';
            final String doctorName = data['doctorName'] ?? '';

            return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                phone.contains(_searchQuery) ||
                reservationCode
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                doctorName.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (reservations.isEmpty) {
          return _buildEmptyState();
        }

        return _isSmallScreen(context)
            ? _buildMobileList(reservations)
            : _buildDesktopTable(reservations);
      },
    );
  }

  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Tidak ada reservasi ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter pencarian',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<DocumentSnapshot> reservations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final data = reservations[index].data() as Map<String, dynamic>;
        final String docId = reservations[index].id;

        return _buildReservationCard(docId, data);
      },
    );
  }

  Widget _buildReservationCard(String docId, Map<String, dynamic> data) {
    final DateTime reservationDateTime =
        (data['reservationDateTime'] as Timestamp).toDate();
    final String formattedDate =
        DateFormat('dd MMM yyyy').format(reservationDateTime);
    final String formattedTime =
        DateFormat('HH:mm').format(reservationDateTime);
    final String status = data['status'] ?? 'pending';
    final String name = data['name'] ?? 'Tidak ada nama';
    final String phone = data['phone'] ?? '-';
    final String doctorName = data['doctorName'] ?? 'Tidak ada dokter';
    final String reservationCode = data['reservationCode'] ?? '-';
    final String procedureName = data['procedureName'] ?? 'Tidak ada perawatan';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header with status
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
              children: [
                Text(
                  reservationCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(status),
              ],
            ),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(phone),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                _infoRow('Dokter', doctorName),
                const SizedBox(height: 8),
                _infoRow('Perawatan', procedureName),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusDropdown(docId, status),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () =>
                          _showDeleteConfirmation(docId, reservationCode),
                      icon: Icon(Icons.delete, color: Colors.red.shade400),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
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
    );
  }

  Widget _buildDesktopTable(List<DocumentSnapshot> reservations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        dataRowHeight: 65,
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
        headingTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        columns: const [
          DataColumn(label: Text('Kode')),
          DataColumn(label: Text('Nama')),
          DataColumn(label: Text('Telepon')),
          DataColumn(label: Text('Dokter')),
          DataColumn(label: Text('Perawatan')),
          DataColumn(label: Text('Tanggal & Jam')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: reservations.map((reservation) {
          final data = reservation.data() as Map<String, dynamic>;
          final String docId = reservation.id;
          final DateTime reservationDateTime =
              (data['reservationDateTime'] as Timestamp).toDate();
          final String formattedDate =
              DateFormat('dd MMM yyyy').format(reservationDateTime);
          final String formattedTime =
              DateFormat('HH:mm').format(reservationDateTime);
          final String status = data['status'] ?? 'pending';

          return DataRow(cells: [
            DataCell(Text(
              data['reservationCode'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
            DataCell(Text(data['name'] ?? 'Tidak ada nama')),
            DataCell(Text(data['phone'] ?? '-')),
            DataCell(Text(data['doctorName'] ?? '-')),
            DataCell(Text(data['procedureName'] ?? '-')),
            DataCell(Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate),
                Text(
                  formattedTime,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )),
            DataCell(_buildStatusBadge(status)),
            DataCell(Row(
              children: [
                Expanded(child: _buildStatusDropdown(docId, status)),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      _showDeleteConfirmation(docId, data['reservationCode']),
                  icon: Icon(Icons.delete, color: Colors.red.shade400),
                  tooltip: 'Hapus',
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData badgeIcon;
    String statusText = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'confirmed':
        badgeColor = Colors.green;
        badgeIcon = Icons.check_circle;
        break;
      case 'cancelled':
        badgeColor = Colors.red;
        badgeIcon = Icons.cancel;
        break;
      case 'rescheduled':
        badgeColor = Colors.orange;
        badgeIcon = Icons.update;
        break;
      case 'completed':
        badgeColor = Colors.blue;
        badgeIcon = Icons.task_alt;
        break;
      default:
        badgeColor = Colors.amber;
        badgeIcon = Icons.pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(String docId, String currentStatus) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: BorderRadius.circular(8),
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            DropdownMenuItem(value: 'rescheduled', child: Text('Rescheduled')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
          ],
          onChanged: (newValue) {
            if (newValue != null && newValue != currentStatus) {
              _updateReservationStatus(docId, newValue);
            }
          },
        ),
      ),
    );
  }
}
