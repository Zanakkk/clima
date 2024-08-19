// ignore_for_file: avoid_web_libraries_in_flutter, library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable

import 'package:clima/UserView/RegisterLogin/Login/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'InputData.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _registerWithEmailPassword() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Validasi: Pastikan semua bidang terisi
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("All fields are required.");
      return;
    }

    // Validasi: Pastikan password cocok
    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match.");
      return;
    }

    // Validasi: Pastikan password sesuai dengan kriteria
    if (!_isValidPassword(password)) {
      _showSnackBar(
          "Password must be at least 8 characters long, contain 1 uppercase letter, 1 lowercase letter, and 1 number.");
      return;
    }

    try {
      // Proses registrasi pengguna di Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showSnackBar("User registered successfully!");

      // Navigasi ke halaman pendaftaran klinik setelah berhasil registrasi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ClinicRegistrationPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Menangani berbagai kemungkinan kesalahan dari Firebase Auth
      if (e.code == 'email-already-in-use') {
        _showSnackBar(
            "The email address is already in use by another account.");
      } else if (e.code == 'weak-password') {
        _showSnackBar("The password is too weak.");
      } else if (e.code == 'invalid-email') {
        _showSnackBar("The email address is invalid.");
      } else {
        _showSnackBar("An error occurred: ${e.message}");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    }
  }

// Fungsi untuk menampilkan pesan di SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

// Validasi password yang lebih ketat
  bool _isValidPassword(String password) {
    // Password harus minimal 8 karakter, mengandung 1 huruf kapital, 1 huruf kecil, dan 1 angka
    final RegExp passwordRegExp =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: 1200,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Colors.black.withOpacity(0.6),
                width: 5,
              ),
            ),
            child: Row(
              children: [
                // Left side with image and text
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: Colors.black.withOpacity(0.6),
                        width: 5,
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
                // Right side with registration form
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 48.0, horizontal: 72),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          children: [
                            SizedBox(height: 24),
                            Text(
                              'Create an Account!',
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
                            _buildTextField(
                              controller: _emailController,
                              labelText: 'Email',
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              controller: _passwordController,
                              labelText: 'Password',
                              isPasswordVisible: _isPasswordVisible,
                              onVisibilityToggle: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirm Password',
                              isPasswordVisible: _isConfirmPasswordVisible,
                              onVisibilityToggle: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _registerWithEmailPassword,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 24.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'REGISTER',
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
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child:
                                  const Text('Sudah Punya Akun? Login di sini'),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(prefixIcon),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
      obscureText: !isPasswordVisible,
    );
  }
}
