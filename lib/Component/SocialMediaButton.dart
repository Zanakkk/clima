// ignore_for_file: file_names

import 'package:flutter/material.dart';

class SocialMediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final LinearGradient gradient;

  const SocialMediaButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8.0), // Membuat sudut kartu menjadi bulat
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient:
                gradient, // Menggunakan gradient yang berbeda untuk tiap tombol
            borderRadius: BorderRadius.circular(
                8.0), // Sesuaikan dengan border radius Card
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                    width:
                        12), // Menambahkan sedikit jarak antara ikon dan teks
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors
                        .white, // Warna teks menjadi putih agar terlihat pada background gradient
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
