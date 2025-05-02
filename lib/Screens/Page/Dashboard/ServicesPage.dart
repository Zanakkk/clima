import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const ServicesPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Image Section

            Expanded(
              flex: 3,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip
                    .antiAlias, // Memastikan gambar terpotong sesuai dengan radius card
                child: Image.asset(
                  'assets/LandingPage/hospital.jpg',
                  fit: BoxFit.cover, // Gambar memenuhi seluruh card
                  height: double.infinity, // Menghilangkan batasan tinggi
                  width: double
                      .infinity, // Memastikan gambar mengisi seluruh lebar card
                ),
              ),
            ),

            const SizedBox(width: 16),
            // Description Section
            Expanded(
                flex: 3, // Teks lebih besar dari gambar
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Menambahkan warna teks
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[
                              700], // Memberikan warna teks yang lebih lembut
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
