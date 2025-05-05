// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'DaftarPasien.dart';

// Constants
const Color primaryColor = Color(0xFF4F6AFF);
const Color secondaryColor = Color(0xFF8C9EFF);
const Color backgroundColor = Color(0xFFF5F7FF);
const Color textColor = Color(0xFF2C3E50);

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  int _selectedIndex = 0;
  final bool _isSidebarExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Navigation method
  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the screen is small (mobile)
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: isSmallScreen ? _buildDrawer() : null,
      body: Row(
        children: [
          if (!isSmallScreen) _buildSidebar(),
          Expanded(
            child: Container(
              color: backgroundColor,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Klinik Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildSidebarItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSidebarExpanded ? 250 : 70,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          if (_isSidebarExpanded)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Menu Pasien',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            )
          else
            const SizedBox(height: 20),
          Expanded(child: _buildSidebarItems()),
        ],
      ),
    );
  }

  Widget _buildSidebarItems() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SidebarItem(
          icon: Icons.person_add,
          label: 'Tambah Pasien',
          isActive: _selectedIndex == 0,
          isExpanded: _isSidebarExpanded,
          onTap: () => _navigateTo(0),
        ),
        SidebarItem(
          icon: Icons.visibility,
          label: 'Lihat Pasien',
          isActive: _selectedIndex == 1,
          isExpanded: _isSidebarExpanded,
          onTap: () => _navigateTo(1),
        ),
        SidebarItem(
          icon: Icons.list,
          label: 'Daftar Pasien',
          isActive: _selectedIndex == 2,
          isExpanded: _isSidebarExpanded,
          onTap: () => _navigateTo(2),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const AddPatientForm();
      case 1:
        return const PatientListPage();
      case 2:
        return const DaftarTindakanPasien();
      default:
        return const AddPatientForm();
    }
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 0,
          vertical: 2,
        ),
        leading: Icon(
          icon,
          color: isActive ? primaryColor : Colors.grey,
          size: 24,
        ),
        title: isExpanded
            ? Text(
                label,
                style: TextStyle(
                  color: isActive ? primaryColor : textColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class AddPatientForm extends StatefulWidget {
  const AddPatientForm({super.key});

  @override
  State<AddPatientForm> createState() => _AddPatientFormState();
}

class _AddPatientFormState extends State<AddPatientForm> {
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
  String? _medicalRecordNumber;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchClinicId();
  }

// Pertama, tambahkan variabel untuk menyimpan ID klinik
  String? _clinicId;

// Tambahkan fungsi untuk mendapatkan ID klinik berdasarkan email user yang login
  Future<void> _fetchClinicId() async {
    try {
      // Dapatkan email dari user saat ini
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final String userEmail = user.email!;

        // Cari klinik dengan email tersebut
        final snapshot = await FirebaseFirestore.instance
            .collection('clinics')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _clinicId = snapshot.docs.first.id;
          });

          // Setelah mendapatkan ID klinik, lanjutkan dengan fetch nomor rekam medis
          _fetchMedicalRecordNumber();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Klinik tidak ditemukan!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch clinic ID: $e')),
      );
    }
  }

  Future<void> _fetchMedicalRecordNumber() async {
    try {
      if (_clinicId == null) {
        throw Exception('ID Klinik tidak tersedia');
      }

      if (kDebugMode) {
        print('Clinic ID: $_clinicId');
      }

      // Ambil semua data untuk klinik ini
      final snapshot = await FirebaseFirestore.instance
          .collection('pasien')
          .where('clinicId', isEqualTo: _clinicId)
          .get();


      int lastNumber = 0;
      if (snapshot.docs.isNotEmpty) {
        // Loop melalui semua dokumen untuk menemukan nomor terbesar
        for (var doc in snapshot.docs) {
          final String? mrn = doc.data()['medicalRecordNumber'] as String?;

          if (mrn != null) {
            // Parse nomor rekam medis
            final int? number = int.tryParse(mrn);
            if (number != null && number > lastNumber) {
              lastNumber = number;
            }
          }
        }

      }

      // Nomor berikutnya adalah nomor terakhir + 1
      final nextNumber = lastNumber + 1;

      setState(() {
        // Format: 8 digit dengan leading zeros
        _medicalRecordNumber = nextNumber.toString().padLeft(8, '0');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch medical record number: $e')),
      );
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Pastikan clinicId ada
        if (_clinicId == null) {
          throw Exception('ID Klinik tidak tersedia');
        }

        // Upload image first if available
        final String? imageUrl = await _uploadImage();

        // Prepare patient data
        final patientData = {
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
          'imageUrl': imageUrl,
          'clinicId': _clinicId, // Tambahkan clinicId ke data pasien
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Save to Firestore
        await FirebaseFirestore.instance.collection('pasien').add(patientData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pasien berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );

        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit data: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
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
        });
      } else {
        final File imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return null;

    try {
      final String fileName =
          '${_nikController.text}_${DateTime.now().millisecondsSinceEpoch}';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('patient_images/$fileName');

      final UploadTask uploadTask = storageRef.putData(_imageBytes!);
      final TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  void _resetForm() {
    setState(() {
      _fullNameController.clear();
      _dobController.clear();
      _nikController.clear();
      _addressController.clear();
      _phoneController.clear();
      _emailController.clear();
      _pekerjaanController.clear();
      _selectedGender = null;
      _selectedReligion = null;
      _imageBytes = null;
      _fetchMedicalRecordNumber();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
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
                  'Tambah Data Pasien Baru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(height: 8),
                const Text(
                  'Silakan isi semua data dengan benar',
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
                          prefixIcon:
                              const Icon(Icons.person, color: primaryColor),
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
                          prefixIcon:
                              const Icon(Icons.badge, color: primaryColor),
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
                          prefixIcon:
                              const Icon(Icons.people, color: primaryColor),
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
                          prefixIcon: const Icon(Icons.calendar_today,
                              color: primaryColor),
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
                              _dobController.text =
                                  DateFormat('dd/MM/yyyy').format(pickedDate);
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
                          prefixIcon:
                              const Icon(Icons.phone, color: primaryColor),
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
                          prefixIcon:
                              const Icon(Icons.email, color: primaryColor),
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
                          prefixIcon:
                              const Icon(Icons.church, color: primaryColor),
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
                          prefixIcon:
                              const Icon(Icons.work, color: primaryColor),
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
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan Data Pasien',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Pasien',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lihat dan kelola semua data pasien',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari pasien...',
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Patient list
          Expanded(
            child: _buildPatientList(isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList(bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  if (!isSmallScreen) ...[
                    const SizedBox(width: 50),
                    Expanded(
                      flex: 2,
                      child: _columnHeader('Nama'),
                    ),
                    Expanded(
                      flex: 1,
                      child: _columnHeader('No. RM'),
                    ),
                    Expanded(
                      flex: 1,
                      child: _columnHeader('Jenis Kelamin'),
                    ),
                    Expanded(
                      flex: 1,
                      child: _columnHeader('Tanggal Lahir'),
                    ),
                    const SizedBox(width: 100),
                  ],
                ],
              ),
            ),
            const Divider(),

            // List of patients
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildPatientQuery(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada data pasien yang ditemukan',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return isSmallScreen
                          ? _buildMobilePatientItem(doc.id, data)
                          : _buildDesktopPatientItem(doc.id, data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _buildPatientQuery() {
    Query query = FirebaseFirestore.instance.collection('pasien');

    // If search query is provided, filter results
    if (_searchQuery.isNotEmpty) {
      // Search by name (case-insensitive prefix match)
      query = query
          .where('fullName', isGreaterThanOrEqualTo: _searchQuery)
          .where('fullName', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
          .limit(20);
    } else {
      // Default: latest patients first
      query = query.orderBy('createdAt', descending: true).limit(20);
    }

    return query.snapshots();
  }

  Widget _buildDesktopPatientItem(String id, Map<String, dynamic> data) {
    return InkWell(
      onTap: () => _viewPatientDetails(id, data),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: primaryColor,
              child: Text(
                data['fullName']?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),

            // Patient details
            Expanded(
              flex: 2,
              child: Text(
                data['fullName'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(data['medicalRecordNumber'] ?? ''),
            ),
            Expanded(
              flex: 1,
              child: Text(data['gender'] ?? ''),
            ),
            Expanded(
              flex: 1,
              child: Text(data['dob'] ?? ''),
            ),

            // Actions
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: primaryColor),
                  onPressed: () => _viewPatientDetails(id, data),
                  tooltip: 'Lihat Detail',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: () => _editPatient(id, data),
                  tooltip: 'Edit Data',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePatientItem(String id, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: Text(
            data['fullName']?.substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          data['fullName'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('No. RM: ${data['medicalRecordNumber'] ?? ''}'),
            Text('${data['gender'] ?? ''} | ${data['dob'] ?? ''}'),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: primaryColor),
                  SizedBox(width: 8),
                  Text('Lihat Detail'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.amber),
                  SizedBox(width: 8),
                  Text('Edit Data'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'medical',
              child: Row(
                children: [
                  Icon(Icons.medical_services, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Riwayat Medis'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewPatientDetails(id, data);
                break;
              case 'edit':
                _editPatient(id, data);
                break;
              case 'medical':
                // View medical history
                break;
            }
          },
        ),
        onTap: () => _viewPatientDetails(id, data),
      ),
    );
  }

  Widget _columnHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  void _viewPatientDetails(String id, Map<String, dynamic> data) {
    // Navigate to patient details view
    // This could be implemented as a modal dialog or navigation to a new page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pasien: ${data['fullName']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _detailItem('Nama', data['fullName'] ?? ''),
              _detailItem('NIK', data['nik'] ?? ''),
              _detailItem('No. Rekam Medis', data['medicalRecordNumber'] ?? ''),
              _detailItem('Jenis Kelamin', data['gender'] ?? ''),
              _detailItem('Tanggal Lahir', data['dob'] ?? ''),
              _detailItem('Email', data['email'] ?? ''),
              _detailItem('No. Telepon', data['phone'] ?? ''),
              _detailItem('Alamat', data['address'] ?? ''),
              _detailItem('Agama', data['religion'] ?? ''),
              _detailItem('Pekerjaan', data['pekerjaan'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editPatient(id, data);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text('Edit Data'),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editPatient(String id, Map<String, dynamic> data) {
    // Navigate to edit patient view
    // This would typically navigate to an edit form pre-populated with patient data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur edit pasien akan segera tersedia'),
      ),
    );
  }
}
