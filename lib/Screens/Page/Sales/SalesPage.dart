// ignore_for_file: library_private_types_in_public_api, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  String? clinicId;

  // Define color scheme
  final Color primaryColor = const Color(0xFF1976D2); // Primary blue
  final Color accentColor = const Color(0xFF64B5F6);  // Light blue
  final Color backgroundColor = const Color(0xFFF5F7FA); // Light gray background
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF333333);
  final Color lightTextColor = const Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _getClinicId().then((_) {
      procedureStatsFuture = fetchProcedureStats(selectedMonth, selectedYear);
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
      print('Error getting clinic ID: $e');
    }
  }

  Future<Map<String, ProcedureStat>> fetchProcedureStats(
      String month, String year) async {
    try {
      if (clinicId == null) {
        throw Exception('Clinic ID not found');
      }

      // Get procedures from pricelist collection
      final QuerySnapshot pricelistSnapshot = await FirebaseFirestore.instance
          .collection('pricelist')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      // Initialize stats map with procedure names and prices
      final Map<String, ProcedureStat> procedureStats = {};
      for (var doc in pricelistSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['name'] != null && data['price'] != null) {
          procedureStats[data['name']] = ProcedureStat(
            procedureName: data['name'],
            price: (data['price'] as num).toDouble(),
            count: 0,
          );
        }
      }

      // Process tindakan collection to count procedures by month/year
      final QuerySnapshot tindakanSnapshot = await FirebaseFirestore.instance
          .collection('tindakan')
          .where('doctorId', isNotEqualTo: '') // Just to ensure we get all documents
          .get();

      double calculatedRevenue = 0;

      // Process each tindakan document
      for (var tindakanDoc in tindakanSnapshot.docs) {
        final tindakanData = tindakanDoc.data() as Map<String, dynamic>;
        if (tindakanData['timestamp'] != null) {
          // Handle both Timestamp and String timestamp formats
          DateTime procedureDate;
          if (tindakanData['timestamp'] is Timestamp) {
            procedureDate = (tindakanData['timestamp'] as Timestamp).toDate();
          } else {
            // Handle string format timestamps
            procedureDate = DateTime.parse(tindakanData['timestamp'].toString());
          }

          final String procedureMonth = DateFormat('MMMM').format(procedureDate);
          final String procedureYear = DateFormat('yyyy').format(procedureDate);

          if (procedureMonth == month && procedureYear == year) {
            // Get all procedures within this tindakan document
            final proceduresSnapshot = await tindakanDoc.reference
                .collection('procedure')
                .get();

            for (var procedureDoc in proceduresSnapshot.docs) {
              final procedureData = procedureDoc.data();
              final procedureName = procedureData['procedure'] as String?;
              final procedurePrice = procedureData['price'] as num?;

              if (procedureName != null && procedureStats.containsKey(procedureName)) {
                procedureStats[procedureName]!.count++;
                calculatedRevenue += procedurePrice?.toDouble() ?? 0;
              }
            }
          }
        }
      }

      setState(() {
        totalRevenue = calculatedRevenue;
      });

      return procedureStats;
    } catch (e) {
      print('Error fetching procedure stats: $e');
      throw Exception('Failed to load procedure data: $e');
    }
  }

  void _refreshData() {
    setState(() {
      procedureStatsFuture = fetchProcedureStats(selectedMonth, selectedYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Sales Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector card
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
                  'Select Period',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Month dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedMonth,
                            icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Year dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedYear,
                            icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
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
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Revenue summary card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Revenue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${NumberFormat('#,###').format(totalRevenue.toInt())}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          // View table button
          Container(
            margin: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.table_chart),
              label: const Text('View Detailed Table'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SalesTablePage()),
                );
              },
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

          // Procedures list
          Expanded(
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Procedures',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<Map<String, ProcedureStat>>(
                      future: procedureStatsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: SpinKitCircle(
                              color: primaryColor,
                              size: 50.0,
                            ),
                          );
                        } else if (snapshot.hasError) {
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
                                  snapshot.error.toString().replaceAll('Exception: ', ''),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: lightTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  color: Colors.grey[400],
                                  size: 60,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No procedure data available',
                                  style: TextStyle(
                                    color: lightTextColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          final procedureStats = snapshot.data!.values.toList();

                          // Sort by frequency
                          procedureStats.sort((a, b) => b.count.compareTo(a.count));

                          return ListView.separated(
                            itemCount: procedureStats.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final procedureStat = procedureStats[index];
                              print(procedureStat);
                              double revenue = procedureStat.count * procedureStat.price;

                              // Calculate percentage of total revenue
                              double percentage = totalRevenue > 0
                                  ? (revenue / totalRevenue) * 100
                                  : 0;

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Procedure count indicator
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        procedureStat.count.toString(),
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Procedure details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            procedureStat.procedureName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rp ${NumberFormat('#,###').format(procedureStat.price.toInt())} per procedure',
                                            style: TextStyle(
                                              color: lightTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // Progress indicator
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: percentage / 100,
                                              backgroundColor: Colors.grey.shade200,
                                              color: accentColor,
                                              minHeight: 4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Revenue amount
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Rp ${NumberFormat('#,###').format(revenue.toInt())}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${percentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: accentColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
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
            ),
          ),
          const SizedBox(height: 16),
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