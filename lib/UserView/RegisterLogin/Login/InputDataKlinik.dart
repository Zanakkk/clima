import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../main.dart';

class ClinicRegistrationPage extends StatefulWidget {
  const ClinicRegistrationPage({super.key});

  @override
  _ClinicRegistrationPageState createState() => _ClinicRegistrationPageState();
}

class _ClinicRegistrationPageState extends State<ClinicRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
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
      _downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _downloadUrl = _downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: $e')),
      );
    }
  }

  Future<void> _registerClinic() async {
    final String clinicName = _nameController.text.trim();
    final String clinicAddress = _addressController.text.trim();
    final String clinicEmail = FirebaseAuth.instance.currentUser!.email!;
    final String endpoint = _generateEndpoint(clinicName);

    if (clinicName.isEmpty || clinicAddress.isEmpty || _downloadUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all the fields and upload a logo.")),
      );
      return;
    }

    final String url = '$URL/clinics/$endpoint.json';

    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode({
          'name': clinicName,
          'address': clinicAddress,
          'email': clinicEmail,
          'logo': _downloadUrl,
        }),
      );

      if (response.statusCode == 200) {
        copyFirebaseData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Clinic registered successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to register clinic. Status code: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  Future<void> copyFirebaseData() async {
    // Source and target URLs
    final String sourceUrl =
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/.json';
    final String targetUrl =
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/zanakdental5651.json';

    try {
      // Fetch data from the source URL
      final sourceResponse = await http.get(Uri.parse(sourceUrl));

      if (sourceResponse.statusCode == 200) {
        // Decode the JSON data
        final Map<String, dynamic> data = json.decode(sourceResponse.body);

        // Write data to the target URL
        final targetResponse = await http.put(
          Uri.parse(targetUrl),
          body: json.encode(data),
        );

        if (targetResponse.statusCode == 200) {
          print('Data successfully copied to the target URL.');
        } else {
          print(
              'Failed to copy data. Status code: ${targetResponse.statusCode}');
        }
      } else {
        print(
            'Failed to fetch data from the source URL. Status code: ${sourceResponse.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
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
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Make elements fill the available width
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Clinic Name',
                        border:
                            OutlineInputBorder(), // Adding a border for better UI
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Clinic Address',
                        border:
                            OutlineInputBorder(), // Adding a border for better UI
                      ),
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _registerClinic,
                      child: const Text('Register Clinic'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
