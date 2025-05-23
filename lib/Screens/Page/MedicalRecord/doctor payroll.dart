// ignore: avoid_web_libraries_in_flutter
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter, library_private_types_in_public_api, empty_catches, avoid_types_as_parameter_names, duplicate_ignore, unused_local_variable

import 'dart:html' as html;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DoctorFinancialReport extends StatefulWidget {
  const DoctorFinancialReport({super.key});

  @override
  _DoctorFinancialReportState createState() => _DoctorFinancialReportState();
}

class _DoctorFinancialReportState extends State<DoctorFinancialReport> {
  // Data and filtering variables
  List<Map<String, dynamic>> tableData = [];
  Map<String, List<Map<String, dynamic>>> doctorData = {};
  String? selectedMonth;
  String? selectedYear;
  DateTime? selectedDate;
  String? selectedDoctor;
  String? clinicId;
  List<String> doctorList = [];
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

  // Map to store doctor revenues per month
  Map<String, Map<String, double>> doctorRevenuePerMonth = {};

  // Konfigurasi untuk sistem pembayaran dokter
  PaymentSystem currentPaymentSystem = PaymentSystem.percentageBased;
  double doctorSharePercentage = 0.7; // 70% untuk model persentase
  double materialCostPercentage =
      0.25; // 25% perkiraan biaya bahan (untuk model 2)
  double baseSalary =
      10000000; // Rp 10.000.000 gaji dasar bulanan (untuk model 3)
  double bonusPercentage = 0.1; // 10% bonus dari pendapatan (untuk model 3)

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
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (clinicId == null) {
        throw Exception('Clinic ID not found');
      }

      final QuerySnapshot tindakanSnapshot = await FirebaseFirestore.instance
          .collection('tindakan')
          .where('doctorId',
              isNotEqualTo: '') // Just to ensure we get all documents
          .get();


      List<Map<String, dynamic>> data = [];
      Map<String, List<Map<String, dynamic>>> doctorTransactions = {};
      Set<String> uniqueDoctors = {}; // To collect unique doctor names

      // Initialize doctor revenue per month structure
      doctorRevenuePerMonth = {};

      // Process all tindakan documents
      for (var tindakanDoc in tindakanSnapshot.docs) {
        final tindakanData = tindakanDoc.data() as Map<String, dynamic>;

        if (tindakanData['timestamp'] != null) {
          String namaPasien = tindakanData['namapasien'] ?? 'No Name';
          String doctor = tindakanData['doctor'] ?? 'No Doctor';

          // Add to unique doctors list
          if (doctor != 'No Doctor') {
            uniqueDoctors.add(doctor);

            // Initialize doctor data structures if needed
            if (!doctorTransactions.containsKey(doctor)) {
              doctorTransactions[doctor] = [];
            }

            if (!doctorRevenuePerMonth.containsKey(doctor)) {
              doctorRevenuePerMonth[doctor] = {};
              for (var month in months) {
                doctorRevenuePerMonth[doctor]![month] = 0;
              }
            }
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
          List<Map<String, dynamic>> procedureDetails = [];

          try {

            // PERUBAHAN: Mengubah nama koleksi dari 'procedure' menjadi 'procedures'
            final proceduresSnapshot = await tindakanDoc.reference
                .collection(
                    'procedures') // Ubah kembali ke 'procedure' karena berdasarkan informasi dari Firestore path
                .get();


            if (proceduresSnapshot.docs.isEmpty) {
              // This is critical to understand - log if no procedures found

              // TAMBAHAN: Coba ambil dengan nama koleksi yang berbeda untuk debugging
            }

            for (var procedureDoc in proceduresSnapshot.docs) {
              final procedureData = procedureDoc.data();
              final procedurePrice = procedureData['price'] != null
                  ? (procedureData['price'] is num
                      ? procedureData['price'] as num
                      : int.tryParse(procedureData['price'].toString()) ?? 0)
                  : 0;

              final procedureName = procedureData['procedure'] as String?;
              final explanation = procedureData['explanation'] as String?;

              // Add procedure details
              procedureDetails.add({
                'name': procedureName ?? 'Unknown Procedure',
                'price': procedurePrice,
                'explanation': explanation ?? '',
              });

              totalBayar += procedurePrice.toInt();
            }
          } catch (e) {
          }


          // Calculate doctor's share of the revenue
          // Hitung bagian dokter berdasarkan sistem yang dipilih
          double doctorShare = calculateDoctorShare(totalBayar);

          // Create entry for this tindakan
          Map<String, dynamic> entry = {
            'Nama Pasien': namaPasien,
            'Dokter': doctor,
            'Total Bayar': totalBayar,
            'Bagian Dokter': doctorShare.round(),
            'Tanggal': formatTanggal(procedureDate),
            'Waktu': formatWaktu(procedureDate),
            'Date': procedureDate,
            'Procedures':
                procedureDetails, // Add detailed procedure information
          };

          // Apply filters before adding to data
          if (_applyFilters(procedureDate, doctor)) {
            data.add(entry);

            // Add to doctor-specific transactions
            if (doctor != 'No Doctor') {
              doctorTransactions[doctor]!.add(entry);

              // Update doctor monthly revenue data
              String month = months[procedureDate.month - 1];
              doctorRevenuePerMonth[doctor]![month] =
                  (doctorRevenuePerMonth[doctor]![month] ?? 0) + doctorShare;
            }
          }
        }
      }

      setState(() {
        tableData = data;
        doctorData = doctorTransactions;
        doctorList = uniqueDoctors.toList()..sort();
        isLoading = false;

        // Debug print of final data
        if (doctorList.isNotEmpty) {
        } else {
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  double calculateDoctorShare(int totalRevenue) {
    switch (currentPaymentSystem) {
      case PaymentSystem.percentageBased:
        // Model 1: Persentase langsung dari pendapatan kotor
        return totalRevenue * doctorSharePercentage;

      case PaymentSystem.percentageAfterCost:
        // Model 2: Persentase setelah dikurangi biaya bahan
        double materialCost = totalRevenue * materialCostPercentage;
        double netRevenue = totalRevenue - materialCost;
        return netRevenue * doctorSharePercentage;

      case PaymentSystem.salaryPlusBonus:
        // Model 3: Bagian ini lebih kompleks karena berdasarkan perhitungan bulanan
        // Ini hanya estimasi bonus per transaksi
        return totalRevenue * bonusPercentage;
    }
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

    String doctorInfo = selectedDoctor != null
        ? "_${selectedDoctor!.replaceAll(' ', '_')}"
        : "";
    String filterInfo = "";
    if (selectedMonth != null) filterInfo += "_$selectedMonth";
    if (selectedYear != null) filterInfo += "_$selectedYear";
    if (selectedDate != null) {
      String formattedDate = DateFormat('dd_MM_yyyy').format(selectedDate!);
      filterInfo += "_$formattedDate";
    }

    return 'doctor_finance$doctorInfo$filterInfo${day}_${month}_$year.xlsx';
  }

  Future<void> exportDoctorReport() async {
    try {
      // Create Excel workbook
      var excel = Excel.createExcel();

      // If a specific doctor is selected, only export that doctor's data
      List<String> doctorsToExport =
          selectedDoctor != null ? [selectedDoctor!] : doctorList;

      for (String doctor in doctorsToExport) {
        var sheet = excel[doctor]; // Each doctor gets their own sheet

        // Add title and filter info
        List<String> titleCells = ["Doctor Finance Report: $doctor"];
        if (selectedMonth != null) titleCells.add("Month: $selectedMonth");
        if (selectedYear != null) titleCells.add("Year: $selectedYear");
        if (selectedDate != null) {
          titleCells.add("Date: ${formatTanggal(selectedDate!)}");
        }
        sheet.appendRow(titleCells.map((text) => TextCellValue(text)).toList());

        // Add empty row and doctor fee info
        sheet.appendRow([TextCellValue("")]);
        sheet.appendRow([
          TextCellValue("Doctor Share Percentage:"),
          TextCellValue("${(doctorSharePercentage * 100).round()}%")
        ]);
        sheet.appendRow([TextCellValue("")]);

        List<Map<String, dynamic>> doctorRecords = doctorData[doctor] ?? [];

        if (doctorRecords.isNotEmpty) {
          // Add header row
          sheet.appendRow([
            TextCellValue("Nama Pasien"),
            TextCellValue("Total Bayar"),
            TextCellValue("Bagian Dokter"),
            TextCellValue("Tanggal"),
            TextCellValue("Waktu")
          ]);

          // Add data rows
          for (var row in doctorRecords) {
            sheet.appendRow([
              TextCellValue(row['Nama Pasien']),
              TextCellValue(formatCurrency(row['Total Bayar'])),
              TextCellValue(formatCurrency(row['Bagian Dokter'])),
              TextCellValue(row['Tanggal']),
              TextCellValue(row['Waktu'])
            ]);
          }

          // Add summary section
          sheet.appendRow([TextCellValue("")]);
          sheet.appendRow([TextCellValue("Summary")]);

          // Calculate total revenue for doctor
          int totalRevenue = doctorRecords.fold(
              0, (sum, item) => sum + (item['Total Bayar'] as int));
          int doctorIncome = doctorRecords.fold(
              0, (sum, item) => sum + (item['Bagian Dokter'] as int));

          sheet.appendRow([
            TextCellValue("Total Gross Revenue:"),
            TextCellValue(formatCurrency(totalRevenue))
          ]);

          sheet.appendRow([
            TextCellValue("Doctor Total Income:"),
            TextCellValue(formatCurrency(doctorIncome))
          ]);

          sheet.appendRow([
            TextCellValue("Clinic Share:"),
            TextCellValue(formatCurrency(totalRevenue - doctorIncome))
          ]);

          sheet.appendRow([
            TextCellValue("Total Transactions:"),
            IntCellValue(doctorRecords.length)
          ]);

          sheet.appendRow([
            TextCellValue("Average Revenue per Transaction:"),
            TextCellValue(
                formatCurrency((totalRevenue / doctorRecords.length).round()))
          ]);
        } else {
          sheet.appendRow([
            TextCellValue(
                "No data available for this doctor with the current filters")
          ]);
        }
      }

      // Save Excel file
      final bytes = excel.save();
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
            content: Text('Doctor financial report downloaded successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating Excel file: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Doctor Financial Report',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          color: Colors.white,
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
                      // Doctor dropdown
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
                      const SizedBox(width: 16),
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
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All Months'),
                                ),
                                ...months.map((month) {
                                  return DropdownMenuItem<String>(
                                    value: month,
                                    child: Text(month),
                                  );
                                }),
                              ],
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
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('All Years'),
                                ),
                                ...List.generate(5, (index) {
                                  final year =
                                      (DateTime.now().year - index).toString();
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year),
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
                  Row(
                    children: [
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
                      // Doctor share percentage input
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue:
                              (doctorSharePercentage * 100).toString(),
                          decoration: InputDecoration(
                            labelText: 'Doctor Share %',
                            suffixText: '%',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            double? percentage = double.tryParse(value);
                            if (percentage != null &&
                                percentage >= 0 &&
                                percentage <= 100) {
                              setState(() {
                                doctorSharePercentage = percentage / 100;
                                fetchData(); // Recalculate with new percentage
                              });
                            }
                          },
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
                            selectedDoctor = null;
                            fetchData(); // Refresh with cleared filters
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: lightTextColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Export Report'),
                        onPressed:
                            tableData.isNotEmpty ? exportDoctorReport : null,
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
            const SizedBox(height: 16),
// Pilihan sistem pembayaran
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment System:',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PaymentSystem>(
                      value: currentPaymentSystem,
                      icon:
                          Icon(Icons.keyboard_arrow_down, color: primaryColor),
                      onChanged: (PaymentSystem? newValue) {
                        if (newValue != null) {
                          setState(() {
                            currentPaymentSystem = newValue;
                            fetchData(); // Recalculate with new payment system
                          });
                        }
                      },
                      items: PaymentSystem.values.map((system) {
                        String displayName;
                        switch (system) {
                          case PaymentSystem.percentageBased:
                            displayName =
                                'Model 1: Persentase Pendapatan Kotor';
                            break;
                          case PaymentSystem.percentageAfterCost:
                            displayName = 'Model 2: Persentase Setelah Biaya';
                            break;
                          case PaymentSystem.salaryPlusBonus:
                            displayName = 'Model 3: Gaji Tetap + Bonus';
                            break;
                        }
                        return DropdownMenuItem<PaymentSystem>(
                          value: system,
                          child: Text(displayName),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
// Parameter untuk sistem pembayaran yang dipilih
            if (currentPaymentSystem == PaymentSystem.percentageAfterCost)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Material Cost %:',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: (materialCostPercentage * 100).toString(),
                      decoration: InputDecoration(
                        labelText: 'Material Cost %',
                        suffixText: '%',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        double? percentage = double.tryParse(value);
                        if (percentage != null &&
                            percentage >= 0 &&
                            percentage <= 100) {
                          setState(() {
                            materialCostPercentage = percentage / 100;
                            fetchData();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            if (currentPaymentSystem == PaymentSystem.salaryPlusBonus)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Base Salary:',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: baseSalary.toString(),
                          decoration: InputDecoration(
                            labelText: 'Monthly Base Salary',
                            prefixText: 'Rp ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            double? salary = double.tryParse(value);
                            if (salary != null && salary >= 0) {
                              setState(() {
                                baseSalary = salary;
                                fetchData();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Bonus %:',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: (bonusPercentage * 100).toString(),
                          decoration: InputDecoration(
                            labelText: 'Bonus Percentage',
                            suffixText: '%',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            double? percentage = double.tryParse(value);
                            if (percentage != null &&
                                percentage >= 0 &&
                                percentage <= 100) {
                              setState(() {
                                bonusPercentage = percentage / 100;
                                fetchData();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            // Doctor chart section
            if (selectedDoctor != null) _buildDoctorChart(),

            // Doctor summary cards
            _buildDoctorSummaryCards(),

            // Doctor transactions table
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      selectedDoctor != null
                          ? 'Transactions for Dr. $selectedDoctor'
                          : 'All Doctor Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  _buildDataTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildDoctorChart() {
    if (selectedDoctor == null ||
        !doctorRevenuePerMonth.containsKey(selectedDoctor)) {
      return const SizedBox.shrink();
    }

    Map<String, double> doctorMonthlyData =
        doctorRevenuePerMonth[selectedDoctor]!;

    // Find the maximum value for better scaling
    double maxValue = 0;
    for (var value in doctorMonthlyData.values) {
      if (value > maxValue) maxValue = value;
    }

    // Scale up a bit for better visibility
    maxValue = maxValue > 0 ? (maxValue * 1.2) : 1000;

    return Container(
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
            'Monthly Income for Dr. $selectedDoctor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
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
                borderData: FlBorderData(show: true),
                minY: 0,
                maxY: maxValue,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(12, (index) {
                      final month = months[index];
                      final revenue = doctorMonthlyData[month] ?? 0;
                      return FlSpot(index.toDouble(), revenue);
                    }),
                    isCurved: true,
                    barWidth: 3,
                    color: accentColor,
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
                      color: accentColor.withOpacity(0.2),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final index = barSpot.x.toInt();
                        final month = months[index];
                        final value = barSpot.y;
                        return LineTooltipItem(
                          '$month\n${formatCurrency(value.toInt())}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSummaryCards() {
    if (isLoading) {
      return Center(
        child: SpinKitRing(
          color: primaryColor,
          size: 50.0,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    List<Widget> doctorCards = [];

    // If a specific doctor is selected, only show that doctor's card
    List<String> doctorsToShow =
        selectedDoctor != null ? [selectedDoctor!] : doctorList;

    for (String doctor in doctorsToShow) {
      List<Map<String, dynamic>> doctorTransactions = doctorData[doctor] ?? [];

      if (doctorTransactions.isEmpty) continue;

      // Calculate totals
      int totalRevenue = doctorTransactions.fold(
          0, (sum, item) => sum + (item['Total Bayar'] as int));
      int doctorIncome = doctorTransactions.fold(
          0, (sum, item) => sum + (item['Bagian Dokter'] as int));
      int clinicShare = totalRevenue - doctorIncome;

      doctorCards.add(
        Container(
          margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
                  'Dr. $doctor Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Total Revenue',
                        formatCurrency(totalRevenue),
                        Icons.attach_money,
                        primaryColor,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Doctor Share',
                        formatCurrency(doctorIncome),
                        Icons.person,
                        accentColor,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Clinic Share',
                        formatCurrency(clinicShare),
                        Icons.business,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Transactions',
                        doctorTransactions.length.toString(),
                        Icons.receipt_long,
                        Colors.amber,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Avg Revenue',
                        formatCurrency(
                            (totalRevenue / doctorTransactions.length).round()),
                        Icons.trending_up,
                        Colors.purple,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Avg Doctor Share',
                        formatCurrency(
                            (doctorIncome / doctorTransactions.length).round()),
                        Icons.savings,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (doctorCards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No data available for the selected filters',
            style: TextStyle(
              color: lightTextColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Tambahan khusus untuk model gaji + bonus
    if (currentPaymentSystem == PaymentSystem.salaryPlusBonus) {
      // Calculate total revenue for all displayed doctors
      int calculatedTotalRevenue = 0;
      for (String doctor in doctorsToShow) {
        List<Map<String, dynamic>> doctorTransactions =
            doctorData[doctor] ?? [];
        calculatedTotalRevenue += doctorTransactions.fold(
            0, (sum, item) => sum + (item['Total Bayar'] as int));
      }

      doctorCards.add(
        Container(
          margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
                'Model Gaji + Bonus Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Base Salary',
                      formatCurrency(baseSalary.toInt()),
                      Icons.money,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Bonus Amount',
                      formatCurrency(
                          (calculatedTotalRevenue * bonusPercentage).toInt()),
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Total Income',
                      formatCurrency((baseSalary +
                              calculatedTotalRevenue * bonusPercentage)
                          .toInt()),
                      Icons.account_balance_wallet,
                      primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: doctorCards);
  }

  Widget _buildSummaryItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: lightTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: SpinKitRing(
            color: primaryColor,
            size: 50.0,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    if (tableData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No data available for the selected filters',
            style: TextStyle(
              color: lightTextColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowColor: MaterialStateProperty.all(backgroundColor),
        columns: const [
          DataColumn(label: Text('Nama Pasien')),
          DataColumn(label: Text('Dokter')),
          DataColumn(label: Text('Total Bayar')),
          DataColumn(label: Text('Bagian Dokter')),
          DataColumn(label: Text('Tanggal')),
          DataColumn(label: Text('Waktu')),
        ],
        rows: tableData.map((data) {
          return DataRow(
            cells: [
              DataCell(Text(data['Nama Pasien'])),
              DataCell(Text(data['Dokter'])),
              DataCell(Text(formatCurrency(data['Total Bayar']))),
              DataCell(Text(formatCurrency(data['Bagian Dokter']))),
              DataCell(Text(data['Tanggal'])),
              DataCell(Text(data['Waktu'])),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Enum untuk jenis sistem pembayaran
enum PaymentSystem {
  percentageBased, // Model 1: Pembagian persentase dari pendapatan kotor
  percentageAfterCost, // Model 2: Pembagian setelah dikurangi biaya
  salaryPlusBonus // Model 3: Gaji tetap plus bonus persentase
}
