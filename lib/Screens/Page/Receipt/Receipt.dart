// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ResepObat extends StatefulWidget {
  const ResepObat({super.key});

  @override
  State<ResepObat> createState() => _ResepObatState();
}

class _ResepObatState extends State<ResepObat> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const CreatePrescriptionPage(),
    const ViewPrescriptionsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Row(
        children: [
          // Modern Side Navigation
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade400
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'SIM Klinika',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        'Prescription System',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation Items
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildNavItem(
                          icon: Icons.add_circle_outline,
                          title: 'Create Prescription',
                          isSelected: _selectedIndex == 0,
                          onTap: () => setState(() => _selectedIndex = 0),
                        ),
                        const SizedBox(height: 8),
                        _buildNavItem(
                          icon: Icons.assignment,
                          title: 'View Prescriptions',
                          isSelected: _selectedIndex == 1,
                          onTap: () => setState(() => _selectedIndex = 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.blue.shade200) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePrescriptionPage extends StatefulWidget {
  const CreatePrescriptionPage({super.key});

  @override
  State<CreatePrescriptionPage> createState() => _CreatePrescriptionPageState();
}

class _CreatePrescriptionPageState extends State<CreatePrescriptionPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Doctor Information
  final _doctorNameController = TextEditingController();
  final _sipNumberController = TextEditingController();
  final _practiceLocationController = TextEditingController();
  final _phoneController = TextEditingController();

  // Patient Information
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();

  // Prescription Information
  final _prescriptionDateController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );

  // Medications List
  List<Medication> medications = [];

  @override
  void dispose() {
    _doctorNameController.dispose();
    _sipNumberController.dispose();
    _practiceLocationController.dispose();
    _phoneController.dispose();
    _patientNameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _prescriptionDateController.dispose();
    super.dispose();
  }

  Future<void> _savePrescription() async {
    if (_formKey.currentState!.validate() && medications.isNotEmpty) {
      setState(() {
        _isSaving = true;
      });

      try {
        final firestore = FirebaseFirestore.instance;

        final prescriptionData = {
          'doctorInfo': {
            'name': _doctorNameController.text,
            'sipNumber': _sipNumberController.text,
            'practiceLocation': _practiceLocationController.text,
            'phone': _phoneController.text,
          },
          'patientInfo': {
            'name': _patientNameController.text,
            'age': _ageController.text,
            'address': _addressController.text,
          },
          'prescriptionInfo': {
            'date': _prescriptionDateController.text,
            'medications': medications.map((med) => med.toMap()).toList(),
          },
          'createdAt': FieldValue.serverTimestamp(),
        };

        await firestore.collection('resep').add(prescriptionData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Prescription saved successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Clear form
          _formKey.currentState!.reset();
          _prescriptionDateController.text =
              DateFormat('dd/MM/yyyy').format(DateTime.now());
          setState(() {
            medications.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Error: $e'),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } else if (medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please add at least one medication'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        onAdd: (medication) {
          setState(() {
            medications.add(medication);
          });
        },
      ),
    );
  }

  void _editMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        medication: medications[index],
        onAdd: (medication) {
          setState(() {
            medications[index] = medication;
          });
        },
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      medications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Prescription',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Fill in the details to create a prescription',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        children: [
                          // Doctor Information
                          _buildModernCard(
                            title: 'Doctor Information',
                            icon: Icons.person,
                            child: Column(
                              children: [
                                _buildModernTextField(
                                  controller: _doctorNameController,
                                  label: 'Doctor Name',
                                  icon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter doctor name';
                                    }
                                    return null;
                                  },
                                ),
                                _buildModernTextField(
                                  controller: _sipNumberController,
                                  label: 'SIP Number',
                                  icon: Icons.badge,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter SIP number';
                                    }
                                    return null;
                                  },
                                ),
                                _buildModernTextField(
                                  controller: _practiceLocationController,
                                  label: 'Practice Location',
                                  icon: Icons.location_on,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter practice location';
                                    }
                                    return null;
                                  },
                                ),
                                _buildModernTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter phone number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Patient Information
                          _buildModernCard(
                            title: 'Patient Information',
                            icon: Icons.person_outline,
                            child: Column(
                              children: [
                                _buildModernTextField(
                                  controller: _patientNameController,
                                  label: 'Patient Name',
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter patient name';
                                    }
                                    return null;
                                  },
                                ),
                                _buildModernTextField(
                                  controller: _ageController,
                                  label: 'Age',
                                  icon: Icons.cake,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter age';
                                    }
                                    return null;
                                  },
                                ),
                                _buildModernTextField(
                                  controller: _addressController,
                                  label: 'Address',
                                  icon: Icons.home,
                                  maxLines: 2,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter address';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Right Column
                    Expanded(
                      child: Column(
                        children: [
                          // Prescription Date
                          _buildModernCard(
                            title: 'Prescription Date',
                            icon: Icons.calendar_today,
                            child: GestureDetector(
                              onTap: () => _selectDate(
                                  context, _prescriptionDateController),
                              child: AbsorbPointer(
                                child: _buildModernTextField(
                                  controller: _prescriptionDateController,
                                  label: 'Prescription Date',
                                  icon: Icons.calendar_today,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select date';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Medications
                          _buildModernCard(
                            title: 'Medications',
                            icon: Icons.medication,
                            child: Column(
                              children: [
                                // Add Medication Button
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _addMedication,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text(
                                      'Add Medication',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Medications List
                                ...medications.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Medication med = entry.value;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'R/ ${med.name}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit,
                                                      color:
                                                          Colors.blue.shade600,
                                                      size: 20),
                                                  onPressed: () =>
                                                      _editMedication(index),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color:
                                                          Colors.red.shade600,
                                                      size: 20),
                                                  onPressed: () =>
                                                      _removeMedication(index),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Dosage: ${med.dosage}'),
                                        Text('Quantity: ${med.quantity}'),
                                        Text(
                                            'Instructions: ${med.additionalInfo}'),
                                      ],
                                    ),
                                  );
                                }).toList(),

                                if (medications.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade200,
                                          style: BorderStyle.solid),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.medication_outlined,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No medications added yet',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Click "Add Medication" to start',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _savePrescription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Prescription',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }
}

class _MedicationDialog extends StatefulWidget {
  final Medication? medication;
  final Function(Medication) onAdd;

  const _MedicationDialog({
    this.medication,
    required this.onAdd,
  });

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _formKey = GlobalKey<FormState>();

  // Predefined medication list
  final List<Map<String, String>> _medicationList = [
    // Antibiotik
    {
      'name': 'Amoxicillin',
      'category': 'Antibiotik',
      'defaultDosage': 'tab 500 mg'
    },
    {
      'name': 'Ciprofloxacin',
      'category': 'Antibiotik',
      'defaultDosage': 'tab 500 mg'
    },
    {
      'name': 'Cefixime',
      'category': 'Antibiotik',
      'defaultDosage': 'kaps 200 mg'
    },
    // Antiinflamasi
    {
      'name': 'Ibuprofen',
      'category': 'Antiinflamasi',
      'defaultDosage': 'tab 400 mg'
    },
    {
      'name': 'Diclofenac',
      'category': 'Antiinflamasi',
      'defaultDosage': 'tab 50 mg'
    },
    {
      'name': 'Meloxicam',
      'category': 'Antiinflamasi',
      'defaultDosage': 'tab 15 mg'
    },
    {
      'name': 'Dexamethasone',
      'category': 'Antiinflamasi',
      'defaultDosage': 'tab 0.5 mg'
    },
    // Antinyeri
    {
      'name': 'Paracetamol',
      'category': 'Antinyeri',
      'defaultDosage': 'tab 500 mg'
    },
    {
      'name': 'Asam Mefenamat',
      'category': 'Antinyeri',
      'defaultDosage': 'kaps 500 mg'
    },
    {
      'name': 'Ketorolac',
      'category': 'Antinyeri',
      'defaultDosage': 'tab 10 mg'
    },
  ];

  String? _selectedMedication;
  late TextEditingController _dosageController;
  late TextEditingController _quantityController;
  late TextEditingController _frequencyController;
  late TextEditingController _additionalInfoController;
  late TextEditingController _additionalInfo2Controller;

  @override
  void initState() {
    super.initState();
    _selectedMedication = widget.medication?.name;
    _dosageController =
        TextEditingController(text: widget.medication?.dosage ?? '');
    _quantityController =
        TextEditingController(text: widget.medication?.quantity ?? '');
    _frequencyController =
        TextEditingController(text: widget.medication?.frequency ?? '');
    _additionalInfoController =
        TextEditingController(text: widget.medication?.additionalInfo ?? '');
    _additionalInfo2Controller =
        TextEditingController(text: widget.medication?.additionalInfo2 ?? '');
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _quantityController.dispose();
    _frequencyController.dispose();
    _additionalInfoController.dispose();
    _additionalInfo2Controller.dispose();
    super.dispose();
  }

  void _onMedicationSelected(String? medication) {
    setState(() {
      _selectedMedication = medication;
      if (medication != null) {
        final selectedMed =
            _medicationList.firstWhere((med) => med['name'] == medication);
        _dosageController.text = selectedMed['defaultDosage'] ?? '';
      }
    });
  }

  String _generatePrescription() {
    if (_selectedMedication == null) return '';

    return 'R/ $_selectedMedication ${_dosageController.text} ${_quantityController.text}\n${_frequencyController.text} ${_additionalInfoController.text} ${_additionalInfo2Controller.text}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.medication,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.medication == null
                          ? 'Tambah Resep Obat'
                          : 'Edit Resep Obat',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nama Obat Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedMedication,
                  decoration: InputDecoration(
                    labelText: 'Nama Obat',
                    prefixIcon:
                        Icon(Icons.medication, color: Colors.blue.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade600, width: 2),
                    ),
                  ),
                  isExpanded: true,
                  isDense: true,
                  menuMaxHeight: 400,
                  items: _medicationList.map((medication) {
                    return DropdownMenuItem<String>(
                      value: medication['name'],
                      child: Container(
                        width: double.infinity,
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: medication['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: ' - ${medication['category']!}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _onMedicationSelected,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih nama obat';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sediaan
                TextFormField(
                  controller: _dosageController,
                  decoration: InputDecoration(
                    labelText: 'Sediaan (e.g., tab 500 mg, kaps 200 mg)',
                    prefixIcon:
                        Icon(Icons.science, color: Colors.blue.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade600, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan sediaan obat';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Jumlah Obat
                DropdownButtonFormField<String>(
                  value: _quantityController.text.isEmpty
                      ? null
                      : _quantityController.text,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Obat',
                    prefixIcon:
                        Icon(Icons.numbers, color: Colors.blue.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade600, width: 2),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    'No V',
                    'No X',
                    'No XV',
                    'No XX',
                    'No XXV',
                    'No XXX',
                  ].map((quantity) {
                    return DropdownMenuItem<String>(
                      value: quantity,
                      child: Text(quantity),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _quantityController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih jumlah obat';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Aturan Pakai
                DropdownButtonFormField<String>(
                  value: _frequencyController.text.isEmpty
                      ? null
                      : _frequencyController.text,
                  decoration: InputDecoration(
                    labelText: 'Aturan Pakai',
                    prefixIcon:
                        Icon(Icons.schedule, color: Colors.blue.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade600, width: 2),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    {'value': 'S.1.d.d', 'label': 'S.1.d.d (1x sehari)'},
                    {'value': 'S.2.d.d', 'label': 'S.2.d.d (2x sehari)'},
                    {'value': 'S.3.d.d', 'label': 'S.3.d.d (3x sehari)'},
                    {'value': 'S.4.d.d', 'label': 'S.4.d.d (4x sehari)'},
                    {'value': 'S.prn', 'label': 'S.prn (seperlunya)'},
                  ].map((frequency) {
                    return DropdownMenuItem<String>(
                      value: frequency['value'],
                      child: Text(
                        frequency['label']!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _frequencyController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih aturan pakai';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Keterangan Tambahan 1
                DropdownButtonFormField<String>(
                  value: _additionalInfoController.text.isEmpty
                      ? null
                      : _additionalInfoController.text,
                  decoration: InputDecoration(
                    labelText: 'Keterangan Tambahan 1',
                    prefixIcon:
                        Icon(Icons.info_outline, color: Colors.blue.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade600, width: 2),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    {
                      'value': 'tab 1 pc',
                      'label': 'tab 1 pc (1 tablet setelah makan)'
                    },
                    {
                      'value': 'tab 1 ac',
                      'label': 'tab 1 ac (1 tablet sebelum makan)'
                    },
                    {
                      'value': 'kaps 1 pc',
                      'label': 'kaps 1 pc (1 kapsul setelah makan)'
                    },
                    {
                      'value': 'kaps 1 ac',
                      'label': 'kaps 1 ac (1 kapsul sebelum makan)'
                    },
                    {
                      'value': 'tab 1/2 pc',
                      'label': 'tab 1/2 pc (1/2 tablet setelah makan)'
                    },
                    {
                      'value': 'tab 1/2 ac',
                      'label': 'tab 1/2 ac (1/2 tablet sebelum makan)'
                    },
                    {'value': 'prn', 'label': 'prn (bila perlu)'},
                  ].map((info) {
                    return DropdownMenuItem<String>(
                      value: info['value'],
                      child: Text(
                        info['label']!,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _additionalInfoController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih keterangan tambahan 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Keterangan Tambahan 2
                DropdownButtonFormField<String>(
                  value: _additionalInfo2Controller.text.isEmpty
                      ? null
                      : _additionalInfo2Controller.text,
                  decoration: InputDecoration(
                    labelText: 'Keterangan Tambahan 2',
                    prefixIcon:
                        Icon(Icons.more_horiz, color: Colors.blue.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade600, width: 2),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    {
                      'value': 'max 2dd',
                      'label': 'max 2dd (maksimal 2x sehari)'
                    },
                    {
                      'value': 'max 3dd',
                      'label': 'max 3dd (maksimal 3x sehari)'
                    },
                    {
                      'value': 'max 4dd',
                      'label': 'max 4dd (maksimal 4x sehari)'
                    },
                  ].map((info) {
                    return DropdownMenuItem<String>(
                      value: info['value'],
                      child: Text(
                        info['label']!,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _additionalInfo2Controller.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih keterangan tambahan 2';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Preview Resep
                if (_selectedMedication != null &&
                    _dosageController.text.isNotEmpty &&
                    _quantityController.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview Resep:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _generatePrescription(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final medication = Medication(
                              name: _selectedMedication!,
                              dosage: _dosageController.text,
                              quantity: _quantityController.text,
                              frequency: _frequencyController.text,
                              additionalInfo: _additionalInfoController.text,
                              additionalInfo2: _additionalInfo2Controller.text,
                              prescription: _generatePrescription(),
                            );
                            widget.onAdd(medication);
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.medication == null ? 'Tambah' : 'Update',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Medication {
  final String name;
  final String dosage;
  final String quantity;
  final String frequency;
  final String additionalInfo;
  final String additionalInfo2;
  final String prescription;

  Medication({
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.frequency,
    required this.additionalInfo,
    required this.additionalInfo2,
    required this.prescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'quantity': quantity,
      'frequency': frequency,
      'additionalInfo': additionalInfo,
      'additionalInfo2': additionalInfo2,
      'prescription': prescription,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      quantity: map['quantity'] ?? '',
      frequency: map['frequency'] ?? '',
      additionalInfo: map['additionalInfo'] ?? '',
      additionalInfo2: map['additionalInfo2'] ?? '',
      prescription: map['prescription'] ?? '',
    );
  }

  // Method tambahan untuk kemudahan
  Medication copyWith({
    String? name,
    String? dosage,
    String? quantity,
    String? frequency,
    String? additionalInfo,
    String? additionalInfo2,
    String? prescription,
  }) {
    return Medication(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      quantity: quantity ?? this.quantity,
      frequency: frequency ?? this.frequency,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      additionalInfo2: additionalInfo2 ?? this.additionalInfo2,
      prescription: prescription ?? this.prescription,
    );
  }

  @override
  String toString() {
    return 'Medication(name: $name, dosage: $dosage, quantity: $quantity, frequency: $frequency, additionalInfo: $additionalInfo, additionalInfo2: $additionalInfo2, prescription: $prescription)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medication &&
        other.name == name &&
        other.dosage == dosage &&
        other.quantity == quantity &&
        other.frequency == frequency &&
        other.additionalInfo == additionalInfo &&
        other.additionalInfo2 == additionalInfo2 &&
        other.prescription == prescription;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        dosage.hashCode ^
        quantity.hashCode ^
        frequency.hashCode ^
        additionalInfo.hashCode ^
        additionalInfo2.hashCode ^
        prescription.hashCode;
  }
}

class ViewPrescriptionsPage extends StatefulWidget {
  const ViewPrescriptionsPage({super.key});

  @override
  State<ViewPrescriptionsPage> createState() => _ViewPrescriptionsPageState();
}

class _ViewPrescriptionsPageState extends State<ViewPrescriptionsPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View Prescriptions',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'Browse and manage existing prescriptions',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by patient name or doctor name...',
                  prefixIcon: Icon(Icons.search, color: Colors.blue.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Prescriptions List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('resep')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading prescriptions',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No prescriptions found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first prescription to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter prescriptions based on search query
                  List<QueryDocumentSnapshot> filteredDocs =
                      snapshot.data!.docs;
                  if (_searchQuery.isNotEmpty) {
                    filteredDocs = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final patientName =
                          data['patientInfo']['name'].toString().toLowerCase();
                      final doctorName =
                          data['doctorInfo']['name'].toString().toLowerCase();
                      return patientName.contains(_searchQuery) ||
                          doctorName.contains(_searchQuery);
                    }).toList();
                  }

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No prescriptions match your search',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return _buildPrescriptionCard(data, doc.id);
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

  Widget _buildPrescriptionCard(Map<String, dynamic> data, String docId) {
    final doctorInfo = data['doctorInfo'] as Map<String, dynamic>;
    final patientInfo = data['patientInfo'] as Map<String, dynamic>;
    final prescriptionInfo = data['prescriptionInfo'] as Map<String, dynamic>;
    final medications = (prescriptionInfo['medications'] as List<dynamic>)
        .map((med) => Medication.fromMap(med as Map<String, dynamic>))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient: ${patientInfo['name']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Date: ${prescriptionInfo['date']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deletePrescription(docId);
                    } else if (value == 'print') {
                      _printPrescription(data);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'print',
                      child: Row(
                        children: [
                          Icon(Icons.print, size: 18),
                          SizedBox(width: 8),
                          Text('Print'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor & Patient Info Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doctor Information',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Name: ${doctorInfo['name']}'),
                          Text('SIP: ${doctorInfo['sipNumber']}'),
                          Text('Location: ${doctorInfo['practiceLocation']}'),
                          Text('Phone: ${doctorInfo['phone']}'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient Information',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Name: ${patientInfo['name']}'),
                          Text('Age: ${patientInfo['age']}'),
                          Text('Address: ${patientInfo['address']}'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Medications
                Text(
                  'Medications (${medications.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),

                ...medications
                    .map((med) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'R/ ${med.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Dosage: ${med.dosage}'),
                              Text('Quantity: ${med.quantity}'),
                              Text('Instructions: ${med.additionalInfo}'),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deletePrescription(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Prescription'),
        content: const Text(
            'Are you sure you want to delete this prescription? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('resep')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Prescription deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Error deleting prescription: $e'),
                      ],
                    ),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _printPrescription(Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Text('Print functionality would be implemented here'),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
