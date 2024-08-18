import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade800, // Background color of the footer
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Top Section: Logo and Tagline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    child: Image.asset(
                      'assets/LOGO.jpg',
                      width: 96,
                      height: 96,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    children: [
                      Text(
                        'Atur Klinik Tanpa Ribet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        'hanya dengan CLIMA',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColumn(
                    title: 'Social Media',
                    links: [
                      _buildFooterLink('Instagram',
                          'https://www.instagram.com/clima.health/'),
                      _buildFooterLink(
                          'WhatsApp', 'https://wa.me/6282387696487'),
                    ],
                  ),
                  const SizedBox(
                    width: 36,
                  ),
                  _buildColumn(
                    title: 'Company',
                    links: [
                      _buildFooterLink('Kontak Kami', '/contact-us'),
                      _buildFooterLink('Tentang Kami', '/about-us'),
                      _buildFooterLink('Testimoni', '/testimonials'),
                      _buildFooterLink('Blog', 'https://www.zenius.net/blog/'),
                    ],
                  ),
                  const SizedBox(
                    width: 36,
                  ),
                  _buildColumn(
                    title: 'Terms & Policies',
                    links: [
                      _buildFooterLink('Kebijakan Privasi', '/privacy-policy'),
                      _buildFooterLink(
                          'Ketentuan Penggunaan', '/terms-and-conditions'),
                    ],
                  ),
                  const SizedBox(
                    width: 36,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Copyright Section
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '© CLIMA, 2024.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a column for each section
  Widget _buildColumn({required String title, required List<Widget> links}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...links,
      ],
    );
  }

  // Helper method to build each link
  Widget _buildFooterLink(String label, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  // Method to launch URL
  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}
