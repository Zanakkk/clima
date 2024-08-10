// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final String label;
  final VoidCallback onClose;
  final Function(String, String, String) onConditionChanged;
  final Function(String, bool) onRCTChanged;
  final List<Map<String, dynamic>> toothConditions;

  const DetailPage({
    required this.label,
    required this.onClose,
    required this.onConditionChanged,
    required this.onRCTChanged,
    required this.toothConditions,
    super.key,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String? selectedMesial;
  String? selectedDistal;
  String? selectedBukal;
  String? selectedPalatal;
  String? selectedOclusal;
  bool showTriangle = false;

  @override
  void initState() {
    super.initState();
    var toothCondition = widget.toothConditions.firstWhere(
        (element) => element['label'] == widget.label,
        orElse: () => {'label': widget.label});

    selectedMesial = toothCondition['mesial'];
    selectedDistal = toothCondition['distal'];
    selectedBukal = toothCondition['bukal'];
    selectedPalatal = toothCondition['palatal'];
    selectedOclusal = toothCondition['oclusal'];
    showTriangle = toothCondition['rct'] ?? false;
  }

  void _toggleRCT(bool value) {
    setState(() {
      showTriangle = value;
      widget.onRCTChanged(widget.label, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> options = ['karies', 'komposit', 'gic'];
    bool showOclusal = ![
      '13',
      '12',
      '11',
      '21',
      '22',
      '23',
      '43',
      '42',
      '41',
      '31',
      '32',
      '33'
    ].contains(widget.label);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.label,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('RCT'),
              value: showTriangle,
              onChanged: _toggleRCT,
            ),
            Expanded(
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedMesial,
                    decoration: const InputDecoration(labelText: 'Mesial'),
                    items: options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedMesial = newValue;
                        widget.onConditionChanged(
                            widget.label, 'mesial', newValue!);
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedDistal,
                    decoration: const InputDecoration(labelText: 'Distal'),
                    items: options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedDistal = newValue;
                        widget.onConditionChanged(
                            widget.label, 'distal', newValue!);
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedBukal,
                    decoration: const InputDecoration(labelText: 'Bukal'),
                    items: options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedBukal = newValue;
                        widget.onConditionChanged(
                            widget.label, 'bukal', newValue!);
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPalatal,
                    decoration: const InputDecoration(labelText: 'Palatal'),
                    items: options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedPalatal = newValue;
                        widget.onConditionChanged(
                            widget.label, 'palatal', newValue!);
                      });
                    },
                  ),
                  if (showOclusal)
                    DropdownButtonFormField<String>(
                      value: selectedOclusal,
                      decoration: const InputDecoration(labelText: 'Oclusal'),
                      items: options.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedOclusal = newValue;
                          widget.onConditionChanged(
                              widget.label, 'oclusal', newValue!);
                        });
                      },
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
