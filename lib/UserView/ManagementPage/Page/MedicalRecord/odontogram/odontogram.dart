// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'Anterior.dart';
import 'DetailPage.dart';
import 'Posterior.dart';
import 'RCT.dart';

class Odontogram extends StatefulWidget {
  const Odontogram({super.key});

  @override
  State<Odontogram> createState() => _OdontogramState();
}

class _OdontogramState extends State<Odontogram> {
  String? selectedLabel;
  List<Map<String, dynamic>> toothConditions = List.generate(
    32,
    (index) => {
      'label': '', // Pastikan label diisi dengan benar saat inisialisasi
      'mesial': null,
      'distal': null,
      'bukal': null,
      'palatal': null,
      'oclusal': null,
      'rct': false,
      'teks_atas': null, // Menambahkan teks atas
      'teks_bawah': null, // Menambahkan teks bawah
    },
  );

  void _onShapeTapped(String label) {
    setState(() {
      if (selectedLabel == label) {
        selectedLabel =
            null; // Hide the DetailPage if the same label is tapped again
      } else {
        selectedLabel = label; // Show the DetailPage for the new label
      }
    });
  }

  void _updateToothCondition(
      String label, String part, String condition, bool? rct) {
    setState(() {
      int index =
          toothConditions.indexWhere((element) => element['label'] == label);
      if (index != -1) {
        toothConditions[index][part] = condition;
        if (part == 'teks_atas') {
          toothConditions[index]['teks_atas'] = condition;
        }
        if (part == 'teks_bawah') {
          toothConditions[index]['teks_bawah'] = condition;
        }
        if (rct != null) {
          toothConditions[index]['rct'] = rct;
        }
      } else {
        toothConditions.add({
          'label': label,
          'mesial': part == 'mesial' ? condition : null,
          'distal': part == 'distal' ? condition : null,
          'bukal': part == 'bukal' ? condition : null,
          'palatal': part == 'palatal' ? condition : null,
          'oclusal': part == 'oclusal' ? condition : null,
          'rct': rct ?? false,
          'teks_atas': part == 'teks_atas' ? condition : null,
          'teks_bawah': part == 'teks_bawah' ? condition : null,
        });
      }
    });
  }

  void _closeDetailPage() {
    setState(() {
      selectedLabel = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Shape Grid Example'),
      ),
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ShapeGridPage(
              onShapeTapped: _onShapeTapped,
              toothConditions: toothConditions,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: const Offset(0, 0),
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: selectedLabel != null
                  ? DetailPage(
                      key: ValueKey<String>(selectedLabel!),
                      label: selectedLabel!,
                      onClose: _closeDetailPage,
                      onConditionChanged: (label, part, condition) =>
                          _updateToothCondition(label, part, condition, null),
                      onRCTChanged: (label, value) =>
                          _updateToothCondition(label, '', '', value),
                      toothConditions: toothConditions,
                    )
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class ShapeGridPage extends StatefulWidget {
  final Function(String) onShapeTapped;
  final List<Map<String, dynamic>> toothConditions;

  const ShapeGridPage({
    super.key,
    required this.onShapeTapped,
    required this.toothConditions,
  });

  @override
  _ShapeGridPageState createState() => _ShapeGridPageState();
}

class _ShapeGridPageState extends State<ShapeGridPage> {
  final List<bool> _isBlueList = List.generate(32, (_) => false);
  int? _selectedIndex;

  void _toggleShapeColor(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _isBlueList[index] = !_isBlueList[index];
        if (!_isBlueList[index]) {
          _selectedIndex = null;
        }
      } else {
        if (_selectedIndex != null) {
          _isBlueList[_selectedIndex!] = false;
        }
        _isBlueList[index] = true;
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      '18',
      '17',
      '16',
      '15',
      '14',
      '13',
      '12',
      '11',
      '21',
      '22',
      '23',
      '24',
      '25',
      '26',
      '27',
      '28',
      '48',
      '47',
      '46',
      '45',
      '44',
      '43',
      '42',
      '41',
      '31',
      '32',
      '33',
      '34',
      '35',
      '36',
      '37',
      '38',
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemSize = screenWidth / 16 * 0.75;
    Widget buildToothItem(int index, String label) {
      // Mendapatkan kondisi gigi yang sesuai dengan label
      final toothCondition = widget.toothConditions.firstWhere(
            (element) => element['label'] == label,
        orElse: () => {'label': label},
      );

      // Cek apakah gigi adalah posterior atau anterior
      final isPosterior = [
        '18',
        '17',
        '16',
        '15',
        '14',
        '24',
        '25',
        '26',
        '27',
        '28',
        '48',
        '47',
        '46',
        '45',
        '44',
        '34',
        '35',
        '36',
        '37',
        '38'
      ].contains(label);

      // Menentukan painter sesuai dengan jenis gigi
      final painter = isPosterior
          ? Posterior(
        isBlue: _isBlueList[index],
        conditions: toothCondition,
        label: label,
      )
          : Anterior(
        isBlue: _isBlueList[index],
        conditions: toothCondition,
        label: label,
      );

      // Cek apakah RCT harus ditampilkan
      final bool showTriangle = toothCondition['rct'] ?? false;

      // Mendapatkan teks atas
      final String teksAtas = toothCondition['teks_atas'] ?? '';

      // Kelompokkan berdasarkan label untuk posisi label gigi
      final bool isUpperTeeth = ['18', '17', '16', '15', '14', '13', '12', '11', '21', '22', '23', '24', '25', '26', '27', '28'].contains(label);
      final bool isLowerTeeth = ['48', '47', '46', '45', '44', '43', '42', '41', '31', '32', '33', '34', '35', '36', '37', '38'].contains(label);

      return SizedBox(
        width: itemSize,
        height: 140, // Disesuaikan untuk menampung teks tambahan
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Jika gigi atas, tampilkan label di atas
            if (isUpperTeeth)
              Column(
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                ],
              ),

            // Tampilkan teks atas jika ada
            Text(
              teksAtas,
              style: const TextStyle(fontSize: 10, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Bagian utama: kotak gigi
            InkWell(
              onTap: () {
                _toggleShapeColor(index);
                widget.onShapeTapped(label);
              },
              child: SizedBox(
                height: itemSize * 0.75,
                width: itemSize * 0.75,
                child: CustomPaint(
                  painter: painter,
                  child: Container(),
                ),
              ),
            ),

            // Tampilkan triangle jika RCT aktif
            if (showTriangle)
              const SizedBox(
                height: 10,
                child: InvertedTriangleWidget(),
              )
            else
              const SizedBox(
                height: 10,
              ),

            // Jika gigi bawah, tampilkan label di bawah
            if (isLowerTeeth)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      );
    }


    return Column(
      children: [
        Wrap(
          spacing: 2,
          runSpacing: 8,
          children: List.generate(16, (index) {
            return buildToothItem(index, labels[index]);
          }),
        ),
        const SizedBox(height: 20), // Spacing between the rows
        Wrap(
          spacing: 2,
          runSpacing: 8,
          children: List.generate(16, (index) {
            return buildToothItem(index + 16, labels[index + 16]);
          }),
        ),
      ],
    );
  }
}
