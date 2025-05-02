// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../HomePage.dart';

class ClinicRegistrationScreen extends StatefulWidget {
  const ClinicRegistrationScreen({super.key});

  @override
  _ClinicRegistrationScreenState createState() =>
      _ClinicRegistrationScreenState();
}

class _ClinicRegistrationScreenState extends State<ClinicRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordManagementController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Uint8List? _imageBytes;
  String? _downloadUrl;
  final ImagePicker _picker = ImagePicker();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _passwordManagementController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
        await _uploadFile(bytes);
      }
    } catch (e) {
      _showErrorDialog("Image Selection Error", "Failed to select image: $e");
    }
  }

  Future<void> _uploadFile(Uint8List bytes) async {
    try {
      setState(() {
      });

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final storageRef =
          FirebaseStorage.instance.ref().child('clinic_logos/$fileName');

      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/png'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _downloadUrl = downloadUrl;
      });
    } catch (e) {
      setState(() {
      });
      _showErrorDialog("Upload Error", "Failed to upload logo: $e");
    }
  }

  Future<void> _registerClinic() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageBytes == null || _downloadUrl == null) {
      _showSnackBar("Please upload a clinic logo");
      return;
    }

    if (_passwordManagementController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords don't match");
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("You must be logged in to register a clinic");
      return;
    }

    setState(() {
    });

    try {
      final String clinicName = _nameController.text.trim();
      final String clinicAddress = _addressController.text.trim();
      final String clinicEmail = user.email!;
      final String passwordManagement =
          _passwordManagementController.text.trim();
      final String endpointId = _generateEndpoint(clinicName);

      // Create basic clinic data for Firestore (without plan selection)
      final Map<String, dynamic> clinicData = {
        'activation' : false,
        'name': clinicName,
        'address': clinicAddress,
        'email': clinicEmail,
        'logo': _downloadUrl,
        'passwordManagement': passwordManagement,
        'endpointId': endpointId,
        'createdAt': FieldValue.serverTimestamp(),
        'registrationComplete':
            false, // Flag to indicate plan selection is pending
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('clinics')
          .doc(endpointId)
          .set(clinicData);

      // Update URL
      FULLURL = endpointId;
      final newUrl = Uri.base.replace(path: '/$endpointId');
      html.window.history.pushState(null, '', newUrl.toString());

      // Navigate to the plan selection screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(clinicId: endpointId)),
        );
      }
    } catch (e) {
      _showErrorDialog("Registration Error", "Failed to register clinic: $e");
    } finally {
      if (mounted) {
        setState(() {
        });
      }
    }
  }

  String _generateEndpoint(String clinicName) {
    final String sanitizedName =
        clinicName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
    final String randomDigits =
        Random().nextInt(9000).toString().padLeft(4, '0');
    return '$sanitizedName$randomDigits';
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 900;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left Column - Logo Upload
        Expanded(
          flex: 4,
          child: _buildLogoUploader(),
        ),

        const SizedBox(width: 32),

        // Right Column - Registration Form
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clinic Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      )),
              const SizedBox(height: 24),
              _buildRegistrationForm(),
              const SizedBox(height: 32),
              _buildNextButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo Upload
        Center(
          child: SizedBox(
            width: 300,
            child: _buildLogoUploader(),
          ),
        ),

        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 32),

        // Registration Form
        Text('Clinic Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                )),
        const SizedBox(height: 24),
        _buildRegistrationForm(),
        const SizedBox(height: 32),
        _buildNextButton(),
      ],
    );
  }

  Widget _buildLogoUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Clinic Logo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Upload your clinic logo to display to your patients',
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          height: 220,
          width: 220,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: _imageBytes != null
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: _imageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    _imageBytes!,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 72,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Click to upload',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PNG, JPG up to 5MB',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 220,
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: Icon(_imageBytes != null ? Icons.edit : Icons.upload),
            label: Text(_imageBytes != null ? 'Change Logo' : 'Upload Logo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (_imageBytes != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _imageBytes = null;
                  _downloadUrl = null;
                });
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Clinic Name',
              hintText: 'Enter your clinic name',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Clinic name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Clinic Address',
              hintText: 'Enter your clinic address',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Clinic address is required';
              }
              return null;
            },
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordManagementController,
            decoration: InputDecoration(
              labelText: 'Management Password',
              hintText: 'Create a secure password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordManagementController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _registerClinic,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Select Plan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
