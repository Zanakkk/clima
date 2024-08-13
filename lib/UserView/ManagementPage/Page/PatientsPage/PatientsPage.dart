// ignore_for_file: use_build_context_synchronously

import 'package:clima/UserView/ManagementPage/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

import '../../SideBar/SideBar.dart';
import 'DaftarPasien.dart';
import 'LihatPasien.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  String? _selectedGender;
  String? _selectedReligion;
  Uint8List? _imageBytes;
  String? _downloadUrl;
  String? _medicalRecordNumber;

  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 0;
  final bool _isSidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecordNumber();
  }

  Future<void> _fetchMedicalRecordNumber() async {
    final url = Uri.parse(
        '$FULLURL/datapasien.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      final recordCount = data?.length ?? 0;
      setState(() {
        _medicalRecordNumber = (recordCount + 1).toString();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch medical record number.')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });

      await _uploadFile(pickedFile);
    }
  }

  Future<void> _uploadFile(XFile file) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('patient_images/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putData(await file.readAsBytes());

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

  Future<void> _submitData() async {
    if (_formKey.currentState?.validate() ?? false) {
      final url = Uri.parse(
          '$FULLURL/datapasien.json');

      final response = await http.post(
        url,
        body: json.encode({
          'fullName': _fullNameController.text,
          'nik': _nikController.text,
          'gender': _selectedGender,
          'dob': _dobController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'religion': _selectedReligion,
          'pekerjaan': _pekerjaanController.text,
          'medicalRecordNumber': _medicalRecordNumber,
          'imageUrl': _downloadUrl, // Masukkan link download gambar
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data successfully submitted!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit data.')),
        );
      }
    }
  }

  Widget _buildSidebar() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SidebarItem(
          icon: Icons.person_add,
          label: 'Tambah Pasien',
          isActive: _selectedIndex == 0,
          isExpanded: _isSidebarExpanded,
          onTap: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        ),
        SidebarItem(
          icon: Icons.visibility,
          label: 'Lihat Pasien',
          isActive: _selectedIndex == 1,
          isExpanded: _isSidebarExpanded,
          onTap: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
        ),
        SidebarItem(
          icon: Icons.list,
          label: 'Daftar Pasien',
          isActive: _selectedIndex == 2,
          isExpanded: _isSidebarExpanded,
          onTap: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildAddPatientForm();
      case 1:
        return const PatientListPage();
      case 2:
        return const DaftarTindakanPasien();
      default:
        return _buildAddPatientForm();
    }
  }

  Widget _buildAddPatientForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const Text(
            'Personal Identification Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_medicalRecordNumber != null)
            Text(
              'Nomor Rekam Medis: $_medicalRecordNumber',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nikController,
            decoration: const InputDecoration(
              labelText: 'National ID Number (NIK)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your NIK';
              } else if (value.length != 16) {
                return 'NIK harus terdiri dari 16 digit';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            items: ['Male', 'Female']
                .map((gender) => DropdownMenuItem(
              value: gender,
              child: Text(gender),
            ))
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your gender';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dobController,
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              border: OutlineInputBorder(),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _dobController.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your date of birth';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedReligion,
            items:
            ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu']
                .map((religion) => DropdownMenuItem(
              value: religion,
              child: Text(religion),
            ))
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Religion',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _selectedReligion = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your religion';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pekerjaanController,
            decoration: const InputDecoration(
              labelText: 'Pekerjaan',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your pekerjaan';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload Photo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_imageBytes != null)
            Image.memory(
              _imageBytes!,
              height: 150,
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitData,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasien'),
        automaticallyImplyLeading: false, // Hapus tombol back
      ),
      body: Row(
        children: [
          SizedBox(
            width: _isSidebarExpanded ? 250 : 80,
            child: _buildSidebar(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }
}
