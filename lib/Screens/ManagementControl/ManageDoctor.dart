// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../HomePage.dart';


class Doctor {
  String id;
  String name;
  String sip;

  Doctor({required this.id, required this.name, required this.sip});

  factory Doctor.fromMap(String id, Map<String, dynamic> data) {
    return Doctor(
      id: id,
      name: data['name'] as String,
      sip: data['sip'] as String,
    );
  }
}

class ManagementDoctorPage extends StatefulWidget {
  const ManagementDoctorPage({super.key});

  @override
  _ManagementDoctorPageState createState() => _ManagementDoctorPageState();
}

class _ManagementDoctorPageState extends State<ManagementDoctorPage> {
  final String databaseUrl = '$FULLURL/dokter.json';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sipController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // Add this line

  List<Doctor> doctors = [];
  String? selectedDoctorId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final response = await http.get(Uri.parse(databaseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        List<Doctor> doctorList = [];

        data.forEach((key, value) {
          doctorList.add(Doctor.fromMap(key, value));
        });

        setState(() {
          doctors = doctorList;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load doctors');
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

  void _deleteDoctor(String doctorId) async {
    final deleteUrl = '$FULLURL/dokter/$doctorId.json';
    try {
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        _fetchDoctors();
      } else {
        throw Exception('Failed to delete doctor');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  void _submitDoctor() async {
    final String name = _nameController.text.trim();
    final String sip = _sipController.text.trim();
    final String password = _passwordController.text.trim(); // Add this line

    if (name.isEmpty || sip.isEmpty || password.isEmpty) {
      // Update validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    try {
      final body = json.encode({
        'name': name,
        'sip': sip,
        'password': password, // Include the password in the request body
      });

      if (selectedDoctorId == null) {
        // Add new doctor
        final response = await http.post(
          Uri.parse(databaseUrl),
          body: body,
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          _fetchDoctors();
        }
      } else {
        // Edit existing doctor
        final editUrl = '$FULLURL/dokter/$selectedDoctorId.json';
        final response = await http.put(
          Uri.parse(editUrl),
          body: body,
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          _fetchDoctors();
        }
      }

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _sipController.clear();
    _passwordController.clear(); // Clear password field
    setState(() {
      selectedDoctorId = null;
    });
  }

  void _editDoctor(Doctor doctor) {
    setState(() {
      selectedDoctorId = doctor.id;
      _nameController.text = doctor.name;
      _sipController.text = doctor.sip;
      // You may or may not set the password here depending on the flow you want
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Doctors'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Container
            Container(
              width: 400,
              height: 300, // Adjust height for the new password field
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.teal.withOpacity(0.6), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Doctor Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextField(
                                controller: _sipController,
                                decoration: const InputDecoration(
                                  labelText: 'SIP',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextField(
                                controller:
                                    _passwordController, // Add password input
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true, // To hide password text
                              ),
                              const SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: _submitDoctor,
                                child: Text(selectedDoctorId == null
                                    ? 'Add Doctor'
                                    : 'Update Doctor'),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20.0),
            // List Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.teal.withOpacity(0.6), width: 2),
                ),
                child: ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return ListTile(
                      title: Text(doctor.name),
                      subtitle: Text(doctor.sip),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editDoctor(doctor);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteDoctor(doctor.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
