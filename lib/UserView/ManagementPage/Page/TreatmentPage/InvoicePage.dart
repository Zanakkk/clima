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
            children: [
              _buildPatientInfo(),
              const Divider(height: 24),
              _buildProceduresList(procedures),
              const Divider(height: 24),
              _buildTotalCost(procedures),
              const SizedBox(height: 16),
              _buildSendInvoiceButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(
          'Nama Pasien:',
          selectedPatient?['fullName'] ?? 'Tidak ada data',
        ),
        const SizedBox(height: 8),
        _buildRow(
          'Dokter:',
          selectedTindakan?['doctor'] ?? 'Tidak ada data',
        ),
        const SizedBox(height: 8),
        _buildRow(
          'Tanggal:',
          selectedTindakan?['timestamp'] != null
              ? _formatDate(selectedTindakan!['timestamp'])
              : 'Tidak ada data',
        ),
        const SizedBox(height: 8),
        _buildRow(
          'Pukul:',
          selectedTindakan?['timestamp'] != null
              ? _formatTime(selectedTindakan!['timestamp'])
              : 'Tidak ada data',
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildProceduresList(Map<String, dynamic>? procedures) {
    if (procedures == null || procedures.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada tindakan yang tercatat',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Flexible(
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
                      Text(procedure['procedure'] ?? 'Tidak ada data'),
                      Text(formatCurrency(procedure['price'] ?? 0)),
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
    );
  }

  Widget _buildTotalCost(Map<String, dynamic>? procedures) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          formatCurrency(
              procedures != null ? _calculateTotalCost(procedures) : 0),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSendInvoiceButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onSendInvoice,
        icon: const Icon(
          LineIcons.whatSApp,
          color: Colors.white,
        ),
        label: const Text(
          'Send to WhatsApp',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366),
        ),
      ),
    );
  }

  double _calculateTotalCost(Map<String, dynamic> procedures) {
    return procedures.values
        .map<double>(
            (procedure) => (procedure['price'] as num?)?.toDouble() ?? 0)
        .fold(0, (a, b) => a + b);
  }

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
