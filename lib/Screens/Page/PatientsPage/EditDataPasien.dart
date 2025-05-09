// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Constants - for consistency, using the same colors as in the main app
const Color primaryColor = Color(0xFF4F6AFF);
const Color secondaryColor = Color(0xFF8C9EFF);
const Color backgroundColor = Color(0xFFF5F7FF);
const Color textColor = Color(0xFF2C3E50);

class EditPatientPage extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const EditPatientPage({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  State<EditPatientPage> createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _nikController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _pekerjaanController;
  late String? _selectedGender;
  late String? _selectedReligion;
  Uint8List? _imageBytes;
  String? _medicalRecordNumber;
  String? _currentImageUrl;
  bool _isImageChanged = false;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers with patient data
    _fullNameController = TextEditingController(text: widget.patientData['fullName'] ?? '');
    _dobController = TextEditingController(text: widget.patientData['dob'] ?? '');
    _nikController = TextEditingController(text: widget.patientData['nik'] ?? '');
    _addressController = TextEditingController(text: widget.patientData['address'] ?? '');
    _phoneController = TextEditingController(text: widget.patientData['phone'] ?? '');
    _emailController = TextEditingController(text: widget.patientData['email'] ?? '');
    _pekerjaanController = TextEditingController(text: widget.patientData['pekerjaan'] ?? '');
    _selectedGender = widget.patientData['gender'];
    _selectedReligion = widget.patientData['religion'];
    _medicalRecordNumber = widget.patientData['medicalRecordNumber'];
    _currentImageUrl = widget.patientData['imageUrl'];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _nikController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  Future<void> _updatePatientData() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Handle image upload if the image has been changed
        String? imageUrl = _currentImageUrl;
        if (_isImageChanged && _imageBytes != null) {
          imageUrl = await _uploadImage();
        }

        // Prepare updated patient data
        final updatedPatientData = {
          'fullName': _fullNameController.text,
          'nik': _nikController.text,
          'gender': _selectedGender,
          'dob': _dobController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'religion': _selectedReligion,
          'pekerjaan': _pekerjaanController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Only update image URL if the image was changed
        if (_isImageChanged) {
          updatedPatientData['imageUrl'] = imageUrl;
        }

        // Update Firestore document
        await FirebaseFirestore.instance
            .collection('pasien')
            .doc(widget.patientId)
            .update(updatedPatientData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data pasien berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating patient data: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui data: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isImageChanged = true;
        });
      } else {
        final File imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isImageChanged = true;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return null;

    try {
      final String fileName = '${_nikController.text}_${DateTime.now().millisecondsSinceEpoch}';
      final Reference storageRef = FirebaseStorage.instance.ref().child('patient_images/$fileName');

      final UploadTask uploadTask = storageRef.putData(_imageBytes!);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to upload image: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah gambar: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Data Pasien',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Header section
                  const Text(
                    'Edit Data Pasien',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Silakan perbarui data pasien',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const Divider(height: 30),

                  // Medical Record Number section
                  if (_medicalRecordNumber != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Nomor Rekam Medis: $_medicalRecordNumber',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Photo upload section
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Foto Pasien',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _imageBytes != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                              : _currentImageUrl != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _currentImageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                              : const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Kamera'),
                              onPressed: () => _pickImage(ImageSource.camera),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galeri'),
                              onPressed: () => _pickImage(ImageSource.gallery),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form fields
                  const Text(
                    'Data Pribadi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Responsive grid layout
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width - 80
                            : (MediaQuery.of(context).size.width - 120) / 2,
                        child: TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: const Icon(Icons.person, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan nama lengkap';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width - 80
                            : (MediaQuery.of(context).size.width - 120) / 2,
                        child: TextFormField(
                          controller: _nikController,
                          decoration: InputDecoration(
                            labelText: 'NIK',
                            prefixIcon: const Icon(Icons.badge, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan NIK';
                            } else if (value.length != 16) {
                              return 'NIK harus terdiri dari 16 digit';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width - 80
                            : (MediaQuery.of(context).size.width - 120) / 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          items: ['Laki-laki', 'Perempuan']
                              .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'Jenis Kelamin',
                            prefixIcon: const Icon(Icons.people, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon pilih jenis kelamin';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width - 80
                            : (MediaQuery.of(context).size.width - 120) / 2,
                        child: TextFormField(
                          controller: _dobController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Lahir',
                            prefixIcon: const Icon(Icons.calendar_today, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: primaryColor,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan tanggal lahir';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width - 80
                            : (MediaQuery.of(context).size.width - 120) / 2,
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Nomor Telepon',
                            prefixIcon: const Icon(Icons.phone, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan nomor telepon';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width - 80
                            : (MediaQuery.of(context).size.width - 120) / 2,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan email';
                            } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Mohon masukkan email yang valid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Informasi Tambahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: const Icon(Icons.home, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mohon masukkan alamat';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width - 80
                            : (MediaQuery.of(context).size.width - 120) / 2,
                        child: DropdownButtonFormField<String>(
                          value: _selectedReligion,
                          items: [
                            'Islam',
                            'Kristen',
                            'Katolik',
                            'Hindu',
                            'Buddha',
                            'Konghucu'
                          ]
                              .map((religion) => DropdownMenuItem(
                            value: religion,
                            child: Text(religion),
                          ))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'Agama',
                            prefixIcon: const Icon(Icons.church, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedReligion = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon pilih agama';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width - 80
                            : (MediaQuery.of(context).size.width - 120) / 2,
                        child: TextFormField(
                          controller: _pekerjaanController,
                          decoration: InputDecoration(
                            labelText: 'Pekerjaan',
                            prefixIcon: const Icon(Icons.work, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan pekerjaan';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Submit button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updatePatientData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}