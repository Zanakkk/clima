import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  // Controller untuk input form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();

  // State untuk menyimpan tanggal dan jam yang dipilih
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;

  // Data untuk time slot yang tersedia dan yang sudah dipesan
  final List<String> _availableTimeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'
  ];

  // Simulasi data appointment yang sudah ada (dalam pengembangan nyata akan diambil dari database)
  final HashMap<String, List<String>> _bookedSlots = HashMap<String, List<String>>();
  final List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    // Simulasi beberapa slot yang sudah dipesan
    _bookedSlots[_formatDateKey(DateTime.now())] = ['09:00', '11:00', '14:30'];
    _loadAppointments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  // Format tanggal untuk digunakan sebagai key
  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Method untuk memuat data appointment yang sudah ada
  void _loadAppointments() {
    // Dalam aplikasi nyata, ini akan mengambil data dari database/API
    final String todayKey = _formatDateKey(_selectedDate);
    if (_bookedSlots.containsKey(todayKey)) {
      // Simulasi data
      for (var slot in _bookedSlots[todayKey]!) {
        _appointments.add({
          'name': 'Pasien ${slot.replaceAll(':', '')}',
          'complaint': 'Keluhan untuk jadwal $slot',
          'time': slot,
          'date': _selectedDate,
        });
      }
    }
  }

  // Method yang dipanggil ketika pengguna memilih tanggal
  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null; // Reset time slot ketika tanggal berganti
    });
  }

  // Method untuk memeriksa apakah slot waktu sudah dipesan
  bool _isTimeSlotBooked(String timeSlot) {
    final String dateKey = _formatDateKey(_selectedDate);
    return _bookedSlots.containsKey(dateKey) &&
        _bookedSlots[dateKey]!.contains(timeSlot);
  }

  // Method untuk menangani booking appointment baru
  void _bookAppointment() {
    if (_nameController.text.isEmpty ||
        _complaintController.text.isEmpty ||
        _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field harus diisi'))
      );
      return;
    }

    // Dalam aplikasi nyata, kode di bawah akan mengirim data ke database/API
    final String dateKey = _formatDateKey(_selectedDate);
    if (!_bookedSlots.containsKey(dateKey)) {
      _bookedSlots[dateKey] = [];
    }
    _bookedSlots[dateKey]!.add(_selectedTimeSlot!);

    // Menambahkan data appointment baru
    _appointments.add({
      'name': _nameController.text,
      'complaint': _complaintController.text,
      'time': _selectedTimeSlot,
      'date': _selectedDate,
    });

    // Reset form
    setState(() {
      _nameController.clear();
      _complaintController.clear();
      _selectedTimeSlot = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Janji temu berhasil dibuat'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Janji Temu',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form untuk membuat janji temu
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Pasien',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Lengkap',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _complaintController,
                              decoration: const InputDecoration(
                                labelText: 'Keluhan',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            _buildDatePicker(),
                            const SizedBox(height: 16),
                            const Text(
                              'Pilih Jam',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _buildTimeTable(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: _bookAppointment,
                                child: const Text('Buat Janji Temu'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Daftar janji temu yang sudah ada
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daftar Janji Temu Hari Ini',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _appointments.isEmpty
                                  ? const Center(
                                child: Text('Belum ada janji temu untuk hari ini'),
                              )
                                  : ListView.builder(
                                itemCount: _appointments.length,
                                itemBuilder: (context, index) {
                                  final appointment = _appointments[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue[100],
                                        child: Text(
                                          appointment['time'],
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      title: Text(appointment['name']),
                                      subtitle: Text(appointment['complaint']),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.more_vert),
                                        onPressed: () {
                                          // Opsi untuk mengedit/menghapus
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk calendar picker
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Tanggal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null && picked != _selectedDate) {
              _onDateChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk membangun timetable
  Widget _buildTimeTable() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _availableTimeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = _availableTimeSlots[index];
        final isBooked = _isTimeSlotBooked(timeSlot);
        final isSelected = timeSlot == _selectedTimeSlot;

        return InkWell(
          onTap: isBooked ? null : () {
            setState(() {
              _selectedTimeSlot = timeSlot;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.grey[300]
                  : isSelected
                  ? Colors.blue
                  : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue[700]! : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                timeSlot,
                style: TextStyle(
                  color: isBooked
                      ? Colors.grey[600]
                      : isSelected
                      ? Colors.white
                      : Colors.blue[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}