// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../HomePage.dart';
import 'SalesTable.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late Future<Map<String, ProcedureStat>> procedureStatsFuture;
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String selectedYear = DateFormat('yyyy').format(DateTime.now());
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    procedureStatsFuture = fetchProcedureStats(selectedMonth, selectedYear);
  }

  Future<Map<String, ProcedureStat>> fetchProcedureStats(
      String month, String year) async {
    final response = await http.get(Uri.parse('$FULLURL.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data == null || data.isEmpty) {
        throw Exception('Data is empty');
      }

      final pricelist = data['pricelist'] ?? {};
      final tindakan = data['tindakan'] ?? {};
      final Map<String, ProcedureStat> procedureStats = {};

      // Inisialisasi harga tindakan
      pricelist.forEach((key, value) {
        if (value != null && value['name'] != null && value['price'] != null) {
          procedureStats[value['name']] = ProcedureStat(
            procedureName: value['name'],
            price: value['price'].toDouble(),
            count: 0,
          );
        }
      });

      double calculatedRevenue = 0;

      // Filter tindakan berdasarkan bulan dan tahun, hitung jumlah dan pendapatan
      tindakan.forEach((tindakanKey, tindakanValue) {
        if (tindakanValue != null && tindakanValue['timestamp'] != null) {
          final timestamp = tindakanValue['timestamp'];
          final DateTime procedureDate = DateTime.parse(timestamp);
          final String procedureMonth =
              DateFormat('MMMM').format(procedureDate);
          final String procedureYear = DateFormat('yyyy').format(procedureDate);

          if (procedureMonth == month && procedureYear == year) {
            final procedures = tindakanValue['procedure'] ?? {};
            procedures.forEach((procedureKey, procedureValue) {
              final procedureName = procedureValue['procedure'];
              final procedurePrice = procedureValue['price'];

              if (procedureName != null &&
                  procedureStats.containsKey(procedureName)) {
                procedureStats[procedureName]!.count++;
                calculatedRevenue += procedurePrice?.toDouble() ?? 0;
              }
            });
          }
        }
      });

      setState(() {
        totalRevenue = calculatedRevenue;
      });

      return procedureStats;
    } else {
      throw Exception('Failed to load procedure data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Page'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: selectedMonth,
                  items: [
                    'January',
                    'February',
                    'March',
                    'April',
                    'May',
                    'June',
                    'July',
                    'August',
                    'September',
                    'October',
                    'November',
                    'December'
                  ]
                      .map((month) => DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                      procedureStatsFuture =
                          fetchProcedureStats(selectedMonth, selectedYear);
                    });
                  },
                ),
                DropdownButton<String>(
                  value: selectedYear,
                  items: List.generate(10, (index) {
                    int year = DateTime.now().year - index;
                    return DropdownMenuItem(
                      value: year.toString(),
                      child: Text(year.toString()),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                      procedureStatsFuture =
                          fetchProcedureStats(selectedMonth, selectedYear);
                    });
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SalesTablePage()));
              },
              child: const Text('Tabel')),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Revenue for $selectedMonth $selectedYear: Rp ${totalRevenue.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, ProcedureStat>>(
              future: procedureStatsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No procedure data available'));
                } else {
                  final procedureStats = snapshot.data!.values.toList();

                  // Urutkan berdasarkan frekuensi
                  procedureStats.sort((a, b) => b.count.compareTo(a.count));

                  return ListView.builder(
                    itemCount: procedureStats.length,
                    itemBuilder: (context, index) {
                      final procedureStat = procedureStats[index];
                      double revenue =
                          procedureStat.count * procedureStat.price;
                      return ListTile(
                        title: Text(procedureStat.procedureName),
                        subtitle: Text(
                            'Rp ${procedureStat.price.toStringAsFixed(0)} per procedure'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${procedureStat.count} times'),
                            Text('Revenue: Rp ${revenue.toStringAsFixed(0)}'),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProcedureStat {
  final String procedureName;
  final double price;
  int count;

  ProcedureStat({
    required this.procedureName,
    required this.price,
    this.count = 0,
  });
}
