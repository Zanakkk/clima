// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
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
  String? _selectedProcedure;
  final TextEditingController _procedureExplanationController =
      TextEditingController();

  List<Map<String, dynamic>> _pricelist = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _fetchPricelist();
  }

  // Fetch Pricelist dari API
  Future<void> _fetchPricelist() async {
    final url = Uri.parse(
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/zanakdental5651/pricelist.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic>? data = json.decode(response.body);
      if (data != null) {
        setState(() {
          _pricelist = data
              .map<Map<String, dynamic>>((item) => {
                    'name': item['name'],
                    'price': item['price'],
                  })
              .toList();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch pricelist.')),
      );
    }
  }

  // Mendapatkan harga berdasarkan nama prosedur
  int _getProcedurePrice(String procedure) {
    final item = _pricelist.firstWhere(
      (item) => item['name'] == procedure,
      orElse: () => {'price': 0},
    );
    return item['price'];
  }

  Future<void> _addProcedure() async {
    if (_selectedPatient == null ||
        _selectedProcedure == null ||
        _selectedTindakan == null) return;

    final int price = _getProcedurePrice(_selectedProcedure!);
    final String explanation = _procedureExplanationController.text.trim();

    // Buat body untuk POST
    final newProcedure = {
      'procedure': _selectedProcedure,
      'price': price,
      'explanation': explanation.isNotEmpty ? explanation : null,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final url = Uri.parse(
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/zanakdental5651/tindakan/${_selectedTindakan!['id']}/procedure.json');

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

  Future<void> _fetchTindakanData() async {
    if (_selectedPatient == null) return;

    final url = Uri.parse(
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/zanakdental5651/tindakan.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        // Inisialisasi tindakanId dengan null
        String? tindakanId;

        // Iterasi melalui tindakan untuk menemukan yang sesuai dengan idpasien
        data.forEach((key, value) {
          if (value['idpasien'] == _selectedPatient!['id']) {
            tindakanId = key;
            _selectedTindakan = value;
          }
        });

        // Perbarui state dengan tindakanId yang ditemukan
        setState(() {
          if (tindakanId != null) {
            _selectedTindakan!['id'] =
                tindakanId; // Simpan tindakanId ke _selectedTindakan
          } else {
            _selectedTindakan = null; // Jika tidak ada tindakan ditemukan
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch tindakan data.')),
      );
    }
  }

  Future<void> _sendInvoice() async {
    if (_selectedPatient == null) return;

    final String tindakanId = _selectedTindakan!['id']; // ID tindakan khusus
    final String url =
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/zanakdental5651/tindakan/$tindakanId/procedure.json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        // Mulai membuat pesan invoice
        String message = '🧾 *Invoice* 🧾\n\n';

        // Informasi Pasien
        message += '👤 *Nama Pasien:* ${_selectedPatient!['fullName']}\n';
        message += '📅 *Tanggal:* ${DateTime.now().toIso8601String()}\n\n';

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

        // Total Biaya
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

  Future<void> _fetchPatients() async {
    final url = Uri.parse(
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/zanakdental5651/datapasien.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data != null) {
        final patients = data.entries
            .map<Map<String, dynamic>>(
                (entry) => {'id': entry.key, ...entry.value})
            .toList();

        setState(() {
          _patients = patients;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch patients.')),
      );
    }
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(?<=\d)(?=(\d\d\d)+(?!\d))'), '.')}';
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
            ),
          ),
          Expanded(
            flex: 5,
            child: AddTreatmentPage(
              selectedPatient: _selectedPatient,
              selectedTindakan: _selectedTindakan,
              selectedProcedure: _selectedProcedure,
              procedureExplanationController: _procedureExplanationController,
              onProcedureChanged: (value) {
                setState(() {
                  _selectedProcedure = value;
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
