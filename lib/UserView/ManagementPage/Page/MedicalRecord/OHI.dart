// ignore_for_file: non_constant_identifier_names, empty_catches

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OHI extends StatefulWidget {
  const OHI({super.key});

  @override
  State<OHI> createState() => _OHIState();
}

class _OHIState extends State<OHI> {
  // List for debris values: [kanan, ant, kiri]
  List<int> debrisBukalMaxila = [0, 0, 0]; // Maxila Bukal [kanan, ant, kiri]
  List<int> debrisPalatalMaxila = [
    0,
    0,
    0
  ]; // Maxila Palatal [kanan, ant, kiri]
  List<int> debrisBukalMandibula = [
    0,
    0,
    0
  ]; // Mandibula Bukal [kanan, ant, kiri]
  List<int> debrisLingualMandibula = [
    0,
    0,
    0
  ]; // Mandibula Lingual [kanan, ant, kiri]

  // List for kalkulus values: [kanan, ant, kiri]
  List<int> kalkulusBukalMaxila = [0, 0, 0]; // Maxila Bukal [kanan, ant, kiri]
  List<int> kalkulusPalatalMaxila = [
    0,
    0,
    0
  ]; // Maxila Palatal [kanan, ant, kiri]
  List<int> kalkulusBukalMandibula = [
    0,
    0,
    0
  ]; // Mandibula Bukal [kanan, ant, kiri]
  List<int> kalkulusLingualMandibula = [
    0,
    0,
    0
  ]; // Mandibula Lingual [kanan, ant, kiri]

  List<int> index123 = [0, 1, 2, 3];

  final String baseUrl =
      'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/klinikident3558/datapasien/-O65GdveW2IUE0NNU_pC/pemeriksaan/OHI/';

  Future<Map<String, dynamic>> getOHIData() async {
    final url = Uri.parse(baseUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Decode the JSON response into a Map
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        return {};
      }
    } catch (error) {
      return {};
    }
  }

  Future<void> postOHIData(
      String tanggalhariini, Map<String, dynamic> ohiData) async {
    final url = Uri.parse('$baseUrl$tanggalhariini.json');
    try {
      final response = await http.post(
        url,
        body: json.encode(ohiData),
      );
      if (response.statusCode == 200) {
      } else {}
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 4),
          child: Row(
            children: [
              Expanded(child: buildDebrisCard()),
              Expanded(child: buildKalkulusCard()),
            ],
          ),
        ),
        buildSummarySection(),
      ],
    );
  }

  Widget buildDebrisCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Debris',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            // Use the lists to display debris values
            buildRow('Maxila Bukal', debrisBukalMaxila),
            buildRow('Maxila Palatal', debrisPalatalMaxila),
            buildRow('Mandibula Bukal', debrisBukalMandibula),
            buildRow('Mandibula Lingual', debrisLingualMandibula),
          ],
        ),
      ),
    );
  }

  Widget buildKalkulusCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Kalkulus',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            // Use the lists to display kalkulus values
            buildRow('Maxila Bukal', kalkulusBukalMaxila),
            buildRow('Maxila Palatal', kalkulusPalatalMaxila),
            buildRow('Mandibula Bukal', kalkulusBukalMandibula),
            buildRow('Mandibula Lingual', kalkulusLingualMandibula),
          ],
        ),
      ),
    );
  }

  Widget buildSummarySection() {
    int debrisIndex = debrisBukalMaxila.reduce((a, b) => a + b) +
        debrisPalatalMaxila.reduce((a, b) => a + b) +
        debrisBukalMandibula.reduce((a, b) => a + b) +
        debrisLingualMandibula.reduce((a, b) => a + b);

    int kalkulusIndex = kalkulusBukalMaxila.reduce((a, b) => a + b) +
        kalkulusPalatalMaxila.reduce((a, b) => a + b) +
        kalkulusBukalMandibula.reduce((a, b) => a + b) +
        kalkulusLingualMandibula.reduce((a, b) => a + b);

    int OHIIndex = debrisIndex + kalkulusIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                children: [
                  buildSummaryRow('Jumlah Debris Index',
                      (debrisIndex / 6).toStringAsFixed(2)),
                  buildSummaryRow('Jumlah Calculus Index',
                      (kalkulusIndex / 6).toStringAsFixed(2)),
                  buildSummaryRow(
                      'OHI Index', (OHIIndex / 6).toStringAsFixed(2)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                // Ambil tanggal hari ini untuk dimasukkan ke path Firebase
                final tanggalhariini =
                    DateTime.now().toIso8601String().split('T')[0];

                // Siapkan data OHI yang akan dikirim ke Firebase
                final ohiData = {
                  'debrisBukalMaxila': debrisBukalMaxila,
                  'debrisPalatalMaxila': debrisPalatalMaxila,
                  'debrisBukalMandibula': debrisBukalMandibula,
                  'debrisLingualMandibula': debrisLingualMandibula,
                  'kalkulusBukalMaxila': kalkulusBukalMaxila,
                  'kalkulusPalatalMaxila': kalkulusPalatalMaxila,
                  'kalkulusBukalMandibula': kalkulusBukalMandibula,
                  'kalkulusLingualMandibula': kalkulusLingualMandibula,
                };

                // Kirim data OHI ke Firebase
                postOHIData(tanggalhariini, ohiData);

                // Reset indeks setelah data disimpan
                resetIndices();
              },
              child: const Text('Simpan'),
            )),
      ],
    );
  }

  Widget buildRow(String label, List<int> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 200,
          child: Text(label),
        ),
        SizedBox(
          width: 40,
          child: buildDropdown(values[0], (newValue) {
            setState(() {
              values[0] = newValue;
            });
          }),
        ),
        SizedBox(
          width: 40,
          child: buildDropdown(values[1], (newValue) {
            setState(() {
              values[1] = newValue;
            });
          }),
        ),
        SizedBox(
          width: 40,
          child: buildDropdown(values[2], (newValue) {
            setState(() {
              values[2] = newValue;
            });
          }),
        ),
      ],
    );
  }

  Widget buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.black)),
        Text(value,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.black)),
      ],
    );
  }

  DropdownButton<int> buildDropdown(
      int value, Function(int) onChangedCallback) {
    return DropdownButton<int>(
      value: value,
      elevation: 10,
      items: index123.map((int e) {
        return DropdownMenuItem<int>(
          value: e,
          child: Text(e.toString()),
        );
      }).toList(),
      onChanged: (int? newValue) {
        if (newValue != null) {
          onChangedCallback(newValue);
        }
      },
    );
  }

  void resetIndices() {
    setState(() {
      // Reset all debris and kalkulus values to 0
      debrisBukalMaxila = [0, 0, 0];
      debrisPalatalMaxila = [0, 0, 0];
      debrisBukalMandibula = [0, 0, 0];
      debrisLingualMandibula = [0, 0, 0];

      kalkulusBukalMaxila = [0, 0, 0];
      kalkulusPalatalMaxila = [0, 0, 0];
      kalkulusBukalMandibula = [0, 0, 0];
      kalkulusLingualMandibula = [0, 0, 0];
    });
  }
}

class OHIPage extends StatefulWidget {
  const OHIPage({super.key});

  @override
  State<OHIPage> createState() => _OHIPageState();
}

class _OHIPageState extends State<OHIPage> {
  Map<String, dynamic>? ohiData;
  List<String> availableDates = []; // Available dates for the dropdown
  String? selectedDate; // The currently selected date
  bool isLoading = true;

  final String baseUrl =
      'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/klinikident3558/datapasien/-O65GdveW2IUE0NNU_pC/pemeriksaan/OHI.json';

  Future<void> fetchOHIData() async {
    final url = Uri.parse(baseUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          ohiData = data;
          availableDates = data.keys.toList(); // Get all available dates
          if (availableDates.isNotEmpty) {
            selectedDate = availableDates.first; // Default to the first date
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOHIData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OHI Data")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                buildDatePicker(), // Build the date picker dropdown
                const SizedBox(height: 16),
                selectedDate != null && ohiData != null
                    ? Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width / 4),
                          children: [
                            Row(
                              children: [
                                Expanded(child: buildDebrisCard()),
                                Expanded(child: buildKalkulusCard()),
                              ],
                            ),
                            buildSummarySection(),
                          ],
                        ),
                      )
                    : const Center(child: Text("No Data Available")),
              ],
            ),
    );
  }

  Widget buildDatePicker() {
    return DropdownButton<String>(
      value: selectedDate,
      hint: const Text("Select Date"),
      onChanged: (String? newValue) {
        setState(() {
          selectedDate = newValue;
        });
      },
      items: availableDates.map<DropdownMenuItem<String>>((String date) {
        return DropdownMenuItem<String>(
          value: date,
          child: Text(date),
        );
      }).toList(),
    );
  }

  Widget buildDebrisCard() {
    final debrisData = ohiData?[selectedDate]?['-O65kVAKcoDKzVjAhzQt'];
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Debris',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            buildRow('Maxila Bukal', debrisData?['debrisBukalMaxila']),
            buildRow('Maxila Palatal', debrisData?['debrisPalatalMaxila']),
            buildRow('Mandibula Bukal', debrisData?['debrisBukalMandibula']),
            buildRow(
                'Mandibula Lingual', debrisData?['debrisLingualMandibula']),
          ],
        ),
      ),
    );
  }

  Widget buildKalkulusCard() {
    final kalkulusData = ohiData?[selectedDate]?['-O65kVAKcoDKzVjAhzQt'];
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Kalkulus',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            buildRow('Maxila Bukal', kalkulusData?['kalkulusBukalMaxila']),
            buildRow('Maxila Palatal', kalkulusData?['kalkulusPalatalMaxila']),
            buildRow(
                'Mandibula Bukal', kalkulusData?['kalkulusBukalMandibula']),
            buildRow(
                'Mandibula Lingual', kalkulusData?['kalkulusLingualMandibula']),
          ],
        ),
      ),
    );
  }

  Widget buildSummarySection() {
    final debrisData = ohiData?[selectedDate]?['-O65kVAKcoDKzVjAhzQt'];
    final kalkulusData = ohiData?[selectedDate]?['-O65kVAKcoDKzVjAhzQt'];

    int debrisIndex = debrisData?['debrisBukalMaxila']
            ?.reduce((a, b) => a + b) ??
        0 + debrisData?['debrisPalatalMaxila']?.reduce((a, b) => a + b) ??
        0 + debrisData?['debrisBukalMandibula']?.reduce((a, b) => a + b) ??
        0 + debrisData?['debrisLingualMandibula']?.reduce((a, b) => a + b) ??
        0;

    int kalkulusIndex = kalkulusData?['kalkulusBukalMaxila']
            ?.reduce((a, b) => a + b) ??
        0 + kalkulusData?['kalkulusPalatalMaxila']?.reduce((a, b) => a + b) ??
        0 + kalkulusData?['kalkulusBukalMandibula']?.reduce((a, b) => a + b) ??
        0 +
            kalkulusData?['kalkulusLingualMandibula']
                ?.reduce((a, b) => a + b) ??
        0;

    int OHIIndex = debrisIndex + kalkulusIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: SizedBox(
            width: 250,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                children: [
                  buildSummaryRow('Jumlah Debris Index',
                      (debrisIndex / 6).toStringAsFixed(2)),
                  buildSummaryRow('Jumlah Kalkulus Index',
                      (kalkulusIndex / 6).toStringAsFixed(2)),
                  buildSummaryRow(
                      'OHI Index', (OHIIndex / 6).toStringAsFixed(2)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRow(String label, List<dynamic>? values) {
    if (values == null) return const Text("No Data");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 200,
          child: Text(label),
        ),
        SizedBox(width: 40, child: Text(values[0].toString())),
        SizedBox(width: 40, child: Text(values[1].toString())),
        SizedBox(width: 40, child: Text(values[2].toString())),
      ],
    );
  }

  Widget buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.black)),
        Text(value,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.black)),
      ],
    );
  }
}

class OHIService {
  final String baseUrl =
      'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/klinikident3558/datapasien/-O65GdveW2IUE0NNU_pC/pemeriksaan.json';

  Future<Map<String, dynamic>> getOHIData() async {
    final url = Uri.parse(baseUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Decode the JSON response into a Map
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        return {};
      }
    } catch (error) {
      return {};
    }
  }
}
