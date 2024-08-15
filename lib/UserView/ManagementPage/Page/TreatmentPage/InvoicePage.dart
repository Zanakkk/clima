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
    final procedures = selectedTindakan?['procedure'] as Map<String, dynamic>?;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Pasien
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nama Pasien:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    selectedPatient?['fullName'] ?? 'Tidak ada data',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Dokter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dokter:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    selectedTindakan?['doctor'] ?? 'Tidak ada data',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tanggal:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    selectedTindakan?['timestamp'] != null
                        ? _formatDate(selectedTindakan!['timestamp'])
                        : 'Tidak ada data',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Pukul
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pukul:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    selectedTindakan?['timestamp'] != null
                        ? _formatTime(selectedTindakan!['timestamp'])
                        : 'Tidak ada data',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Detail Tindakan
              const Text(
                'Detail Tindakan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              procedures == null || procedures.isEmpty
                  ? const Center(
                child: Text(
                  'Tidak ada tindakan yang tercatat',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
                  : Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: procedures.entries.map<Widget>((entry) {
                      final procedure = entry.value;
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(procedure['procedure'] ??
                                    'Tidak ada data'),
                                Text(formatCurrency(
                                    procedure['price'] ?? 0)),
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
              // Total Biaya
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency(procedures != null
                        ? _calculateTotalCost(procedures)
                        : 0),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Button Send to WhatsApp
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

  // Helper function to calculate the total cost of all procedures
  double _calculateTotalCost(Map<String, dynamic> procedures) {
    return procedures.values
        .map<double>((procedure) =>
    (procedure['price'] as num?)?.toDouble() ?? 0)
        .fold(0, (a, b) => a + b);
  }

  // Helper function to format timestamp into 'Tanggal: 16 Agustus 2024, Pukul: 03:10'
  String _formatDateTime(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final String formattedDate = _formatDate(dateTime as String);
      final String formattedTime = _formatTime(dateTime as String);
      return '$formattedDate, Pukul: $formattedTime';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Helper function to format date
  String _formatDate(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = months[dateTime.month - 1];
      final year = dateTime.year.toString();
      return '$day $month $year';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Helper function to format time
  String _formatTime(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return 'Invalid time';
    }
  }
}
