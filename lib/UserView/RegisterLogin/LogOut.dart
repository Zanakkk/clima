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
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Colors.red
                    .withOpacity(0.6), // Garis tepi dengan opacity 0.6
                width: 2, // Ketebalan garis tepi
              ),
            ),
            child: Container(
              width: 400,
              height: 200,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color:
                    Colors.red.withOpacity(0.1), // Isi dalam dengan opacity 0.1
                borderRadius:
                    BorderRadius.circular(24), // Menyesuaikan border Card
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Are you sure you want to log out?',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Logout'),
                            content:
                                const Text('Do you really want to log out?'),
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
        ),
      ),
    );
  }
}
