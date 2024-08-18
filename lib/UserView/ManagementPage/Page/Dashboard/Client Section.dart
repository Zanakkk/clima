import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class OurClientSection extends StatefulWidget {
  @override
  _OurClientSectionState createState() => _OurClientSectionState();
}

class _OurClientSectionState extends State<OurClientSection> {
  final ScrollController _scrollController = ScrollController();
  final double _scrollSpeed = 1.5;

  @override
  void initState() {
    super.initState();
    _startScrolling();
  }

  void _startScrolling() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scroll();
    });
  }

  void _scroll() async {
    while (_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 30));
      _scrollController.jumpTo(_scrollController.offset + _scrollSpeed);
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(0); // Reset to the beginning when reaching the end
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {final List<Map<String, String>> clients = [

    {
      'name': 'drg Farah',
      'image': 'https://via.placeholder.com/150',
      'description': 'Sebagai dokter gigi di Zanak Dental Clinic, saya sangat terbantu dengan sistem manajemen klinik yang disediakan oleh CLIMA. Ini sangat memudahkan dalam manajemen pasien dan pengelolaan data medis.',
    },
    {
      'name': 'dr. Fauzan',
      'image': 'https://via.placeholder.com/150',
      'description': 'Implementasi CLIMA di klinik kami memberikan kemudahan dalam mengatur jadwal pasien dan laporan keuangan. Sangat efektif dan user-friendly!',
    },
    {
      'name': 'dr. Vania',
      'image': 'https://via.placeholder.com/150',
      'description': 'Klinik kami telah menggunakan CLIMA selama 3 tahun dan kami sangat puas dengan semua fitur-fiturnya. Manajemen data pasien lebih terstruktur dan efisien.',
    },
    {
      'name': 'dr. Rizal',
      'image': 'https://via.placeholder.com/150',
      'description': 'Dengan CLIMA, proses manajemen klinik kami menjadi lebih lancar. Kami sangat merekomendasikan platform ini untuk klinik-klinik lainnya.',
    },
    {
      'name': 'drg Liana',
      'image': 'https://via.placeholder.com/150',
      'description': 'CLIMA adalah solusi manajemen klinik terbaik yang pernah kami gunakan. Proses administrasi dan pengelolaan pasien jadi lebih mudah dan cepat.',
    },
  ];


  return SizedBox(
    height: 240,
    child: ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemCount: clients.length * 1000, // High number to simulate infinity
      itemBuilder: (context, index) {
        final client = clients[index % clients.length]; // Recycle the clients infinitely
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildClientCard(client['name']!, client['image']!, client['description']!),
        );
      },
    ),
  );
  }

  Widget _buildClientCard(String name, String imageUrl, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, height: 100, width: 100, fit: BoxFit.cover),
            ),
            SizedBox(
              width: 24,
            ),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold,),
                  textAlign: TextAlign.justify,),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),),

          ],
        ),
      ),
    );
  }
}


