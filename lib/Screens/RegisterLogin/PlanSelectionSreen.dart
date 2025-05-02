// ignore_for_file: library_private_types_in_public_api, avoid_web_libraries_in_flutter, use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import '../HomePage.dart';
import 'VerificationWindow.dart';

class PlanSelectionScreen extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String clinicLogo;
  final String passwordManagement;

  const PlanSelectionScreen({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.clinicAddress,
    required this.clinicLogo,
    required this.passwordManagement,
  });

  @override
  _PlanSelectionScreenState createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  String _selectedPlan = "Basic Monthly"; // Default plan
  bool _isLoading = false;

  List<bool> _generateControllerList(String plan) {
    // Extract the base plan name (without Monthly/Annual suffix)
    String basePlan = plan.contains(' ') ? plan.split(' ')[0] : plan;

    switch (basePlan) {
      case 'Basic':
        // Basic plan features
        final List<bool> controllerList = List.filled(22, false);
        final List<int> enabledFeatures = [
          0,
          2,
          3,
          4,
          6,
          11,
          12,
          13,
          14,
          17,
          19
        ];
        for (final index in enabledFeatures) {
          controllerList[index] = true;
        }
        return controllerList;

      case 'Advanced':
        // Advanced plan features - all except 18
        final List<bool> controllerList = List.filled(22, true);
        controllerList[18] = false;
        return controllerList;

      case 'Custom':
        // Custom plan - will need separate configuration
        // For Custom plans, we'll set all to false initially as they'll be configured separately
        return List.filled(22, false);

      default:
        return List.filled(22, false);
    }
  }

  Future<void> _finalizePurchase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar("You must be logged in to complete registration");
        return;
      }

      // Create clinic data for Firestore
      final Map<String, dynamic> clinicData = {
        'name': widget.clinicName,
        'address': widget.clinicAddress,
        'email': user.email!,
        'logo': widget.clinicLogo,
        'passwordManagement': widget.passwordManagement,
        'endpointId': widget.clinicId,
        'createdAt': FieldValue.serverTimestamp(),
        'Clima': {
          'ClimaPlan': _selectedPlan,
          'ClimaActive': false,
          'ClimaDate': '',
          'controllerclinic': _generateControllerList(_selectedPlan),
        },
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('clinics')
          .doc(widget.clinicId)
          .set(clinicData);

      // Update URL and navigate to activation screen
      FULLURL = widget.clinicId;
      final newUrl = Uri.base.replace(path: '/${widget.clinicId}');
      html.window.history.pushState(null, '', newUrl.toString());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ActivationScreen(),
        ),
      );
    } catch (e) {
      _showErrorDialog(
          "Registration Error", "Failed to complete registration: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  Widget _buildPlanCard(
      String plan, String price, List<String> features, bool isRecommended,
      [String savings = '']) {
    // Extract the plan name without the billing period for comparison
    String planBase = plan.contains(' ') ? plan.split(' ')[0] : plan;
    String selectedPlanBase = _selectedPlan.contains(' ')
        ? _selectedPlan.split(' ')[0]
        : _selectedPlan;
    bool isSelected = planBase == selectedPlanBase;

    return Card(
      elevation: isRecommended ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRecommended
              ? Theme.of(context).primaryColor
              : isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.5)
                  : Colors.grey.shade300,
          width: isRecommended || isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPlan = plan;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recommendation and saving badge
              Row(
                children: [
                  if (isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'REKOMENDASI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (savings.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade700),
                      ),
                      child: Text(
                        savings,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Plan name and selection radio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      planBase, // Just show "Basic", "Advanced", "Custom" without the billing period
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Radio<String>(
                    value: plan,
                    groupValue: _selectedPlan,
                    onChanged: (value) {
                      setState(() {
                        _selectedPlan = value!;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),

              // Price display
              Text(
                price,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (plan.contains('Monthly') && !plan.contains('Custom'))
                Text(
                  'Ditagih per bulan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              if (plan.contains('Annual') && !plan.contains('Custom'))
                Text(
                  'Ditagih tahunan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Features list
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // For custom plan, add a contact button
              if (plan == 'Custom')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPlan = plan;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      foregroundColor: isSelected
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Hubungi Kami'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive breakpoints
    final bool isDesktop = MediaQuery.of(context).size.width > 1100;
    final bool isTablet = MediaQuery.of(context).size.width <= 1100 &&
        MediaQuery.of(context).size.width >= 650;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Plan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Section
                          Text(
                            'Choose Your Plan',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select the plan that best fits your clinic\'s needs',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Plan selection
                          _buildPlanSelection(isGrid: isDesktop || isTablet),

                          const SizedBox(height: 32),

                          // Continue button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _finalizePurchase,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                'Continue',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanSelection({bool isGrid = true}) {
    // Payment toggle state
    bool isAnnual = _selectedPlan.contains("Annual");

    // Common features for the two main plans
    final List<String> basicFeatures = [
      'Pendaftaran pasien',
      'Penjadwalan janji temu dasar',
      'Manajemen rekam medis',
      'Laporan dasar',
      'Dukungan email',
    ];

    final List<String> advancedFeatures = [
      'Semua fitur paket Basic',
      'Penjadwalan lanjutan',
      'Manajemen inventaris',
      'Laporan keuangan',
      'Manajemen staf',
      'Dashboard analitik',
      'Dukungan prioritas 24/7',
    ];

    final List<String> customFeatures = [
      'Paket fitur disesuaikan',
      'Dukungan enterprise',
      'Manajer akun dedikasi',
      'Integrasi khusus',
      'Pelatihan on-site',
      'Akses API penuh',
    ];

    // Plans with monthly/annual price options
    final List<Map<String, dynamic>> plans = [
      {
        'name': isAnnual ? 'Basic Annual' : 'Basic Monthly',
        'price': isAnnual ? 'Rp5.000.000/tahun' : 'Rp499.000/bulan',
        'features': basicFeatures,
        'recommended': false,
        'savings': isAnnual ? 'Hemat Rp988.000' : '',
      },
      {
        'name': isAnnual ? 'Advanced Annual' : 'Advanced Monthly',
        'price': isAnnual ? 'Rp9.500.000/tahun' : 'Rp899.000/bulan',
        'features': advancedFeatures,
        'recommended': true,
        'savings': isAnnual ? 'Hemat Rp1.288.000' : '',
      },
      {
        'name': 'Custom',
        'price': 'Hubungi kami',
        'features': customFeatures,
        'recommended': false,
        'savings': '',
      },
    ];

    return Column(
      children: [
        // Payment toggle
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Monthly option
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedPlan.contains("Annual")) {
                      _selectedPlan =
                          _selectedPlan.replaceAll("Annual", "Monthly");
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: !isAnnual
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Bulanan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !isAnnual ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),

              // Annual option
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedPlan.contains("Monthly")) {
                      _selectedPlan =
                          _selectedPlan.replaceAll("Monthly", "Annual");
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAnnual
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Tahunan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAnnual ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (isAnnual)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Hemat 15%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // The plans
        if (isGrid && MediaQuery.of(context).size.width > 800)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return _buildPlanCard(
                plan['name'],
                plan['price'],
                List<String>.from(plan['features']),
                plan['recommended'],
                plan['savings'],
              );
            },
          )
        else
          Column(
            children: plans.map((plan) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildPlanCard(
                  plan['name'],
                  plan['price'],
                  List<String>.from(plan['features']),
                  plan['recommended'],
                  plan['savings'],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
