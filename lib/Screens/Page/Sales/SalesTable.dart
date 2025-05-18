// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, avoid_print, avoid_types_as_parameter_names, unused_local_variable

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SalesTablePage extends StatefulWidget {
  const SalesTablePage({super.key});

  @override
  _SalesTablePageState createState() => _SalesTablePageState();
}

class _SalesTablePageState extends State<SalesTablePage> {
  // Data and filtering variables
  List<Map<String, dynamic>> tableData = [];
  String jsonString = "";
  String? selectedMonth;
  String? selectedYear;
  DateTime? selectedDate;
  String? clinicId;
  bool isLoading = true;
  String? errorMessage;

  // UI Colors
  final Color primaryColor = const Color(0xFF1976D2); // Primary blue
  final Color accentColor = const Color(0xFF64B5F6); // Light blue
  final Color backgroundColor =
      const Color(0xFFF5F7FA); // Light gray background
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF333333);
  final Color lightTextColor = const Color(0xFF757575);

  // Constants for months
  final List<String> months = [
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

  final List<String> shortMonths = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des"
  ];

  // Map to store sales per month
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

  // Add this to your _SalesTablePageState class variables
  String? selectedDoctor;
  List<String> doctorList = [];

  @override
  void initState() {
    super.initState();
    _getClinicId().then((_) {
      fetchData();
    });
  }

  Future<void> _getClinicId() async {
    try {
      // Get current user's email
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email != null) {
        // Query the clinics collection to find the clinic with matching email
        final QuerySnapshot clinicSnapshot = await FirebaseFirestore.instance
            .collection('clinics')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (clinicSnapshot.docs.isNotEmpty) {
          setState(() {
            clinicId = clinicSnapshot.docs.first.id;
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error getting clinic ID: $e';
      });
      print('Error getting clinic ID: $e');
    }
  }

  // Modify fetchData() to include doctor filtering and fix revenue calculation
  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (clinicId == null) {
        throw Exception('Clinic ID not found');
      }

      // First, get all tindakan documents
      final QuerySnapshot tindakanSnapshot = await FirebaseFirestore.instance
          .collection('tindakan')
          .where('doctorId',
              isNotEqualTo: '') // Just to ensure we get all documents
          .get();

      List<Map<String, dynamic>> data = [];
      Set<String> uniqueDoctors = {}; // To collect unique doctor names

      // Reset sales per month
      for (var month in months) {
        salesPerMonth[month] = 0;
      }

      // Process all tindakan documents
      for (var tindakanDoc in tindakanSnapshot.docs) {
        final tindakanData = tindakanDoc.data() as Map<String, dynamic>;

        if (tindakanData['timestamp'] != null) {
          String namaPasien = tindakanData['namapasien'] ?? 'No Name';
          String doctor = tindakanData['doctor'] ?? 'No Doctor';

          // Add to unique doctors list
          if (doctor != 'No Doctor') {
            uniqueDoctors.add(doctor);
          }

          // Handle both Timestamp and String timestamp formats
          DateTime procedureDate;
          if (tindakanData['timestamp'] is Timestamp) {
            procedureDate = (tindakanData['timestamp'] as Timestamp).toDate();
          } else {
            procedureDate =
                DateTime.parse(tindakanData['timestamp'].toString());
          }

          // Get procedures and calculate total
          int totalBayar = 0;
          try {
            final proceduresSnapshot =
                await tindakanDoc.reference.collection('procedure').get();

            for (var procedureDoc in proceduresSnapshot.docs) {
              final procedureData = procedureDoc.data();
              final procedurePrice = procedureData['price'] as num?;
              if (procedurePrice != null) {
                // Make sure price is not null
                totalBayar += procedurePrice.toInt();
              }
            }
          } catch (e) {
            print('Error fetching procedures: $e');
          }

          // Create entry for this tindakan
          Map<String, dynamic> entry = {
            'Nama Pasien': namaPasien,
            'Dokter': doctor,
            'Total Bayar': totalBayar,
            'Tanggal': formatTanggal(procedureDate),
            'Waktu': formatWaktu(procedureDate),
            'Date': procedureDate, // Keep the actual date for filtering
          };

          // Apply filters before adding to tableData
          if (_applyFilters(procedureDate, doctor)) {
            data.add(entry);

            // Update monthly sales data
            String month = months[procedureDate.month - 1];
            salesPerMonth[month] =
                (salesPerMonth[month] ?? 0) + totalBayar.toDouble();
          }
        }
      }

      setState(() {
        tableData = data;
        doctorList = uniqueDoctors.toList()..sort(); // Sort alphabetically
        jsonString = jsonEncode({"data": data});
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

// Update the _applyFilters method to include doctor filtering
  bool _applyFilters(DateTime date, String doctor) {
    // If a specific doctor is selected, only show data from that doctor
    if (selectedDoctor != null && doctor != selectedDoctor) {
      return false;
    }

    // If a specific date is selected, only show data from that date
    if (selectedDate != null) {
      return date.year == selectedDate!.year &&
          date.month == selectedDate!.month &&
          date.day == selectedDate!.day;
    }

    // If month is selected, filter by month
    if (selectedMonth != null) {
      int monthIndex = months.indexOf(selectedMonth!) + 1;
      if (date.month != monthIndex) {
        return false;
      }
    }

    // If year is selected, filter by year
    if (selectedYear != null) {
      if (date.year != int.parse(selectedYear!)) {
        return false;
      }
    }

    // If we got here, the data passes all filters
    return true;
  }

  String formatTanggal(DateTime dateTime) {
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

  String formatCurrency(int amount) {
    final formatter = NumberFormat("#,###", "id_ID");
    return "Rp ${formatter.format(amount)}";
  }

  String generateFileName() {
    DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    String year = now.year.toString();

    String filterInfo = "";
    if (selectedMonth != null) filterInfo += "_$selectedMonth";
    if (selectedYear != null) filterInfo += "_$selectedYear";
    if (selectedDate != null) {
      String formattedDate = DateFormat('dd_MM_yyyy').format(selectedDate!);
      filterInfo += "_$formattedDate";
    }

    return 'sales_report${filterInfo}_${day}_${month}_$year.xlsx';
  }

  Future<void> jsonToExcel() async {
    try {
      // Create Excel workbook
      var excel = Excel.createExcel();
      var sheet = excel['Sales Report'];

      // Add title row with filter information
      List<String> titleCells = ["Sales Report"];
      if (selectedMonth != null) titleCells.add("Month: $selectedMonth");
      if (selectedYear != null) titleCells.add("Year: $selectedYear");
      if (selectedDate != null) {
        titleCells.add("Date: ${formatTanggal(selectedDate!)}");
      }
      sheet.appendRow(titleCells.map((text) => TextCellValue(text)).toList());

      // Add empty row
      sheet.appendRow([TextCellValue("")]);

      if (tableData.isNotEmpty) {
        // Add header row
        sheet.appendRow(tableData.first.keys
            .where((key) =>
                key != 'Date') // Exclude the Date field used for filtering
            .map((key) => TextCellValue(key))
            .toList());

        // Add data rows
        for (var row in tableData) {
          sheet.appendRow(row.entries
              .where((entry) => entry.key != 'Date') // Exclude the Date field
              .map((entry) {
            final value = entry.value;
            if (value is int) {
              // Format currency values
              if (entry.key == 'Total Bayar') {
                return TextCellValue(formatCurrency(value));
              }
              return IntCellValue(value);
            } else if (value is double) {
              return DoubleCellValue(value);
            } else {
              return TextCellValue(value.toString());
            }
          }).toList());
        }

        // Add summary section
        sheet.appendRow([TextCellValue("")]);
        sheet.appendRow([TextCellValue("Summary")]);

        // Calculate and add total revenue
        int totalRevenue = tableData.fold(
            0, (sum, item) => sum + (item['Total Bayar'] as int));
        sheet.appendRow([
          TextCellValue("Total Revenue:"),
          TextCellValue(formatCurrency(totalRevenue))
        ]);

        // Add average revenue per transaction
        double avgRevenue =
            tableData.isNotEmpty ? totalRevenue / tableData.length : 0;
        sheet.appendRow([
          TextCellValue("Average Revenue per Transaction:"),
          TextCellValue(formatCurrency(avgRevenue.round()))
        ]);

        // Add transaction count
        sheet.appendRow([
          TextCellValue("Total Transactions:"),
          IntCellValue(tableData.length)
        ]);
      }

      // Save Excel file
      final bytes = excel.save(fileName: generateFileName());
      if (bytes != null) {
        final blob = html.Blob([
          bytes
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Create download link
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", generateFileName())
          ..click();

        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel file downloaded successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error creating Excel file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating Excel file: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Sales Report',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchData,
              tooltip: 'Refresh data',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter section
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Options',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Month dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text('Select Month',
                                    style: TextStyle(color: lightTextColor)),
                                value: selectedMonth,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: primaryColor),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedMonth = newValue;
                                    fetchData(); // Refresh data with new filter
                                  });
                                },
                                items: _buildMonthDropdownItems(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Year dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text('Select Year',
                                    style: TextStyle(color: lightTextColor)),
                                value: selectedYear,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: primaryColor),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedYear = newValue;
                                    fetchData(); // Refresh data with new filter
                                  });
                                },
                                items: _buildYearDropdownItems(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Date picker
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              selectedDate == null
                                  ? 'Select Date'
                                  : formatTanggal(selectedDate!),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: () => _selectDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Add doctor dropdown to the filter section in build method
// Add this alongside the other dropdown widgets in the filter section
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text('Select Doctor',
                                    style: TextStyle(color: lightTextColor)),
                                value: selectedDoctor,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: primaryColor),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedDoctor = newValue;
                                    fetchData(); // Refresh data with new filter
                                  });
                                },
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All Doctors'),
                                  ),
                                  ...doctorList.map((doctor) {
                                    return DropdownMenuItem<String>(
                                      value: doctor,
                                      child: Text(doctor),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Filter clearing and export buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Clear Filters'),
                          onPressed: () {
                            setState(() {
                              selectedMonth = null;
                              selectedYear = null;
                              selectedDate = null;
                              fetchData(); // Refresh with cleared filters
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: lightTextColor,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Export to Excel'),
                          onPressed: tableData.isNotEmpty ? jsonToExcel : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Sales chart
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Sales Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildSalesChart(),
                    ),
                  ],
                ),
              ),

              // Summary card
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: isLoading
                    ? const Center(
                        child: SpinKitCircle(
                          color: Colors.white,
                          size: 30.0,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryCard(
                            'Total Revenue',
                            formatCurrency(tableData.fold(
                                0,
                                (sum, item) =>
                                    sum + (item['Total Bayar'] as int))),
                            Icons.monetization_on,
                          ),
                          _buildSummaryCard(
                            'Transactions',
                            tableData.length.toString(),
                            Icons.receipt_long,
                          ),
                          _buildSummaryCard(
                            'Avg. Revenue',
                            tableData.isEmpty
                                ? 'Rp 0'
                                : formatCurrency((tableData.fold(
                                            0,
                                            (sum, item) =>
                                                sum +
                                                (item['Total Bayar'] as int)) /
                                        tableData.length)
                                    .round()),
                            Icons.trending_up,
                          ),
                        ],
                      ),
              ),

              // Table section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Transactions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildDataTable(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    // Find the maximum value for better scaling
    double maxValue = 0;
    for (var value in salesPerMonth.values) {
      if (value > maxValue) maxValue = value;
    }

    // Scale up a bit for better visibility
    maxValue = maxValue > 0 ? (maxValue * 1.2) : 1000;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxValue / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Format as currency
                if (value == 0) return const Text('');

                String label;
                if (value >= 1000000) {
                  label = '${(value / 1000000).toStringAsFixed(1)}M';
                } else if (value >= 1000) {
                  label = '${(value / 1000).toStringAsFixed(0)}K';
                } else {
                  label = value.toStringAsFixed(0);
                }

                return Text(
                  label,
                  style: TextStyle(
                    color: lightTextColor,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < shortMonths.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      shortMonths[index],
                      style: TextStyle(
                        color: lightTextColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
        ),
        minY: 0,
        maxY: maxValue,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(12, (index) {
              final month = months[index];
              final sales = salesPerMonth[month] ?? 0;
              return FlSpot(index.toDouble(), sales);
            }),
            isCurved: true,
            barWidth: 3,
            color: primaryColor,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (isLoading) {
      return Center(
        child: SpinKitCircle(
          color: primaryColor,
          size: 50.0,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[300],
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: lightTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (tableData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              color: Colors.grey[400],
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'No transaction data available',
              style: TextStyle(
                color: lightTextColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filters or check back later',
              style: TextStyle(
                color: lightTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          Colors.grey.shade100,
        ),
        dataRowMaxHeight: 64,
        columnSpacing: 20,
        columns: <DataColumn>[
          DataColumn(
            label: Text(
              'Nama Pasien',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          DataColumn(
            label: Text(
              'Dokter',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          DataColumn(
            label: Text(
              'Total Bayar',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            numeric: true,
          ),
          DataColumn(
            label: Text(
              'Tanggal',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          DataColumn(
            label: Text(
              'Waktu',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ],
        rows: tableData.map((row) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  row['Nama Pasien'] ?? '',
                  style: TextStyle(color: textColor),
                ),
              ),
              DataCell(
                Text(
                  row['Dokter'] ?? '',
                  style: TextStyle(color: textColor),
                ),
              ),
              DataCell(
                Text(
                  formatCurrency(row['Total Bayar'] as int),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              DataCell(
                Text(
                  row['Tanggal'] ?? '',
                  style: TextStyle(color: textColor),
                ),
              ),
              DataCell(
                Text(
                  row['Waktu'] ?? '',
                  style: TextStyle(color: lightTextColor),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildMonthDropdownItems() {
    return months.map((month) {
      return DropdownMenuItem<String>(
        value: month,
        child: Text(month),
      );
    }).toList();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedMonth =
            null; // Clear month filter when specific date is selected
        selectedYear = null; // Clear year filter when specific date is selected
        fetchData(); // Refresh data with new date filter
      });
    }
  }
}
