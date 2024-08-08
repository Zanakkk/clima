// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:clima/UserView/LandingPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'API/AuthServices.dart';
class SignInScreen extends StatefulWidget {
  const SignInScreen({required this.url, super.key});

  final String url;
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // ignore: unused_local_variable
      UserCredential? userCredential = await AuthServices.signInWithGoogleWEB();
      // Jika berhasil, arahkan ke halaman home atau lakukan tindakan lainnya
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LandingPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            Image(
              image: NetworkImage(widget.url),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: InkWell(
                        onTap: _signInWithGoogle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Text(
                            'Coba Buat Sendiri',
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
            )
          ],
        ),
      ),
    );
  }
}
