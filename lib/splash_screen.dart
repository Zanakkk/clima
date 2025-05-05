// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Screens/HomePage.dart';
import 'Screens/RegisterLogin/ClinicRegistrationScreen.dart';
import 'Screens/RegisterLogin/Login.dart';
import 'Screens/RegisterLogin/VerificationWindow.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _navigateToLogin();
      return;
    }

    try {
      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection('clinics')
          .where('email', isEqualTo: currentUser.email)
          .limit(1)
          .get();


      if (!mounted) return;

      if (userDoc.docs.isEmpty) {
        // No clinic profile found, direct to registration
        _navigateToClinicRegistration();
      } else {
        // Get clinic data
        final clinicId = userDoc.docs.first.id;
        final clinicData = userDoc.docs.first.data();

        // Save relevant clinic data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('clinicId', clinicId);

        // Save the clinic endpoint for URL handling if it exists
        if (clinicData.containsKey('endpointId')) {
          await prefs.setString('clinicEndpoint', clinicData['endpointId']);
        }

        // Check activationTrue field
        final bool isActivated = clinicData['activation'] ?? false;

        if (isActivated) {
          // If activated, go to home screen
          _navigateToHome(clinicId);
        } else {
          // If not activated, go to activation screen
          _navigateToActivation();
        }
      }
    } catch (e) {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void _navigateToClinicRegistration() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const ClinicRegistrationScreen()));
  }

  void _navigateToHome(String clinicId) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(clinicId: clinicId)));
  }

  void _navigateToActivation() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const ActivationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.primary,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/LOGO.JPG',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // App name
                const Text(
                  'CLIMA NUSANTARA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // App tagline
                const Text(
                  'Modern Healthcare Management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
                // Loading indicator
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.9),
                    ),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
