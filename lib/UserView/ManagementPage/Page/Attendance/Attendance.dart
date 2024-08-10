import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendancePage extends StatelessWidget {
  final String id;

  const AttendancePage({super.key, required this.id});

  Future<void> _updateAttendance(String id) async {
    final url = Uri.parse(
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/absen/$id.json');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(true),
    );

    if (response.statusCode == 200) {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final qrData =
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/absen/$id.json';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Absensi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'ID: $id',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text(
              'Scan QR Code below to mark your attendance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateAttendance(id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Attendance marked successfully')),
                );
              },
              child: const Text('Mark Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}
