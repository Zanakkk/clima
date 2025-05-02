// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../HomePage.dart';
import 'IDCARD.dart';

import 'package:intl/intl.dart';

// Model class for Appointment
class Appointment {
  final String id;
  final String patientName;
  final String complaint;
  final DateTime date;
  final String timeSlot;
  final String phoneNumber;
  final bool isConfirmed;

  Appointment({
    required this.id,
    required this.patientName,
    required this.complaint,
    required this.date,
    required this.timeSlot,
    required this.phoneNumber,
    this.isConfirmed = false,
  });

  // Convert from JSON to use when getting data from Firebase/database
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      patientName: json['patientName'] ?? '',
      complaint: json['complaint'] ?? '',
      date: DateTime.parse(json['date']),
      timeSlot: json['timeSlot'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isConfirmed: json['isConfirmed'] ?? false,
    );
  }

  // Convert to JSON to send to Firebase/database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'complaint': complaint,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'phoneNumber': phoneNumber,
      'isConfirmed': isConfirmed,
    };
  }
}

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReservationPageMasyarakat()));
            },
            child: const Text('Buat Reservasi')),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReservationResultsPage()));
            },
            child: const Text('Lihat Semua Reservasi')),
        const IDCard(),
      ],
    );
  }
}

class ReservationPageMasyarakat extends StatefulWidget {
  const ReservationPageMasyarakat({super.key});

  @override
  _ReservationPageMasyarakatState createState() =>
      _ReservationPageMasyarakatState();
}

class _ReservationPageMasyarakatState extends State<ReservationPageMasyarakat> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _complaintController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableTimeSlots = [];
  bool _isLoadingTimeSlots = false;

  // Generate all time slots from 9 AM to 12 AM (midnight)
  List<String> _generateAllTimeSlots() {
    List<String> slots = [];
    for (int hour = 9; hour <= 23; hour++) {
      // Format hours to display properly (e.g., 09:00, 10:00)
      final hourString = hour.toString().padLeft(2, '0');
      slots.add('$hourString:00');
      slots.add('$hourString:30');
    }
    // Add midnight slot
    slots.add('00:00');
    return slots;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 30)), // Allow booking up to 30 days ahead
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _selectedTimeSlot = null; // Reset time slot when date changes
      });

      // Load available time slots for the selected date
      _loadAvailableTimeSlots();
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoadingTimeSlots = true;
    });

    try {
      // Generate all possible time slots
      List<String> allTimeSlots = _generateAllTimeSlots();

      // Fetch existing appointments for the selected date
      final url = Uri.parse('$FULLURL/reservation.json');
      final response = await http.get(url);

      if (response.statusCode == 200 && response.body != "null") {
        final Map<String, dynamic> data = json.decode(response.body);
        final String selectedDateStr =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);

        // Filter out booked time slots
        List<String> bookedTimeSlots = [];

        data.forEach((key, value) {
          if (value['date'] != null) {
            final appointmentDate =
                DateTime.parse(value['date']).toString().split(' ')[0];
            if (appointmentDate == selectedDateStr &&
                value['timeSlot'] != null) {
              bookedTimeSlots.add(value['timeSlot']);
            }
          }
        });

        // Remove booked time slots from available slots
        _availableTimeSlots = allTimeSlots
            .where((slot) => !bookedTimeSlots.contains(slot))
            .toList();
      } else {
        // If no data or error, all slots are available
        _availableTimeSlots = allTimeSlots;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading time slots: $e')),
      );
      _availableTimeSlots = [];
    } finally {
      setState(() {
        _isLoadingTimeSlots = false;
      });
    }
  }

  Future<void> _submitReservation() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTimeSlot != null) {
      try {
        // Generate a unique ID based on timestamp
        String id = DateTime.now().millisecondsSinceEpoch.toString();

        final appointment = Appointment(
          id: id,
          patientName: _nameController.text,
          complaint: _complaintController.text,
          date: _selectedDate!,
          timeSlot: _selectedTimeSlot!,
          phoneNumber: _phoneController.text,
        );

        final url = Uri.parse('$FULLURL/reservation.json');
        final response = await http.post(
          url,
          body: json.encode(appointment.toJson()),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reservasi berhasil dikirim!')),
          );

          // Clear the form
          _nameController.clear();
          _phoneController.clear();
          _dateController.clear();
          _complaintController.clear();
          setState(() {
            _selectedDate = null;
            _selectedTimeSlot = null;
            _availableTimeSlots = [];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal mengirim reservasi: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Reservasi'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat Reservasi Baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan nama Anda';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan nomor telepon Anda';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Kunjungan',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon pilih tanggal kunjungan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedDate != null)
                  _isLoadingTimeSlots
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih Jam Kunjungan:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (_availableTimeSlots.isEmpty)
                              const Text(
                                'Tidak ada slot waktu yang tersedia pada tanggal ini.',
                                style: TextStyle(color: Colors.red),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableTimeSlots.map((timeSlot) {
                                  return ChoiceChip(
                                    label: Text(timeSlot),
                                    selected: _selectedTimeSlot == timeSlot,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedTimeSlot =
                                            selected ? timeSlot : null;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                TextFormField(
                  controller: _complaintController,
                  decoration: const InputDecoration(
                      labelText: 'Keluhan/Tujuan Kunjungan'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan keluhan atau tujuan kunjungan Anda';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child: const Text('Kirim Reservasi',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReservationResultsPage extends StatefulWidget {
  const ReservationResultsPage({super.key});

  @override
  _ReservationResultsPageState createState() => _ReservationResultsPageState();
}

class _ReservationResultsPageState extends State<ReservationResultsPage> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _confirmAppointment(String appointmentId) async {
    try {
      final url = Uri.parse('$FULLURL/reservation/$appointmentId.json');

      // Kirim permintaan PATCH untuk memperbarui status reservasi menjadi dikonfirmasi
      final response = await http.patch(
        url,
        body: json.encode({'isConfirmed': true}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservasi berhasil dikonfirmasi!')),
        );

        // Refresh daftar reservasi setelah konfirmasi berhasil
        _fetchAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mengonfirmasi reservasi: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> _fetchAppointments() async {
    try {
      final url = Uri.parse('$FULLURL/reservation.json');
      final response = await http.get(url);

      if (response.statusCode == 200 && response.body != "null") {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<Appointment> loadedAppointments = [];

        data.forEach((key, value) {
          // Include Firebase key as ID if it's not in the data
          final appointment = Appointment(
            id: value['id'] ?? key,
            patientName: value['patientName'] ?? value['name'] ?? '',
            complaint: value['complaint'] ?? value['purpose'] ?? '',
            date: DateTime.parse(value['date']),
            timeSlot: value['timeSlot'] ?? value['time'] ?? '',
            phoneNumber: value['phoneNumber'] ?? value['phone'] ?? '',
            isConfirmed: value['isConfirmed'] ?? false,
          );
          loadedAppointments.add(appointment);
        });

        // Sort appointments by date and time
        loadedAppointments.sort((a, b) {
          int dateComparison = a.date.compareTo(b.date);
          if (dateComparison != 0) return dateComparison;
          return a.timeSlot.compareTo(b.timeSlot);
        });

        setState(() {
          _appointments = loadedAppointments;
          _isLoading = false;
        });
      } else {
        setState(() {
          _appointments = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data reservasi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Results'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.blue[50],
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  final reservation = _appointments[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                          '${reservation.patientName} - ${DateFormat('yyyy-MM-dd').format(reservation.date)}'),
                      subtitle: Text(
                        'Time: ${reservation.timeSlot}\nPhone: ${reservation.phoneNumber}\nPurpose: ${reservation.complaint}',
                      ),
                      trailing: reservation.isConfirmed
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () =>
                                  _confirmAppointment(reservation.id),
                              child: const Text('Konfirmasi'),
                            ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
