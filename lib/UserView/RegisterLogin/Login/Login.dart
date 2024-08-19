// ignore_for_file: avoid_web_libraries_in_flutter, library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import '../../ManagementPage/HomePage.dart';
import '../Register/InputData.dart';
import '../Register/Register.dart';
import '../VerificationWindow.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    if (html.window.localStorage['isLoggedIn'] == 'true') {
      final clinicId = html.window.localStorage['clinicId'];
      if (clinicId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(id: clinicId),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ClinicRegistrationPage(),
          ),
        );
      }
    }
  }

  Future<void> _loginWithEmailPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Login pengguna menggunakan Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final email = _emailController.text;
      final url = Uri.parse(
          'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse data dari Firebase
        final data = json.decode(response.body) as Map<String, dynamic>;
        String? clinicId;
        bool? climaActive;

        // Cari clinicId berdasarkan email
        data.forEach((id, clinic) {
          if (clinic['email'] == email) {
            clinicId = id;
            climaActive =
                clinic['ClimaActive'] ?? false; // Ambil ClimaActive dari data
          }
        });

        // Jika clinicId ditemukan
        if (clinicId != null) {
          // Simpan status login dan clinicId di localStorage
          html.window.localStorage['isLoggedIn'] = 'true';
          html.window.localStorage['clinicId'] = clinicId!;
          final newUrl = '#/$clinicId';
          html.window.history.replaceState(null, 'Clinic', newUrl);

          // Cek status ClimaActive
          if (climaActive == true) {
            // Jika ClimaActive adalah true, navigasi ke HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(id: clinicId!),
              ),
            );
          } else {
            // Jika ClimaActive adalah false, navigasi ke halaman ActivationPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ActivationPage(),
              ),
            );
          }
        } else {
          // Jika clinicId tidak ditemukan, arahkan ke halaman pendaftaran klinik
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ClinicRegistrationPage(),
            ),
          );
        }
      } else {
        throw Exception('Failed to load clinics');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: 1200, // Adjust width for larger screens
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: Colors.black.withOpacity(0.6), // Border color
                  width: 5, // Border width
                ),
              ),
              child: Row(
                children: [
                  // Bagian Kiri - Gambar dan Teks
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: Colors.black.withOpacity(0.6), // Border color
                          width: 5, // Border width
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/LOGO.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Digitalisasi Klinikmu dengan CLIMA",
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bagian Kanan - Form Login
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 48.0, horizontal: 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            children: [
                              SizedBox(height: 24),
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 24),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  prefixIcon: const Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  prefixIcon: const Icon(Icons.lock),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 24),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _loginWithEmailPassword,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0, horizontal: 24.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                        child: const Text(
                                          'LOGIN',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 16),
                              const Text("or",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterUserPage(),
                                    ),
                                  );
                                },
                                child: const Text('Belum Punya Akun ?'),
                              ),
                              const SizedBox(height: 24),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
