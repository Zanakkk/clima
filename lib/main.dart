// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html; // Import untuk penggunaan localStorage
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'UserView/LandingPage.dart';
import 'UserView/ManagementPage/HomePage.dart';
import 'UserView/RegisterLogin/Login/InputDataKlinik.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() {
    final String? isLoggedIn = html.window.localStorage['isLoggedIn'];
    final String? clinicId = html.window.localStorage['clinicId'];

    if (isLoggedIn == 'true' && clinicId != null) {
      _navigateToHome(clinicId);
    } else if (isLoggedIn == 'true') {
      _navigateToClinicRegistration();
    }
  }

  void _navigateToHome(String clinicId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(id: clinicId),
      ),
    );
  }

  void _navigateToClinicRegistration() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ClinicRegistrationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        // Cek apakah clinicId sudah ada di localStorage
        final String? clinicId = html.window.localStorage['clinicId'];
        final bool isLoggedIn =
            html.window.localStorage['isLoggedIn'] == 'true';

        // Jika clinicId sudah ada di localStorage, arahkan langsung ke HomePage
        if (isLoggedIn && clinicId != null && clinicId.isNotEmpty) {
          FULLURL =
              'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/$clinicId.json';
          return MaterialPageRoute(
            builder: (context) => HomePage(id: clinicId),
          );
        }

        // Jika tidak, lanjutkan dengan logika routing biasa
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => const LandingPage(),
          );
        } else if (settings.name != null && settings.name!.startsWith('/')) {
          final String routeClinicId = settings.name!.substring(1);
          FULLURL =
              'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/$routeClinicId.json';

          return MaterialPageRoute(
            builder: (context) => FutureBuilder<UserStatus>(
              future: _checkUserStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text("An error occurred: ${snapshot.error}"),
                    ),
                  );
                } else {
                  switch (snapshot.data) {
                    case UserStatus.loggedInRegistered:
                      return HomePage(id: routeClinicId);
                    case UserStatus.loggedInNotRegistered:
                      return const ClinicRegistrationPage();
                    case UserStatus.notLoggedIn:
                    default:
                      return const LandingPage();
                  }
                }
              },
            ),
          );
        }
        return null;
      },
    );
  }

  Future<UserStatus> _checkUserStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final response = await http.get(Uri.parse(FULLURL));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data != null && data['email'] == user.email) {
          html.window.localStorage['isLoggedIn'] = 'true';
          return UserStatus.loggedInRegistered;
        } else {
          return UserStatus.loggedInNotRegistered;
        }
      } else {
        throw Exception('Failed to load clinic data');
      }
    } else {
      return UserStatus.notLoggedIn;
    }
  }
}

enum UserStatus { loggedInRegistered, loggedInNotRegistered, notLoggedIn }
