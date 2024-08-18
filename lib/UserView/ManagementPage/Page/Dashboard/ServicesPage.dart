import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const urlHospitalCard =
    'https://via.placeholder.com/400x300'; // Replace with actual image link
const urlKlinikCard =
    'https://via.placeholder.com/400x300'; // Replace with actual image link

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Placeholder(),
            ),
            const SizedBox(width: 16),
            // Description Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
