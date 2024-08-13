import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class InvoicePage extends StatelessWidget {
  final Map<String, dynamic>? selectedPatient;
  final Map<String, dynamic>? selectedTindakan;
  final Function() onSendInvoice;
  final Function(double) formatCurrency;

  const InvoicePage({
    super.key,
    required this.selectedPatient,
    required this.selectedTindakan,
    required this.onSendInvoice,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPatient == null || selectedTindakan == null) {
      return const Center(child: Text('Pilih pasien untuk melihat invoice'));
    }

    final procedures = selectedTindakan!['procedure'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nama Pasien:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    selectedPatient!['fullName'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dokter:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    selectedTindakan!['doctor'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tanggal:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    selectedTindakan!['timestamp'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Detail Tindakan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: procedures.entries.map<Widget>((entry) {
                      final procedure = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(procedure['procedure'] ?? ''),
                                Text(formatCurrency(procedure['price'])),
                              ],
                            ),
                            if (procedure['explanation'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  'Keterangan: ${procedure['explanation']}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency(_calculateTotalCost(procedures)),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: onSendInvoice,
                  icon: const Icon(
                    LineIcons.whatSApp,
                    color: Colors.white,
                  ),
                  label: const Text('Send to WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalCost(Map<String, dynamic> procedures) {
    return procedures.values
        .map<double>((procedure) => (procedure['price'] as num).toDouble())
        .fold(0, (a, b) => a + b);
  }
}
