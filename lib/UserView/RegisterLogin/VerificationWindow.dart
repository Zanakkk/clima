import 'package:flutter/material.dart';



// Halaman Aktivasi
class ActivationPage extends StatelessWidget {
  const ActivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activation'),
      ),
      body: const Center(
        child: Text(
          "Tunggu diverifikasi oleh admin.",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}