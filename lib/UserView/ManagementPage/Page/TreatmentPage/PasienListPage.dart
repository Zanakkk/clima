import 'package:flutter/material.dart';

class PasienListPage extends StatelessWidget {
  final List<Map<String, dynamic>> patients;
  final Function(Map<String, dynamic>) onPatientSelected;
  final Map<String, dynamic>? selectedPatient;
  final VoidCallback onRefresh; // Tambahkan callback onRefresh

  const PasienListPage({
    super.key,
    required this.patients,
    required this.onPatientSelected,
    required this.selectedPatient,
    required this.onRefresh, // Tambahkan ini ke constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tambahkan tombol refresh di bagian atas
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Pasien',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh, // Panggil fungsi refresh
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return ListTile(
                title: Text(patient['fullName']),
                subtitle: Text(patient['nik']),
                selected: selectedPatient == patient,
                onTap: () {
                  onPatientSelected(patient);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
