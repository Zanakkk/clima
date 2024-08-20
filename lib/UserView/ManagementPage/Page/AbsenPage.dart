// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../HomePage.dart';

// Daftar 8 warna
final List<Color> colors = [
  Colors.red,
  Colors.blue,
  Colors.teal,
  Colors.orange,
  Colors.purple,
  Colors.black,
  Colors.brown,
  Colors.green,
];

// Fungsi untuk mendapatkan warna acak dari daftar warna
Color getRandomColor() {
  final random = Random();
  return colors[random.nextInt(colors.length)];
}

class Absen extends StatefulWidget {
  const Absen({super.key});

  @override
  _AbsenState createState() => _AbsenState();
}

class _AbsenState extends State<Absen> {
  final String dokterUrl =
      'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/klinikident3558/dokter.json';
  final String staffUrl =
      'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/klinikident3558/staff.json';

  List<Map<String, dynamic>> dokterList = [];
  List<Map<String, dynamic>> staffList = [];
  bool isLoading = true;
  Map<String, bool> alreadyAbsent =
      {}; // Map to track who has already checked in

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dokterResponse = await http.get(Uri.parse(dokterUrl));
      final staffResponse = await http.get(Uri.parse(staffUrl));

      if (dokterResponse.statusCode == 200 && staffResponse.statusCode == 200) {
        final dokterData =
            json.decode(dokterResponse.body) as Map<String, dynamic>;
        final staffData =
            json.decode(staffResponse.body) as Map<String, dynamic>;

        final today =
            "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}";
        final absenResponse =
            await http.get(Uri.parse('$FULLURL/absen/$today.json'));

        if (absenResponse.statusCode == 200) {
          final absenData =
              json.decode(absenResponse.body) as Map<String, dynamic>?;

          // Fill alreadyAbsent map with names of people who have already checked in
          if (absenData != null) {
            absenData.forEach((key, value) {
              alreadyAbsent[value['name']] = true;
            });
          }
        }

        setState(() {
          dokterList = dokterData.entries.map((entry) {
            return {
              'id': entry.key,
              'name': entry.value['name'],
              'sip': entry.value['sip'],
              'password': entry.value['password'],
              'status': 'dokter'
            };
          }).toList();

          staffList = staffData.entries.map((entry) {
            return {
              'id': entry.key,
              'name': entry.value['name'],
              'position': entry.value['position'],
              'password': entry.value['password'],
              'status': 'staff'
            };
          }).toList();

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  Future<void> _showPasswordDialog(Map<String, dynamic> person) async {
    final TextEditingController passwordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Masukkan Password untuk ${person['name']}"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Password"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Absen"),
              onPressed: () {
                _handleAbsen(person, passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void _handleAbsen(Map<String, dynamic> person, String inputPassword) async {
    Navigator.of(context).pop(); // Tutup dialog setelah tombol "Absen" diklik
    if (inputPassword == person['password']) {
      // Password cocok, lakukan post data
      try {
        final timestamp = DateTime.now().toIso8601String();
        final today =
            "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}";

        final response = await http.post(
          Uri.parse('$FULLURL/absen/$today.json'),
          body: json.encode({
            'name': person['name'],
            'timestamp': timestamp,
            'status': person['status']
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            alreadyAbsent[person['name']] = true; // Mark person as absent
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Absen berhasil")),
          );
        } else {
          throw Exception('Failed to submit attendance');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred: $e")),
        );
      }
    } else {
      // Password salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password anda salah")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Halaman Absen'),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dokter',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: GridView.builder(
                        itemCount: dokterList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, // Number of columns in the grid
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              1, // Ensures each cell is a square (1:1 ratio)
                        ),
                        itemBuilder: (context, index) {
                          final dokter = dokterList[index];
                          final isAlreadyAbsent =
                              alreadyAbsent[dokter['name']] ?? false;
                          final color = getRandomColor();

                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color.withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dokter['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'SIP: ${dokter['sip']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: color.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: isAlreadyAbsent
                                        ? null
                                        : () => _showPasswordDialog(dokter),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          color, // Set button color
                                    ),
                                    child: Text(
                                      isAlreadyAbsent ? "Sudah Absen" : "Absen",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Staff',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: GridView.builder(
                        itemCount: staffList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, // Number of columns in the grid
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              1, // Ensures each cell is a square (1:1 ratio)
                        ),
                        itemBuilder: (context, index) {
                          final staff = staffList[index];
                          final isAlreadyAbsent =
                              alreadyAbsent[staff['name']] ?? false;
                          final color = getRandomColor();

                          return Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color.withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    staff['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Position: ${staff['position']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: color.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: isAlreadyAbsent
                                        ? null
                                        : () => _showPasswordDialog(staff),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          color, // Set button color
                                    ),
                                    child: Text(
                                      isAlreadyAbsent ? "Sudah Absen" : "Absen",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ));
  }
}
