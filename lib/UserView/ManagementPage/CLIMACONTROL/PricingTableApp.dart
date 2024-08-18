import 'package:clima/UserView/ManagementPage/CLIMACONTROL/CustomPlan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PricingTableApp extends StatelessWidget {
  const PricingTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pricing Cards',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: PricingTableScreen(),
    );
  }
}

class PricingTableScreen extends StatelessWidget {
  final List<Map<String, dynamic>> pricingPlans = [
    {
      'plan': 'Basic',
      'price': 700000,
      'features': [
        'Lembar SOAP',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Informasi Dokter',
        'Cetak Invoice',
        'Laporan Keuangan Klinik'
      ],
    },
    {
      'plan': 'Advanced',
      'price': 1300000,
      'features': [
        'Fitur Basic',
        'Odontogram',
        'Tindakan Pasien',
        'Informasi Harga',
      ],
    },
    {
      'plan': 'Pro',
      'price': 2000000,
      'features': [
        'Fitur Advanced',
        'Manajemen Data Pasien',
        'Informasi Tindakan',
        'Kirim Invoice Lewat WA',
        'Resep',
        'Laporan Alat Bahan',
        'Laporan Pembayaran Dokter & Staff',
        'Laporan Stok Obat'
      ],
    },
    {
      'plan': 'Custom',
      'price': 'Mulai dari 350.000',
      'features': [
        'Lembar SOAP',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Informasi Dokter',
        'Cetak Invoice',
        'Laporan Keuangan Klinik'
      ],
    },
  ];

  final List<Map<String, dynamic>> pricingPlansfull = [
    {
      'plan': 'Basic',
      'price': 'Rp 600.000,00',
      'features': [
        'Lembar SOAP',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Informasi Dokter',
        'Cetak Invoice',
        'Laporan Keuangan Klinik'
      ],
    },
    {
      'plan': 'Advanced',
      'price': 'Rp 1.300.000,00',
      'features': [
        'Lembar SOAP',
        'Odontogram',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Lihat Pasien',
        'Tindakan Pasien',
        'Informasi Dokter',
        'Informasi Harga',
        'Cetak Invoice',
        'Laporan Keuangan Klinik'
      ],
    },
    {
      'plan': 'Pro',
      'price': 'Rp 2.000.000,00',
      'features': [
        'Lembar SOAP',
        'Odontogram',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Lihat Pasien',
        'Tindakan Pasien',
        'Manajemen Data Pasien',
        'Informasi Dokter',
        'Informasi Harga',
        'Informasi Tindakan',
        'Cetak Invoice',
        'Kirim Invoice Lewat WA',
        'Laporan Keuangan Klinik',
        'Laporan Alat Bahan',
        'Laporan Pembayaran Dokter & Staff',
        'Laporan Stok Obat'
      ],
    }
  ];

  PricingTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: LayoutBuilder(
        builder: (context, constraints) {
          // For larger screens, we display the cards in a row.
          bool isWide = constraints.maxWidth > 800;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Display Pricing Cards
                isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: pricingPlans.map((plan) {
                          bool isHighlighted = plan['plan'] == 'Advanced';

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PricingCard(
                              plan: plan,
                              isHighlighted: isHighlighted,
                            ),
                          );
                        }).toList(),
                      )
                    : Column(
                        children: pricingPlans.map((plan) {
                          bool isHighlighted = plan['plan'] == 'Advanced';

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PricingCard(
                              plan: plan,
                              isHighlighted: isHighlighted,
                            ),
                          );
                        }).toList(),
                      ),
                PricingComparisonScreen(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PricingCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isHighlighted;
  final bool
      isAdvancedPlan; // Indicates if it's the most popular or worth-it plan

  const PricingCard({
    super.key,
    required this.plan,
    this.isHighlighted = false,
    this.isAdvancedPlan = false,
  });

  @override
  Widget build(BuildContext context) {
    // Handle special case for the "Custom" plan
    bool isCustomPlan = plan['plan'] == 'Custom';
    String priceText =
        isCustomPlan ? 'Rp 350.000' : formatCurrency(plan['price']);
    String tekssebelumpricecustom = 'Mulai dari';
    int? originalPrice = isCustomPlan ? null : plan['price'];
    int? discountedPrice = originalPrice != null
        ? (originalPrice * 0.5).toInt()
        : null; // Apply a 50% discount for non-custom plans

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: 300, // Fixed width for all pricing cards
          height: 400, // Fixed height for all pricing cards
          child: Card(
            elevation: isHighlighted ? 12 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: isHighlighted ? Colors.purple : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Plan Name
                  const SizedBox(height: 16),
                  Text(
                    plan['plan'],
                    style: TextStyle(
                      fontSize: 20,
                      color: isHighlighted ? Colors.white : Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pricing Text for Custom Plan and Discounted Price for Others
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (originalPrice != null)
                        Text(
                          formatCurrency(originalPrice),
                          style: TextStyle(
                            fontSize: 18,
                            color: isHighlighted ? Colors.white70 : Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 8),
                      isCustomPlan
                          ? Column(
                              children: [
                                Text(
                                  tekssebelumpricecustom,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  priceText,
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: isHighlighted
                                        ? Colors.white
                                        : Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              formatCurrency(discountedPrice!),
                              style: TextStyle(
                                fontSize: 40,
                                color: isHighlighted
                                    ? Colors.white
                                    : Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'per month',
                    style: TextStyle(
                      fontSize: 16,
                      color: isHighlighted ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: plan['features'].map<Widget>((feature) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 16,
                                color: isHighlighted
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (plan['plan'] == 'Custom') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CustomPlan()),
                        );
                      }
                      // Handle button press for other plans
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          isHighlighted ? Colors.purple : Colors.white,
                      backgroundColor:
                          isHighlighted ? Colors.white : Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text('Select Plan'),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Advanced Plan Badge
        if (isAdvancedPlan)
          Positioned(
            top: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String formatCurrency(int price) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(price);
  }
}

class PricingComparisonScreen extends StatelessWidget {
  final List<Map<String, dynamic>> pricingPlansFull = [
    {
      'plan': 'Basic',
      'price': 'Rp 600.000,00',
      'features': [
        'Lembar SOAP',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Informasi Dokter',
        'Cetak Invoice',
        'Laporan Keuangan Klinik'
      ],
    },
    {
      'plan': 'Advanced',
      'price': 'Rp 1.300.000,00',
      'features': [
        'Lembar SOAP',
        'Odontogram',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Lihat Pasien',
        'Tindakan Pasien',
        'Informasi Dokter',
        'Informasi Harga',
        'Cetak Invoice',
        'Laporan Keuangan Klinik'
      ],
    },
    {
      'plan': 'Pro',
      'price': 'Rp 2.000.000,00',
      'features': [
        'Lembar SOAP',
        'Odontogram',
        'Penjadwalan Pasien',
        'Daftar Pasien',
        'Lihat Pasien',
        'Tindakan Pasien',
        'Manajemen Data Pasien',
        'Informasi Dokter',
        'Informasi Harga',
        'Informasi Tindakan',
        'Cetak Invoice',
        'Kirim Invoice Lewat WA',
        'Laporan Keuangan Klinik',
        'Laporan Alat Bahan',
        'Laporan Pembayaran Dokter & Staff',
        'Laporan Stok Obat'
      ],
    }
  ];

  PricingComparisonScreen({super.key});

  // Extract a unique list of all features across the plans
  List<String> getAllUniqueFeatures() {
    final Set<String> allFeatures = {};
    for (var plan in pricingPlansFull) {
      allFeatures.addAll(plan['features']);
    }
    return allFeatures.toList();
  }

  @override
  Widget build(BuildContext context) {
    final allFeatures = getAllUniqueFeatures();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Plan Names and Prices
          Row(
            children: [
              const SizedBox(
                  width: 200,
                  child: Text('Features',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              for (var plan in pricingPlansFull)
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(plan['plan'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(plan['price'], style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(),
          // Feature Rows: Showing which plan contains each feature
          for (var feature in allFeatures)
            Row(
              children: [
                SizedBox(width: 200, child: Text(feature)),
                for (var plan in pricingPlansFull)
                  SizedBox(
                    width: 150,
                    child: Icon(
                      plan['features'].contains(feature)
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: plan['features'].contains(feature)
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
