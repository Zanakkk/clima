// Add this to your existing authentication flow
// This could be in your main.dart or a separate auth service file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../HomePage.dart';
import 'ClinicRegistrationScreen.dart';
import 'Login.dart';

class UserAuthHandler {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the logged-in user has a registered clinic
  static Future<bool> hasRegisteredClinic() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return false; // No user logged in
    }

    try {
      // Query Firestore to find clinics associated with this user's email
      final QuerySnapshot clinicQuery = await _firestore
          .collection('clinics')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      return clinicQuery.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Route user based on authentication and registration status
  static Future<Widget> getInitialScreen() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      // User is not logged in, return login screen
      return const LoginScreen(); // Replace with your actual login screen
    }

    // Check if user has a registered clinic
    final bool hasClinic = await hasRegisteredClinic();

    if (hasClinic) {
      // User has a clinic, go to homepage
      return const HomeScreen(clinicId: '',);
    } else {
      // User doesn't have a clinic yet, go to registration
      return const ClinicRegistrationScreen();
    }
  }
}
