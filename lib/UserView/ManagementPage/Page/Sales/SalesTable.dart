import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../Component/FormatUmum.dart';

void main() {
  runApp(MaterialApp(
    home: SalesTablePage(),
  ));
}

class SalesTablePage extends StatefulWidget {
  @override
  _SalesTablePageState createState() => _SalesTablePageState();
}

class _SalesTablePageState extends State<SalesTablePage> {
  Map<String, dynamic> data = {};
  String? selectedMonth;
  String? selectedYear;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/tindakan.json'));

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Table with Filters'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Select Month'),
                    value: selectedMonth,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMonth = newValue;
                      });
                    },
                    items: _buildMonthDropdownItems(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Select Year'),
                    value: selectedYear,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue;
                      });
                    },
                    items: _buildYearDropdownItems(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(selectedDate == null
                        ? 'Select Date'
                        : formatTanggalManual(selectedDate!)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: data.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Nama Pasien')),
                        DataColumn(label: Text('Dokter')),
                        DataColumn(label: Text('Total Bayar')),
                        DataColumn(label: Text('Tanggal')),
                      ],
                      rows: _buildFilteredRows(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildMonthDropdownItems() {
    final months = [
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
    return List.generate(12, (index) {
      final month = months[index];
      return DropdownMenuItem<String>(
        value: month,
        child: Text(month),
      );
    });
  }

  List<DropdownMenuItem<String>> _buildYearDropdownItems() {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) {
      final year = (currentYear - index).toString();
      return DropdownMenuItem<String>(
        value: year,
        child: Text(year),
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<DataRow> _buildFilteredRows() {
    List<DataRow> rows = [];

    data.forEach((key, value) {
      String namaPasien = value['namapasien'];
      String doctor = value['doctor'];
      String timestamp = value['timestamp'];

      int totalBayar = 0;
      for (var procedure in value['procedures']) {
        totalBayar += (procedure['price'] as num).toInt();
      }

      // Convert timestamp to Date
      DateTime dateTime = DateTime.parse(timestamp);
      String formattedDate = formatTanggalManual(dateTime);

      // Format totalBayar to currency
      String formattedTotalBayar = formatRupiahManual(totalBayar);

      // Apply filters
      if (_applyFilters(dateTime)) {
        rows.add(DataRow(cells: [
          DataCell(Text(namaPasien)),
          DataCell(Text(doctor)),
          DataCell(Text(formattedTotalBayar)),
          DataCell(Text(formattedDate)),
        ]));
      }
    });

    return rows;
  }

  bool _applyFilters(DateTime dateTime) {
    if (selectedMonth != null) {
      final month = formatTanggalManual(dateTime).split(" ")[1];
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
      if (formatTanggalManual(dateTime) != formatTanggalManual(selectedDate!)) {
        return false;
      }
    }
    return true;
  }
}
