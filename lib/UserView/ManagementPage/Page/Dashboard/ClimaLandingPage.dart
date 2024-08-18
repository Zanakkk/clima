// ignore_for_file: non_constant_identifier_names

import 'package:clima/UserView/ManagementPage/Page/Dashboard/ServicesPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../CLIMACONTROL/PricingTableApp.dart';
import 'Client Section.dart';
import 'Footer.dart';
import 'Heading.dart';

const urlHospitalCard =
    'https://firebasestorage.googleapis.com/v0/b/rekammedis-b4f1a.appspot.com/o/Prakarsa%2Fhospitalcard.jpg?alt=media&token=d6fe162a-876c-4037-afbc-3655a5fd0ece';
const urlKlinikCard =
    'https://firebasestorage.googleapis.com/v0/b/rekammedis-b4f1a.appspot.com/o/Prakarsa%2Fklinik.jpg?alt=media&token=60b38f9a-4225-477a-b67a-a1e872a715d7';

// Define the new teal color constants
class ColorPalette {
  static const primaryTeal = Colors.teal;
  static const secondaryTeal = Colors.tealAccent;
  static const primaryTealDark = Colors.tealAccent;
}

class ClimaLandingPage extends StatelessWidget {
  const ClimaLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: ColorPalette.primaryTeal,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: const Scaffold(
        body: LandscapeView(),
      ),
    );
  }
}

class LandscapeView extends StatelessWidget {
  const LandscapeView({super.key});

  final List<Map<String, dynamic>> pricingPlans = const [
    {
      'plan': 'Basic',
      'price': 700000,
      'features': [
        'Lembar SOAP',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Informasi Dokter',
        'Cetak Invoice',
        'Laporan Keuangan Klinik'
      ],
    },
    {
      'plan': 'Advanced',
      'price': 1300000,
      'features': [
        'Fitur Basic',
        'Odontogram',
        'Tindakan Pasien',
        'Informasi Harga',
      ],
    },
    {
      'plan': 'Pro',
      'price': 2000000,
      'features': [
        'Fitur Advanced',
        'Manajemen Data Pasien',
        'Informasi Tindakan',
        'Kirim Invoice Lewat WA',
        'Resep',
        'Laporan Alat Bahan',
        'Laporan Pembayaran Dokter & Staff',
        'Laporan Stok Obat'
      ],
    },
    {
      'plan': 'Custom',
      'price': 'Mulai dari 350.000',
      'features': [
        'Lembar SOAP',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Informasi Dokter',
        'Cetak Invoice',
        'Laporan Keuangan Klinik'
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Heading(),
          _LandingPageCard(
              context,
              const PageSection(
                title: 'PRAKARSA',
                subtitle:
                    'Layanan Sistem Informasi Manajemen KLINIK (SIM - KLINIK)',
              ),
              Colors.blue),
          _LandingPageCard(
              context,
              const ServicesPage(
                imageUrl: '',
                description:
                    'Klinik kami menyediakan berbagai layanan untuk memastikan kesehatan Anda terjaga dengan baik, mulai dari pendaftaran pasien yang mudah, penjadwalan janji temu online, hingga penyimpanan rekam medis elektronik yang aman. Kami juga menawarkan konsultasi dokter spesialis, pemeriksaan laboratorium yang akurat, serta layanan farmasi yang terintegrasi langsung dengan resep dokter. Selain itu, kami menyediakan pemeriksaan kesehatan berkala dan layanan vaksinasi untuk mendukung kesehatan Anda secara menyeluruh',
                title: 'Service',
              ),
              Colors.red),
          _LandingPageCard(
              context,
              Column(
                children: [
                  Text('Plan Klinik',
                      style: GoogleFonts.roboto(
                          fontSize: 36, fontWeight: FontWeight.w700)),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pricingPlans.map((plan) {
                      bool isHighlighted = plan['plan'] == 'Advanced';

                      return PricingCard(
                        plan: plan,
                        isHighlighted: isHighlighted,
                        isAdvancedPlan:
                            isHighlighted, // Tandai jika ini adalah plan Advanced
                      );
                    }).toList(),
                  ),
                ],
              ),
              Colors.purple),
          const OurClientSection(),
          const Footer(),
        ],
      ),
    );
  }

  Widget _LandingPageCard(BuildContext context, Widget widget, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: color..withOpacity(0.6), // Border color
          width: 5, // Border width
        ),
      ),
      child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), // Internal background color
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
              padding: const EdgeInsets.all(72),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                child: widget,
              ))),
    );
  }
}

class PageSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool services;

  const PageSection({
    super.key,
    required this.title,
    this.subtitle,
    this.services = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style:
                GoogleFonts.roboto(fontSize: 64, fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          const SizedBox(height: 24),
          Text(subtitle!,
              style: GoogleFonts.roboto(
                  fontSize: 28, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }
}
