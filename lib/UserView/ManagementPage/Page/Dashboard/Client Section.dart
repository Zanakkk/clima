// ignore_for_file: library_private_types_in_public_api, empty_catches

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class OurClientSection extends StatefulWidget {
  const OurClientSection({super.key});

  @override
  _OurClientSectionState createState() => _OurClientSectionState();
}

class _OurClientSectionState extends State<OurClientSection> {
  final ScrollController _scrollController = ScrollController();
  final double _scrollSpeed = 1.5;
  List<Map<String, String>> clients = [];

  @override
  void initState() {
    super.initState();

    getData();
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
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent) {
        _scrollController
            .jumpTo(0); // Reset to the beginning when reaching the end
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    final url = Uri.parse(
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/CLIMA/Testimoni.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        List<Map<String, String>> loadedClients = [];
        data.forEach((key, value) {
          loadedClients.add({
            'name': value['name'] ?? '',
            'image': value['image'] ?? '',
            'description': value['description'] ?? '',
          });
        });

        setState(() {
          clients = loadedClients;
        });
      } else {}
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: clients.length * 1000, // High number to simulate infinity
        itemBuilder: (context, index) {
          final client =
              clients[index % clients.length]; // Recycle the clients infinitely
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildClientCard(
                client['name']!, client['image']!, client['description']!),
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
              child: Image.network(imageUrl,
                  height: 100, width: 100, fit: BoxFit.cover),
            ),
            const SizedBox(
              width: 24,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.roboto(
                        fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.justify,
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
