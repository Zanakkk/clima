import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Page/Dashboard.dart';

class ClimaClinicPageControl extends StatefulWidget {
  const ClimaClinicPageControl({super.key});

  @override
  State<ClimaClinicPageControl> createState() => _ClimaClinicPageControlState();
}

class _ClimaClinicPageControlState extends State<ClimaClinicPageControl> {
  bool climaActive = false;
  late String climaDate;
  late String climaPlan;
  List<bool>? controllerClinic;

  // Mapping index to the appropriate label
  final List<String> pageLabels = [
    'Dashboard',
    'Reservation Page',
    'Patient Page',
    'Treatment Page',
    'Medical Record Page',
    'Receipt - advanced',
    'Management Control',
    'Staff List Page',
    'Stocks Page',
    'Peripheral Page',
    'Report Page',
    'Customer Support Page',
    'Logout Page',
    'Management Doctor',
    'Management Price List',
    'Laporan Stok Obat',
    'Sales Page',
    'Purchase Page',
    'Payroll',
    'Cetak Invoice',
    'Kirim Invoice WA',
    'Ekspor Laporan Ke EXCEL',
  ];

  @override
  void initState() {
    super.initState();
    fetchClimaData();
  }

  Future<void> fetchClimaData() async {
    const String url =
        'https://clima-93a68-default-rtdb.asia-southeast1.firebasedatabase.app/clinics/klinikident3558/CLIMA.json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          climaActive = data['ClimaActive'];
          climaDate = data['ClimaDate'] ?? 'Unknown Date'; // Handle null case
          climaPlan = data['ClimaPlan'] ?? 'Unknown Plan'; // Handle null case
          controllerClinic = List<bool>.from(data['controllerclinic'] ?? []);
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure that climaActive is non-null before using it
    final isClimaActive = climaActive ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Clinic Control'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: climaActive == null || controllerClinic == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DashboardBox(
                    title: 'Clima Active',
                    value: isClimaActive ? 'Yes' : 'No',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardBox(
                    title: 'Clima Date',
                    value: climaDate,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardBox(
                    title: 'Clima Plan',
                    value: climaPlan,
                    color: Colors.blue,
                  ),
                ),const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    child: DashboardBox(
                      title: 'Upgrade plan Clinic',
                      value: 'Klik Disini',
                      color: Colors.black
                    ),
                    onTap: (){
                      print('upgrdade');
                    },
                  )
                  )
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Controller Clinic Access:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: controllerClinic!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      controllerClinic![index]
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: controllerClinic![index]
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(
                      pageLabels[index],
                      style: TextStyle(
                        color: controllerClinic![index]
                            ? Colors.black87
                            : Colors.grey,
                        fontWeight: controllerClinic![index]
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
