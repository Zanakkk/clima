// ignore_for_file: avoid_web_libraries_in_flutter, library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import '../../ManagementPage/HomePage.dart';
import 'InputDataKlinik.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    // Periksa apakah pengguna sudah login sebelumnya
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
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final email = _emailController.text;
      final url = Uri.parse(
          'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        String? clinicId;
        data.forEach((id, clinic) {
          if (clinic['email'] == email) {
            clinicId = id;
          }
        });

        if (clinicId != null) {
          // Simpan status login dan clinicId di localStorage
          html.window.localStorage['isLoggedIn'] = 'true';
          html.window.localStorage['clinicId'] = clinicId!;

          // Ubah URL tanpa melakukan reload halaman
          final newUrl = '#/$clinicId';
          html.window.history.replaceState(null, 'Clinic', newUrl);

          // Navigasi ke halaman HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(id: clinicId!),
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
      } else {
        throw Exception('Failed to load clinics');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loginWithEmailPassword,
              child: const Text('Login with Email and Password'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterUserPage(),
                  ),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
