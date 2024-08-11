// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../main.dart';
import 'Attendance/Attendance.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final List<Map<String, dynamic>> staffMembers = [
    {
      'id': '12345',
      'name': 'John Doe',
      'role': 'Admin',
      'profileImage': 'https://randomuser.me/api/portraits/men/1.jpg',
      'email': 'john.doe@example.com',
      'phone': '123-456-7890',
    },
    {
      'id': '67890',
      'name': 'Jane Smith',
      'role': 'Perawat',
      'profileImage': 'https://randomuser.me/api/portraits/women/1.jpg',
      'email': 'jane.smith@example.com',
      'phone': '123-456-7891',
    },
    // Tambahkan lebih banyak staf di sini...
  ];

  Map<String, bool> attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    _fetchAttendanceStatus();
  }

  Future<void> _fetchAttendanceStatus() async {
    final url = Uri.parse(
        '$URL/absen.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        setState(() {
          attendanceStatus =
              data.map((key, value) => MapEntry(key, value as bool));
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch attendance status.')),
      );
    }
  }

  String generateUpdateAttendanceUrl(String id) {
    const baseUrl =
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app';
    final attendanceUrl = '$baseUrl/absen/$id.json';

    // Meng-encode URL untuk melakukan PUT request
    final updateUrl = attendanceUrl;

    return updateUrl;
  }

  void _generateQRCode(String id) {
    final qrData = generateUpdateAttendanceUrl(id);

    showDialog(
      context: context,
      builder: (context) => _buildQRCodeDialog(qrData),
    );
  }

  Widget _buildStaffList(List<Map<String, dynamic>> staffList, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AttendancePage(
                            id: '',
                          )));
            },
            child: const Text('Absen')),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              final id = staff['id'];
              final isAbsent = attendanceStatus[id] ?? false;

              return Card(
                color: isAbsent ? Colors.purple[100] : Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(staff['profileImage'] ?? ''),
                  ),
                  title: Text(staff['name'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staff['role'] ?? 'No Role Specified'),
                      Text(staff['email'] ?? 'No Email Provided'),
                      Text(staff['phone'] ?? 'No Phone Number Provided'),
                    ],
                  ),
                  trailing: isAbsent
                      ? const Text('Sudah Absen',
                          style: TextStyle(color: Colors.green))
                      : ElevatedButton(
                          onPressed: () => _generateQRCode(id),
                          child: const Text('Absen'),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeDialog(String qrData) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scan QR Code to Mark Attendance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 16),
            // Tidak ada tombol di sini, hanya QR Code
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff List with Attendance'),
        automaticallyImplyLeading: false, // Nonaktifkan tombol kembali
      ),
      body: Row(
        children: [
          if (staffMembers
              .where((staff) => staff['role'] == 'Admin')
              .isNotEmpty)
            Expanded(
              child: _buildStaffList(
                  staffMembers
                      .where((staff) => staff['role'] == 'Admin')
                      .toList(),
                  'Admin'),
            ),
          if (staffMembers
              .where((staff) => staff['role'] == 'Perawat')
              .isNotEmpty)
            Expanded(
              child: _buildStaffList(
                  staffMembers
                      .where((staff) => staff['role'] == 'Perawat')
                      .toList(),
                  'Perawat'),
            ),
          if (staffMembers
              .where((staff) => staff['role'] == 'Dokter')
              .isNotEmpty)
            Expanded(
              child: _buildStaffList(
                  staffMembers
                      .where((staff) => staff['role'] == 'Dokter')
                      .toList(),
                  'Dokter'),
            ),
        ],
      ),
    );
  }
}
