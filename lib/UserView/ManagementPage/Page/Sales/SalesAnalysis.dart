// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'FetchData.dart';
import 'Model.dart';

class SalesAnalysisPage extends StatefulWidget {
  const SalesAnalysisPage({super.key});

  @override
  _SalesAnalysisPageState createState() => _SalesAnalysisPageState();
}

class _SalesAnalysisPageState extends State<SalesAnalysisPage> {
  late Future<Map<String, Treatment>> treatmentsFuture;

  int scalingCount = 0;
  int tambalCount = 0;
  int cabutCount = 0;

  int scalingRevenue = 0;
  int tambalRevenue = 0;
  int cabutRevenue = 0;

  @override
  void initState() {
    super.initState();
    treatmentsFuture = fetchTreatments();
  }

  void analyzeSalesData(Map<String, Treatment> treatments) {
    for (var treatment in treatments.values) {
      for (var procedure in treatment.procedures) {
        switch (procedure.procedure) {
          case 'Scaling':
            scalingCount++;
            scalingRevenue += procedure.price;
            break;
          case 'Tambal':
            tambalCount++;
            tambalRevenue += procedure.price;
            break;
          case 'Cabut':
            cabutCount++;
            cabutRevenue += procedure.price;
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analysis'),
      ),
      body: FutureBuilder<Map<String, Treatment>>(
        future: treatmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            analyzeSalesData(snapshot.data!);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales Summary',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16.0),
                  _buildProcedureSummary(
                      'Scaling', scalingCount, scalingRevenue),
                  _buildProcedureSummary('Tambal', tambalCount, tambalRevenue),
                  _buildProcedureSummary('Cabut', cabutCount, cabutRevenue),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  Text(
                    'Total Revenue: Rp ${scalingRevenue + tambalRevenue + cabutRevenue}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildProcedureSummary(String procedure, int count, int revenue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$procedure: $count pasien',
            style: const TextStyle(fontSize: 16.0)),
        Text('Rp $revenue',
            style:
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
