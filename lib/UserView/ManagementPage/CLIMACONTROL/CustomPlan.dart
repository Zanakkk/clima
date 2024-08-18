import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomPlan extends StatefulWidget {
  const CustomPlan({super.key});

  @override
  _CustomPlanState createState() => _CustomPlanState();
}

class _CustomPlanState extends State<CustomPlan> {
  // This will hold the categorized features with their associated prices
  final List<Map<String, dynamic>> categorizedFeatures = [
    {
      'category': 'Rekam Medis',
      'features': [
        {'name': 'Lembar SOAP', 'price': 50000, 'isFixed': true},
        {'name': 'Odontogram', 'price': 50000, 'isFixed': false},
      ]
    },
    {
      'category': 'Pasien',
      'features': [
        {'name': 'Daftar Pasien', 'price': 30000, 'isFixed': true},
        {'name': 'Lihat Pasien', 'price': 30000, 'isFixed': true},
        {'name': 'Tindakan Pasien', 'price': 40000, 'isFixed': true},
        {'name': 'Penjadwalan Pasien', 'price': 50000, 'isFixed': false},
        {'name': 'Managemen Data Pasien', 'price': 50000, 'isFixed': false},
      ]
    },
    {
      'category': 'Informasi',
      'features': [
        {'name': 'Informasi Dokter', 'price': 30000, 'isFixed': true},
        {'name': 'Informasi Harga', 'price': 30000, 'isFixed': true},
        {'name': 'Informasi Tindakan', 'price': 40000, 'isFixed': true},
      ]
    },
    {
      'category': 'Obat',
      'features': [
        {'name': 'Resep Obat', 'price': 50000, 'isFixed': false},
      ]
    },
    {
      'category': 'Invoice',
      'features': [
        {'name': 'Cetak Invoice', 'price': 50000, 'isFixed': true},
        {'name': 'Kirim Invoice Lewat WA', 'price': 50000, 'isFixed': false},
      ]
    },
    {
      'category': 'Laporan',
      'features': [
        {'name': 'Laporan Keuangan Klinik', 'price': 50000, 'isFixed': true},
        {'name': 'Laporan Alat Bahan', 'price': 50000, 'isFixed': false},
        {'name': 'Laporan Stok', 'price': 50000, 'isFixed': false},
        {'name': 'Laporan Pembayaran Dokter & Staff (Payroll)', 'price': 50000, 'isFixed': false},
        {'name': 'Laporan Stok Obat', 'price': 50000, 'isFixed': false},
      ]
    },
    {
      'category': 'Add Ons',
      'features': [
        {'name': 'Absensi', 'price': 50000, 'isFixed': false},
        {'name': 'Ekspor Laporan ke Excel', 'price': 50000, 'isFixed': false},
      ]
    },
    {
      'category': 'Management Cabang',
      'features': []
    },
    {
      'category': 'Web Informasi Klinik',
      'features': []
    }
  ];

  List<Map<String, dynamic>> selectedFeatures = [];

  // Calculate the total price of selected and fixed features
  int calculateTotal() {
    int total = 0;

    // Include the price of fixed features and selected optional features
    for (var category in categorizedFeatures) {
      for (var feature in category['features']) {
        if (feature['isFixed'] == true || selectedFeatures.contains(feature)) {
          total += feature['price'] as int;
        }
      }
    }

    return total;
  }

  // Toggle selection of a feature (only for non-fixed features)
  void toggleFeatureSelection(Map<String, dynamic> feature) {
    if (!feature['isFixed']) {
      setState(() {
        if (selectedFeatures.contains(feature)) {
          selectedFeatures.remove(feature);
        } else {
          selectedFeatures.add(feature);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Plan Builder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categorizedFeatures.length,
                itemBuilder: (context, index) {
                  var category = categorizedFeatures[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['category'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2, // Adjusted to allow more vertical space
                        ),
                        itemCount: category['features'].length,
                        itemBuilder: (context, featureIndex) {
                          var feature = category['features'][featureIndex];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              onTap: () => toggleFeatureSelection(feature),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        feature['name'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: feature['isFixed'] ? Colors.grey : Colors.black,
                                        ),
                                        textAlign: TextAlign.center, // Center align the text
                                        maxLines: 2, // Allow a maximum of 2 lines for wrapping
                                        overflow: TextOverflow.ellipsis, // Truncate text if too long
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formatCurrency(feature['price']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(
                                      feature['isFixed']
                                          ? Icons.lock
                                          : selectedFeatures.contains(feature)
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: feature['isFixed']
                                          ? Colors.grey
                                          : selectedFeatures.contains(feature)
                                          ? Colors.green
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Price: Rp ${formatCurrency(calculateTotal())}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Custom Plan Created! Total: Rp ${formatCurrency(calculateTotal())}'),
                  ),
                );
              },
              child: const Text('Create Custom Plan'),
            ),
          ],
        ),
      ),
    );
  }

  String formatCurrency(int price) {
    final formatCurrency =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(price);
  }
}
