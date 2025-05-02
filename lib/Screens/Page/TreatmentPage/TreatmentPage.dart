// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../HomePage.dart';
import 'PasienListPage.dart';
import 'AddTreatmentPage.dart';
import 'InvoicePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class TreatmentsPage extends StatefulWidget {
  const TreatmentsPage({super.key});

  @override
  _TreatmentsPageState createState() => _TreatmentsPageState();
}

class _TreatmentsPageState extends State<TreatmentsPage> {
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _selectedPatient;
  Map<String, dynamic>? _selectedTindakan;
  Map<String, dynamic>? _selectedProcedure; // Store both name and price
  final TextEditingController _procedureExplanationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPatients(); // Memastikan data selalu diambil setiap kali halaman diakses kembali
  }

  Future<void> _fetchPatients() async {
    final pasienUrl = Uri.parse('$FULLURL/datapasien.json');
    final tindakanUrl = Uri.parse('$FULLURL/tindakan.json');
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    // Ambil data pasien terlebih dahulu
    final pasienResponse = await http.get(pasienUrl);

    if (pasienResponse.statusCode == 200) {
      final Map<String, dynamic>? pasienData = json.decode(pasienResponse.body);
      if (pasienData != null) {
        // Ambil data tindakan
        final tindakanResponse = await http.get(tindakanUrl);

        if (tindakanResponse.statusCode == 200) {
          final Map<String, dynamic>? tindakanData =
              json.decode(tindakanResponse.body);
          if (tindakanData != null) {
            // Buat daftar untuk menyimpan data pasien yang relevan dengan tindakan hari ini
            List<Map<String, dynamic>> patients = [];

            for (var entry in tindakanData.entries) {
              final tindakanItem = entry.value;
              final tindakanTimestamp =
                  DateTime.parse(tindakanItem['timestamp']);

              // Cek apakah tindakan terjadi pada hari ini
              if (DateFormat('yyyy-MM-dd').format(tindakanTimestamp) == today) {
                final idpasien = tindakanItem['idpasien'];

                // Ambil data pasien berdasarkan idpasien
                if (pasienData.containsKey(idpasien)) {
                  final pasien = pasienData[idpasien];
                  patients.add({'id': idpasien, ...pasien});
                }
              }
            }

            // Update state dengan data pasien yang relevan
            setState(() {
              _patients = patients;
            });
          }
        } else {
          // Handle error jika gagal mengambil data tindakan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch tindakan data.')),
          );
        }
      }
    } else {
      // Handle error jika gagal mengambil data pasien
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch patients.')),
      );
    }
  }

  // Add procedure to tindakan
  Future<void> _addProcedure() async {
    if (_selectedPatient == null ||
        _selectedProcedure == null ||
        _selectedTindakan == null) {
      return;
    }

    final int price =
        _selectedProcedure!['price']; // Use selected procedure price
    final String explanation = _procedureExplanationController.text.trim();

    // Buat body untuk POST
    final newProcedure = {
      'procedure': _selectedProcedure!['name'],
      'price': price,
      'explanation': explanation.isNotEmpty ? explanation : null,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final url = Uri.parse(
        '$FULLURL/tindakan/${_selectedTindakan!['id']}/procedure.json');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newProcedure),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procedure added successfully.')),
      );
      _fetchTindakanData(); // Refresh the data
      _procedureExplanationController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add procedure.')),
      );
    }
  }

  // Fetch tindakan data
  Future<void> _fetchTindakanData() async {
    if (_selectedPatient == null) return;

    final url = Uri.parse('$FULLURL/tindakan.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        String? tindakanId;

        // Iterate over tindakan to find the one matching idpasien
        data.forEach((key, value) {
          if (value['idpasien'] == _selectedPatient!['id']) {
            tindakanId = key;
            _selectedTindakan = value;
          }
        });

        // Update state with tindakanId found
        setState(() {
          if (tindakanId != null) {
            _selectedTindakan!['id'] =
                tindakanId; // Save tindakanId to _selectedTindakan
          } else {
            _selectedTindakan = null; // If no tindakan found
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch tindakan data.')),
      );
    }
  }

  // Send invoice to WhatsApp
  Future<void> _sendInvoice() async {
    if (_selectedPatient == null || _selectedTindakan == null) return;

    final String tindakanId = _selectedTindakan!['id'];
    final String url = '$FULLURL/tindakan/$tindakanId/procedure.json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        // Build invoice message
        String message = '🧾 *Invoice* 🧾\n\n';

        // Format Date and Time
        final DateTime now = DateTime.now();
        final String formattedDate = _formatDate(now);
        final String formattedTime = _formatTime(now);

        // Patient and Doctor Information
        message += '👤 *Nama Pasien:* ${_selectedPatient!['fullName']}\n';
        message +=
            '🩺 *Dokter:* drg daffa\n'; // Assuming static doctor name for now
        message += '📅 *Tanggal:* $formattedDate\n';
        message += '🕒 *Pukul:* $formattedTime\n\n';

        // Detail Tindakan
        message += '📝 *Detail Tindakan:*\n';
        double totalCost = 0.0;

        data.forEach((key, procedure) {
          final procedureName = procedure['procedure'] ?? 'Unknown';
          final price = procedure['price'] ?? 0;
          final explanation = procedure['explanation'] ?? '';

          message += '🔹 *$procedureName*: Rp$price';
          if (explanation.isNotEmpty) {
            message += ' _(💬 Keterangan: $explanation)_';
          }
          message += '\n';

          totalCost += price;
        });

        // Total Cost
        message += '\n💵 *Total Biaya:* Rp${totalCost.toStringAsFixed(0)}\n';

        // WhatsApp URI
        final Uri whatsappUri = Uri.parse(
            "https://wa.me/6282387696487?text=${Uri.encodeComponent(message)}");

        if (await canLaunch(whatsappUri.toString())) {
          await launch(whatsappUri.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to retrieve data.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch tindakan data.')),
      );
    }
  }

  // Helper function to format date in '16 Agustus 2024' format
  String _formatDate(DateTime dateTime) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year.toString();
    return '$day $month $year';
  }

  // Helper function to format time in '03:10' format
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatments Page'),
        centerTitle: true,
        automaticallyImplyLeading: false,

      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: PasienListPage(
              patients: _patients,
              onPatientSelected: (patient) {
                setState(() {
                  _selectedPatient = patient;
                  _fetchTindakanData();
                });
              },
              selectedPatient: _selectedPatient,
              onRefresh: _fetchPatients, // Tambahkan fungsi refresh di sini
            ),
          ),
          Expanded(
            flex: 5,
            child: AddTreatmentPage(
              selectedPatient: _selectedPatient,
              selectedTindakan: _selectedTindakan,
              selectedProcedure: _selectedProcedure,
              procedureExplanationController: _procedureExplanationController,
              onProcedureChanged: (Map<String, dynamic>? procedure) {
                setState(() {
                  _selectedProcedure =
                      procedure; // Store the selected procedure
                });
              },
              onAddProcedure: _addProcedure,
            ),
          ),
          Expanded(
            flex: 3,
            child: InvoicePage(
              selectedPatient: _selectedPatient,
              selectedTindakan: _selectedTindakan,
              onSendInvoice: _sendInvoice,
              formatCurrency: formatCurrency,
            ),
          ),
        ],
      ),
    );
  }
}

String formatCurrency(double amount) {
  return 'Rp ${amount.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(?<=\d)(?=(\d\d\d)+(?!\d))'), '.')}';
}
