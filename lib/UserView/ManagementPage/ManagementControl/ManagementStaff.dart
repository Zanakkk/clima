// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../HomePage.dart';

class Staff {
  String id;
  String name;
  String position;
  String password; // Tambahkan password di model

  Staff({required this.id, required this.name, required this.position, required this.password});

  factory Staff.fromMap(String id, Map<String, dynamic> data) {
    return Staff(
      id: id,
      name: data['name'] as String,
      position: data['position'] as String,
      password: data['password'] as String, // Tambahkan password dalam fromMap
    );
  }
}

class ManagementStaffPage extends StatefulWidget {
  const ManagementStaffPage({super.key});

  @override
  _ManagementStaffPageState createState() => _ManagementStaffPageState();
}

class _ManagementStaffPageState extends State<ManagementStaffPage> {
  final String databaseUrl = '$FULLURL/staff.json';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Tambahkan controller untuk password

  List<Staff> staffList = [];
  String? selectedStaffId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    try {
      final response = await http.get(Uri.parse(databaseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        List<Staff> staffMembers = [];

        data.forEach((key, value) {
          staffMembers.add(Staff.fromMap(key, value));
        });

        setState(() {
          staffList = staffMembers;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load staff');
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

  void _deleteStaff(String staffId) async {
    final deleteUrl = '$FULLURL/staff/$staffId.json';
    try {
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        _fetchStaff();
      } else {
        throw Exception('Failed to delete staff');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  void _submitStaff() async {
    final String name = _nameController.text.trim();
    final String position = _positionController.text.trim();
    final String password = _passwordController.text.trim(); // Tambahkan password

    if (name.isEmpty || position.isEmpty || password.isEmpty) { // Periksa validasi password
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    try {
      final body = json.encode({
        'name': name,
        'position': position,
        'password': password, // Tambahkan password ke dalam request body
      });

      if (selectedStaffId == null) {
        // Tambah staf baru
        final response = await http.post(
          Uri.parse(databaseUrl),
          body: body,
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          _fetchStaff();
        }
      } else {
        // Edit staf yang sudah ada
        final editUrl = '$FULLURL/staff/$selectedStaffId.json';
        final response = await http.put(
          Uri.parse(editUrl),
          body: body,
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          _fetchStaff();
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
    _positionController.clear();
    _passwordController.clear(); // Bersihkan password setelah submit
    setState(() {
      selectedStaffId = null;
    });
  }

  void _editStaff(Staff staff) {
    setState(() {
      selectedStaffId = staff.id;
      _nameController.text = staff.name;
      _positionController.text = staff.position;
      _passwordController.text = staff.password; // Tambahkan password ke form jika diedit
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Staff'),
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
              height: 320, // Sesuaikan tinggi untuk memasukkan password
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
                            labelText: 'Staff Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _positionController,
                          decoration: const InputDecoration(
                            labelText: 'Position',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _passwordController, // Tambahkan TextField untuk password
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true, // Password tersembunyi
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: _submitStaff,
                          child: Text(selectedStaffId == null
                              ? 'Add Staff'
                              : 'Update Staff'),
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
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    final staff = staffList[index];
                    return ListTile(
                      title: Text(staff.name),
                      subtitle: Text(staff.position),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editStaff(staff);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteStaff(staff.id);
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
