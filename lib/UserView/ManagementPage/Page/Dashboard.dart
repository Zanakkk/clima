// ignore_for_file: library_private_types_in_public_api, empty_catches

import 'package:flutter/material.dart';
import '../CLIMACONTROL/PricingTableApp.dart';
import '../HomePage.dart';
import 'Dashboard/ClimaLandingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Map<String, dynamic> clinicData = {};

  @override
  void initState() {
    super.initState();
    _fetchClinicData();
    fetchData();
  }

  Map<String, dynamic> data = {};
  String jsonString = ""; // Untuk menyimpan JSON yang dihasilkan

  String? selectedMonth;
  String? selectedYear;
  DateTime? selectedDate;
  String formatTanggal(DateTime dateTime) {
    List<String> months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = months[dateTime.month - 1];
    String year = dateTime.year.toString();

    return "$day $month $year";
  }

  String formatWaktu(DateTime dateTime) {
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');

    return "$hour:$minute:$second";
  }

  bool _applyFilters(DateTime dateTime) {
    if (selectedMonth != null) {
      final month = formatTanggal(dateTime).split(
          " ")[1]; // Cocokkan format ini dengan format di `formatTanggal`
      if (month != selectedMonth) {
        return false;
      }
    }
    if (selectedYear != null) {
      final year = dateTime.year.toString();
      if (year != selectedYear) {
        return false;
      }
    }
    if (selectedDate != null) {
      if (formatTanggal(dateTime) != formatTanggal(selectedDate!)) {
        return false;
      }
    }
    return true;
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$FULLURL/tindakan.json'));

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
        jsonString = jsonEncode(_generateJsonFromTable());
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Map<String, dynamic> _generateJsonFromTable() {
    List<Map<String, dynamic>> tableData = [];
    salesPerMonth.clear(); // Reset data penjualan per bulan

    // Proses data dan hitung total penjualan per bulan
    data.forEach((key, value) {
      String namaPasien = value['namapasien'];
      String doctor = value['doctor'];
      String timestamp = value['timestamp'];

      int totalBayar = 0;

      if (value['procedure'] != null) {
        value['procedure'].forEach((procedureKey, procedureValue) {
          totalBayar += (procedureValue['price'] as num).toInt();
        });
      }

      DateTime dateTime = DateTime.parse(timestamp);

      // Terapkan filter pada setiap entri
      if (_applyFilters(dateTime)) {
        tableData.add({
          'Nama Pasien': namaPasien,
          'Dokter': doctor,
          'Total Bayar': totalBayar,
          'Tanggal': formatTanggal(dateTime),
          'Waktu': formatWaktu(dateTime),
        });

        // Gunakan indeks bulan untuk mendapatkan nama bulan
        String month =
            months[dateTime.month - 1]; // Ambil nama bulan dari array months

        // Tambahkan ke total penjualan per bulan
        if (salesPerMonth.containsKey(month)) {
          salesPerMonth[month] = salesPerMonth[month]! + totalBayar;
        } else {
          salesPerMonth[month] =
              totalBayar.toDouble(); // Jika belum ada, inisialisasi
        }
      }
    });

    return {
      'data': tableData,
    };
  }

  Future<void> _fetchClinicData() async {
    final url = Uri.parse('$FULLURL.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          clinicData = json.decode(response.body) as Map<String, dynamic>;
        });
      } else {}
    } catch (error) {}
  }

  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  Map<String, double> salesPerMonth = {
    "Januari": 0,
    "Februari": 0,
    "Maret": 0,
    "April": 0,
    "Mei": 0,
    "Juni": 0,
    "Juli": 0,
    "Agustus": 0,
    "September": 0,
    "Oktober": 0,
    "November": 0,
    "Desember": 0,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 4, // Number of columns
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          DashboardBox(
            title: "Clinic Name",
            value: clinicData.isNotEmpty && clinicData['name'] != null
                ? clinicData['name']
                : 'N/A',
            color: Colors.blue,
          ),
          if (clinicData.isNotEmpty && clinicData['logo'] != null)
            Image.network(
              clinicData['logo'],
              height: 100,
              fit: BoxFit.cover,
            ),
          DashboardBox(
            title: "Address",
            value: clinicData.isNotEmpty && clinicData['address'] != null
                ? clinicData['address']
                : 'Unknown',
            color: Colors.green,
          ),
          DashboardBox(
            title: "Total Patients",
            value: clinicData.isNotEmpty && clinicData['datapasien'] != null
                ? clinicData['datapasien'].length.toString()
                : '0',
            color: Colors.blue,
          ),
          DashboardBox(
            title: "Doctors",
            value: clinicData.isNotEmpty && clinicData['dokter'] != null
                ? clinicData['dokter'].length.toString()
                : '0',
            color: Colors.orange,
          ),
          DashboardBox(
            title: "Total Procedures",
            value: clinicData.isNotEmpty && clinicData['tindakan'] != null
                ? clinicData['tindakan'].length.toString()
                : '0',
            color: Colors.teal,
          ),
          _buildSalesChart(),
          const DashboardBox(
            title: "Plan CLIMA",
            value: "Basic", // Placeholder since the plan info is not available
            color: Colors.grey,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PricingTableApp()));
              },
              child: const Text('pricing')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ClimaLandingPage()));
              },
              child: const Text('Landing Page')),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return SizedBox(
      height: 300,
      width: MediaQuery.of(context).size.width / 3,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final int index = value.toInt();
                  if (index >= 0 && index < months.length) {
                    return Text(months[index]);
                  } else {
                    return const Text('');
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(12, (index) {
                final month = months[index];
                final sales = salesPerMonth[month] ?? 0;
                return FlSpot(index.toDouble(), sales);
              }),
              isCurved: true,
              barWidth: 4,
              color: Colors.deepPurpleAccent, // Warna ungu pada garis grafik
              dotData: const FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.deepPurpleAccent
                    .withOpacity(0.2), // Area di bawah garis dengan warna ungu
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const DashboardBox({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
