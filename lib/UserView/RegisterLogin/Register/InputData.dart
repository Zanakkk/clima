// ignore_for_file: avoid_web_libraries_in_flutter, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../ManagementPage/HomePage.dart';
import '../VerificationWindow.dart';

class ClinicRegistrationPage extends StatefulWidget {
  const ClinicRegistrationPage({super.key});

  @override
  _ClinicRegistrationPageState createState() => _ClinicRegistrationPageState();
}

class _ClinicRegistrationPageState extends State<ClinicRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordManagementController =
      TextEditingController();
  Uint8List? _imageBytes;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _downloadUrl;
  String _selectedPlan = "Basic"; // Default plan

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (kIsWeb) {
          _imageBytes = bytes;
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
      await _uploadFile(pickedFile);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    }
  }

  Future<void> _uploadFile(XFile file) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('clinic_logos/${DateTime.now().toIso8601String()}.png');
      final uploadTask = kIsWeb
          ? storageRef.putData(_imageBytes!)
          : storageRef.putFile(_imageFile!);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _downloadUrl = downloadUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: $e')),
        );
      }
    }
  }

  Future<void> _registerClinic() async {
    final String clinicName = _nameController.text.trim();
    final String clinicAddress = _addressController.text.trim();
    final String passwordManagement = _passwordManagementController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        _showSnackBar("User is not logged in. Please log in first.");
      }
      return;
    }

    final String clinicEmail = user.email!;
    final String endpoint = _generateEndpoint(clinicName);

    // Validasi untuk form
    if (clinicName.isEmpty ||
        clinicAddress.isEmpty ||
        _downloadUrl == null ||
        passwordManagement.isEmpty) {
      _showSnackBar(
          "Please fill all the fields, upload a logo, and set a password.");
      return;
    }

    // Menentukan nilai controllerclinic berdasarkan plan yang dipilih
    List<bool> listcontroller = _generateControllerList(_selectedPlan);

    final String url =
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/$endpoint.json';

    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode({
          'name': clinicName,
          'address': clinicAddress,
          'email': clinicEmail,
          'logo': _downloadUrl,
          'passwordManagement': passwordManagement,
          'Clima': {
            'ClimaPlan': _selectedPlan,
            'ClimaActive': false, // Default false for activation
            'ClimaDate': '',
            'controllerclinic': listcontroller,
          },
        }),
      );

      if (response.statusCode == 200) {
        FULLURL =
            'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/$endpoint.json';

        final newUrl = Uri.base.replace(path: '/$endpoint');
        html.window.history.pushState(null, '', newUrl.toString());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ActivationPage(),
          ),
        );

        _showSnackBar("Clinic registered successfully!");
      } else {
        _showSnackBar(
            "Failed to register clinic. Status code: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    }
  }

  List<bool> _generateControllerList(String plan) {
    List<bool> controllerList;

    switch (plan) {
      case 'Basic':
        // Basic: nomor 0, 2, 3, 4, 6, 10, 11 true, sisanya false
        controllerList = List.filled(22, false);
        controllerList[0] = true;
        controllerList[2] = true;
        controllerList[3] = true;
        controllerList[4] = true;
        controllerList[6] = true;
        controllerList[11] = true;
        controllerList[12] = true;
        controllerList[13] = true;
        controllerList[14] = true;
        controllerList[17] = true;
        controllerList[19] = true;
        break;

      case 'Advanced':
        // Advanced: Semua true kecuali nomor terakhir
        controllerList = List.filled(22, true);
        controllerList[18] = false;
        controllerList[22] = false;
        break;

      case 'Pro':
        // Pro: Semua true
        controllerList = List.filled(22, true);
        break;

      default:
        controllerList = List.filled(
            22, false); // Default, semua false jika tidak ada plan yang dipilih
        break;
    }

    return controllerList;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _generateEndpoint(String clinicName) {
    final String nameWithoutSpaces =
        clinicName.replaceAll(' ', '').toLowerCase();
    final String randomDigits =
        Random().nextInt(9000).toString().padLeft(4, '0');
    return '$nameWithoutSpaces$randomDigits';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Clinic'),
      ),
      body: Column(
        children: [
          Center(
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                width: 1200,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: Colors.black.withOpacity(0.6),
                      width: 5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Bagian Kiri - Gambar dan Teks
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: Colors.black.withOpacity(0.6),
                                width: 5,
                              ),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: (_imageBytes != null ||
                                          _imageFile != null)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: kIsWeb
                                              ? Image.memory(_imageBytes!)
                                              : Image.file(_imageFile!),
                                        )
                                      : const Center(
                                          child: Text("No image selected"),
                                        ),
                                )),
                          ),
                        ),
                      ),
                      // Bagian Kanan - Form Login
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 48.0, horizontal: 48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                children: [
                                  SizedBox(height: 24),
                                  Text(
                                    'Input Data Klinik',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                ],
                              ),
                              Column(
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Clinic Name',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _addressController,
                                    decoration: const InputDecoration(
                                      labelText: 'Clinic Address',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _passwordManagementController,
                                    decoration: const InputDecoration(
                                      labelText: 'Management Password',
                                      border: OutlineInputBorder(),
                                    ),
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _selectedPlan,
                                    decoration: const InputDecoration(
                                      labelText: 'Plan CLIMA',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "Basic",
                                        child: Text("Basic"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Advanced",
                                        child: Text("Advanced"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Pro",
                                        child: Text("Pro"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Custom",
                                        child: Text("Custom"),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPlan = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Select Logo'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _registerClinic,
                                child: const Text('Register Clinic'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
