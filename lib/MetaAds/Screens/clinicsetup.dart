// lib/screens/clinic_setup_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/model.dart';
import '../Services/AllServices.dart';

class ClinicSetupScreen extends StatefulWidget {
  final ClinicModel? clinic; // null untuk create, ada value untuk edit

  const ClinicSetupScreen({super.key, this.clinic});

  @override
  State<ClinicSetupScreen> createState() => _ClinicSetupScreenState();
}

class _ClinicSetupScreenState extends State<ClinicSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clinicService = ClinicService();

  // Controllers untuk form
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _radiusController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _isEditing = false;
  String _selectedPlan = 'basic';
  int _ageMin = 25;
  int _ageMax = 55;
  List<String> _selectedGenders = ['all'];
  List<String> _selectedLanguages = ['id'];
  List<String> _interests = [];
  List<String> _behaviors = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.clinic != null;
    if (_isEditing) {
      _loadClinicData();
    } else {
      _setDefaultValues();
    }
  }

  void _loadClinicData() {
    final clinic = widget.clinic!;
    _nameController.text = clinic.name;
    _emailController.text = clinic.email;
    _phoneController.text = clinic.phone;
    _addressController.text = clinic.address;
    _latController.text = clinic.location.lat.toString();
    _lngController.text = clinic.location.lng.toString();
    _radiusController.text = clinic.location.radius.toString();

    _selectedPlan = clinic.subscription.plan;
    _ageMin = clinic.defaultTargeting.demographics.ageMin;
    _ageMax = clinic.defaultTargeting.demographics.ageMax;
    _selectedGenders = List.from(clinic.defaultTargeting.demographics.genders);
    _selectedLanguages =
        List.from(clinic.defaultTargeting.demographics.languages);
    _interests = List.from(clinic.defaultTargeting.interests);
    _behaviors = List.from(clinic.defaultTargeting.behaviors);
  }

  void _setDefaultValues() {
    _radiusController.text = '5';
    _selectedGenders = ['all'];
    _selectedLanguages = ['id'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _saveClinic() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final clinicData = ClinicModel(
        id: _isEditing ? widget.clinic!.id : '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        location: LocationModel(
          lat: double.tryParse(_latController.text) ?? 0.0,
          lng: double.tryParse(_lngController.text) ?? 0.0,
          radius: int.tryParse(_radiusController.text) ?? 5,
        ),
        metaIntegration: _isEditing
            ? widget.clinic!.metaIntegration
            : MetaIntegrationModel(
                adAccountId: '',
                pixelId: '',
                pageId: '',
                accessToken: '',
                status: 'disconnected',
              ),
        defaultTargeting: DefaultTargetingModel(
          demographics: DemographicsModel(
            ageMin: _ageMin,
            ageMax: _ageMax,
            genders: _selectedGenders,
            languages: _selectedLanguages,
          ),
          interests: _interests,
          behaviors: _behaviors,
        ),
        subscription: SubscriptionModel(
          plan: _selectedPlan,
          status: 'active',
          expiresAt: DateTime.now().add(const Duration(days: 30)),
          limits: _getPlanLimits(_selectedPlan),
        ),
        createdAt: _isEditing ? widget.clinic!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      ClinicModel result;
      if (_isEditing) {
        result =
            await _clinicService.updateClinic(widget.clinic!.id, clinicData);
      } else {
        result = await _clinicService.createClinic(clinicData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Klinik berhasil diupdate!'
                : 'Klinik berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, int> _getPlanLimits(String plan) {
    switch (plan) {
      case 'pro':
        return {'campaigns': 20, 'ad_accounts': 3};
      case 'enterprise':
        return {'campaigns': 100, 'ad_accounts': 10};
      default:
        return {'campaigns': 5, 'ad_accounts': 1};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Klinik' : 'Setup Klinik'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildSubscriptionSection(),
                    const SizedBox(height: 24),
                    _buildTargetingSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Dasar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Klinik',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama klinik harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email harus diisi';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat harus diisi';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasi & Radius',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Latitude harus diisi';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Format tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Longitude harus diisi';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Format tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _radiusController,
              decoration: const InputDecoration(
                labelText: 'Radius (km)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Radius harus diisi';
                }
                final radius = int.tryParse(value);
                if (radius == null || radius <= 0) {
                  return 'Radius harus lebih dari 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paket Langganan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Basic (5 campaigns, 1 ad account)'),
                  value: 'basic',
                  groupValue: _selectedPlan,
                  onChanged: (value) => setState(() => _selectedPlan = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Pro (20 campaigns, 3 ad accounts)'),
                  value: 'pro',
                  groupValue: _selectedPlan,
                  onChanged: (value) => setState(() => _selectedPlan = value!),
                ),
                RadioListTile<String>(
                  title:
                      const Text('Enterprise (100 campaigns, 10 ad accounts)'),
                  value: 'enterprise',
                  groupValue: _selectedPlan,
                  onChanged: (value) => setState(() => _selectedPlan = value!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Default Targeting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Age Range
            const Text('Rentang Usia:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _ageMin.toDouble(),
                    min: 18,
                    max: 65,
                    divisions: 47,
                    label: _ageMin.toString(),
                    onChanged: (value) {
                      setState(() {
                        _ageMin = value.round();
                        if (_ageMin >= _ageMax) _ageMax = _ageMin + 1;
                      });
                    },
                  ),
                ),
                Text('$_ageMin - $_ageMax'),
                Expanded(
                  child: Slider(
                    value: _ageMax.toDouble(),
                    min: 18,
                    max: 65,
                    divisions: 47,
                    label: _ageMax.toString(),
                    onChanged: (value) {
                      setState(() {
                        _ageMax = value.round();
                        if (_ageMax <= _ageMin) _ageMin = _ageMax - 1;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gender
            const Text('Gender:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            Wrap(
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: _selectedGenders.contains('all'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGenders = ['all'];
                      } else {
                        _selectedGenders.remove('all');
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pria'),
                  selected: _selectedGenders.contains('male'),
                  onSelected: (selected) {
                    setState(() {
                      _selectedGenders.remove('all');
                      if (selected) {
                        _selectedGenders.add('male');
                      } else {
                        _selectedGenders.remove('male');
                      }
                      if (_selectedGenders.isEmpty) _selectedGenders.add('all');
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Wanita'),
                  selected: _selectedGenders.contains('female'),
                  onSelected: (selected) {
                    setState(() {
                      _selectedGenders.remove('all');
                      if (selected) {
                        _selectedGenders.add('female');
                      } else {
                        _selectedGenders.remove('female');
                      }
                      if (_selectedGenders.isEmpty) _selectedGenders.add('all');
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language
            const Text('Bahasa:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            Wrap(
              children: [
                FilterChip(
                  label: const Text('Indonesia'),
                  selected: _selectedLanguages.contains('id'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLanguages.add('id');
                      } else {
                        _selectedLanguages.remove('id');
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('English'),
                  selected: _selectedLanguages.contains('en'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLanguages.add('en');
                      } else {
                        _selectedLanguages.remove('en');
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveClinic,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _isEditing ? 'Update Klinik' : 'Buat Klinik',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
