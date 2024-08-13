// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../Component/FormatUmum.dart';
import '../../HomePage.dart';

class SalesTablePage extends StatefulWidget {
  const SalesTablePage({super.key});

  @override
  _SalesTablePageState createState() => _SalesTablePageState();
}

class _SalesTablePageState extends State<SalesTablePage> {
  Map<String, dynamic> data = {};
  String jsonString = ""; // Untuk menyimpan JSON yang dihasilkan

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
        '$FULLURL/tindakan.json'));

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

    data.forEach((key, value) {
      String namaPasien = value['namapasien'];
      String doctor = value['doctor'];
      String timestamp = value['timestamp'];

      int totalBayar = 0;
      for (var procedure in value['procedures']) {
        totalBayar += (procedure['price'] as num).toInt();
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
      }
    });

    return {
      'data': tableData,
    };
  }

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

  String generateFileName() {
    DateTime now = DateTime
        .now(); // Bisa diganti dengan selectedDate jika ingin berdasarkan tanggal yang dipilih
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    String year = now.year.toString();
    return 'report_${day}_${month}_$year.xlsx';
  }

  Future<void> jsonToExcel() async {
    // Generate filtered JSON data
    Map<String, dynamic> filteredData = _generateJsonFromTable();

    // Buat Excel workbook
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    if (filteredData.isNotEmpty) {
      List<Map<String, dynamic>> tableData =
          List<Map<String, dynamic>>.from(filteredData['data']);

      if (tableData.isNotEmpty) {
        sheet.appendRow(
            tableData.first.keys.map((key) => TextCellValue(key)).toList());

        for (var row in tableData) {
          sheet.appendRow(row.values.map((value) {
            if (value is int) {
              return IntCellValue(value);
            } else if (value is double) {
              return DoubleCellValue(value);
            } else {
              return TextCellValue(value.toString());
            }
          }).toList());
        }
      }
    }

    // Simpan file Excel
    final bytes = excel.save(fileName: generateFileName());
    if (bytes != null) {
      final blob = html.Blob([bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.Url.revokeObjectUrl(url);
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Table with Filters'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Select Month'),
                    value: selectedMonth,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMonth = newValue;
                        // Update JSON after filter change
                        jsonString = jsonEncode(_generateJsonFromTable());
                      });
                    },
                    items: _buildMonthDropdownItems(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Select Year'),
                    value: selectedYear,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue;
                        // Update JSON after filter change
                        jsonString = jsonEncode(_generateJsonFromTable());
                      });
                    },
                    items: _buildYearDropdownItems(),
                  ),
                ),
                const SizedBox(width: 16),
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
                  ? const Center(child: CircularProgressIndicator())
                  : DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Nama Pasien')),
                        DataColumn(label: Text('Dokter')),
                        DataColumn(
                          label: Text('Total Bayar'),
                          numeric: true, // Align right by default for numbers
                        ),
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Waktu')),
                      ],
                      rows: _buildFilteredRows(),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => jsonToExcel(),
              child: const Text('Download File'),
            ),
          ),
        ],
      ),
    );
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

      DateTime dateTime = DateTime.parse(timestamp);
      String formattedDate = formatTanggal(dateTime);
      String formattedTime = formatWaktu(dateTime);
      String formattedTotalBayar = formatRupiahManual(totalBayar).toString();

      // Terapkan filter pada setiap baris
      if (_applyFilters(dateTime)) {
        rows.add(DataRow(cells: [
          DataCell(Text(
            namaPasien,
            textAlign: TextAlign.center,
          )),
          DataCell(Text(
            doctor,
            textAlign: TextAlign.center,
          )),
          DataCell(
            Align(
              alignment: Alignment.centerRight, // Align to the right
              child: Text(formattedTotalBayar),
            ),
          ),
          DataCell(Text(
            formattedDate,
            textAlign: TextAlign.center,
          )),
          DataCell(Text(
            formattedTime,
            textAlign: TextAlign.center,
          )),
        ]));
      }
    });

    return rows;
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
        // Update JSON after date selection
        jsonString = jsonEncode(_generateJsonFromTable());
      });
    }
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
}
