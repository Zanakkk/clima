import 'package:flutter/material.dart';

class PasienListPage extends StatelessWidget {
  final List<Map<String, dynamic>> patients;
  final Function(Map<String, dynamic>) onPatientSelected;
  final Map<String, dynamic>? selectedPatient;

  const PasienListPage({
    super.key,
    required this.patients,
    required this.onPatientSelected,
    required this.selectedPatient,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return ListTile(
          title: Text(patient['fullName']),
          subtitle: Text('NIK: ${patient['nik']}'),
          onTap: () {
            onPatientSelected(patient);
          },
          selected: selectedPatient == patient,
        );
      },
    );
  }
}
