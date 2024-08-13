// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:html' as html; // Import untuk penggunaan localStorage
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../LandingPage.dart';

class LogOut extends StatelessWidget {
  const LogOut({super.key});

  Future<void> _performLogout(BuildContext context) async {
    // Hapus data dari localStorage
    html.window.localStorage.remove('isLoggedIn');
    html.window.localStorage.remove('clinicId');

    // Logout dari Firebase Authentication
    await FirebaseAuth.instance.signOut();

    // Arahkan ke halaman login (LandingPage)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Are you sure you want to log out?',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Konfirmasi logout
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Logout'),
                        content: const Text('Do you really want to log out?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Tutup dialog
                              _performLogout(context); // Lakukan logout
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
