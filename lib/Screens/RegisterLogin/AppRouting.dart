// Modify your main.dart or routing configuration file

// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../HomePage.dart';
import 'ClinicRegistrationScreen.dart';
import 'Login.dart';

class AppRouter {
  static Future<Widget> determineInitialRoute() async {
    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in, return login screen
      return const LoginScreen(); // Replace with your actual login screen
    }

    // Check if user has a registered clinic
    try {
      final QuerySnapshot clinicQuery = await FirebaseFirestore.instance
          .collection('clinics')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (clinicQuery.docs.isNotEmpty) {
        // User has a clinic, extract the endpoint ID and set the URL
        final String endpointId = clinicQuery.docs.first.get('endpointId');
        FULLURL = endpointId;

        // Update URL if not already set
        final currentPath = html.window.location.pathname;
        if (currentPath == '/' || currentPath!.isEmpty) {
          final newUrl = Uri.base.replace(path: '/$endpointId');
          html.window.history.pushState(null, '', newUrl.toString());
        }

        return const HomeScreen(
          clinicId: '',
        );
      } else {
        // No clinic found, direct to registration
        return const ClinicRegistrationScreen();
      }
    } catch (e) {
      // On error, safest to direct to registration
      return const ClinicRegistrationScreen();
    }
  }
}

// In your app's startup/initialization code:
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<Widget>(
        future: AppRouter.determineInitialRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error loading app: ${snapshot.error}'),
              ),
            );
          }

          // Return the appropriate screen
          return snapshot.data ?? const ClinicRegistrationScreen();
        },
      ),
    );
  }
}
