// ignore_for_file: avoid_web_libraries_in_flutter, library_private_types_in_public_api, use_build_context_synchronously

import 'package:clima/UserView/RegisterLogin/Login/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../ManagementPage/HomePage.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _registerUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User registered successfully!")),
      );

      // Navigate to the home page or dashboard after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const ClinicRegistrationPage()), // Define your HomePage
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Register'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("User is not logged in. Please log in first.")),
        );
      }
      return;
    }

    final String clinicEmail = user.email!;
    final String endpoint = _generateEndpoint(clinicName);

    if (clinicName.isEmpty ||
        clinicAddress.isEmpty ||
        _downloadUrl == null ||
        passwordManagement.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Please fill all the fields, upload a logo, and set a password.")),
        );
      }
      return;
    }

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
        }),
      );

      if (response.statusCode == 200) {
        FULLURL =
            'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/$endpoint.json';

        final newUrl = Uri.base.replace(path: '/$endpoint');
        html.window.history.pushState(null, '', newUrl.toString());

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(id: endpoint),
            ),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Clinic registered successfully!")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Failed to register clinic. Status code: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            if (_imageBytes != null || _imageFile != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.memory(_imageBytes!)
                      : Image.file(_imageFile!),
                ),
              )
            else
              const Text("No image selected"),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Select Logo'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _registerClinic,
              child: const Text('Register Clinic'),
            ),
          ],
        ),
      ),
    );
  }
}
