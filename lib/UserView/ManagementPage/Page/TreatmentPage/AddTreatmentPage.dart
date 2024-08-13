import 'package:flutter/material.dart';

class AddTreatmentPage extends StatelessWidget {
  final Map<String, dynamic>? selectedPatient;
  final Map<String, dynamic>? selectedTindakan;
  final String? selectedProcedure;
  final TextEditingController procedureExplanationController;
  final Function(String?) onProcedureChanged;
  final Function() onAddProcedure;

  const AddTreatmentPage({
    super.key,
    required this.selectedPatient,
    required this.selectedTindakan,
    required this.selectedProcedure,
    required this.procedureExplanationController,
    required this.onProcedureChanged,
    required this.onAddProcedure,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPatient == null || selectedTindakan == null) {
      return const Center(child: Text('Pilih pasien untuk melihat detail'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama: ${selectedPatient!['fullName'] ?? ''}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('NIK: ${selectedPatient!['nik'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Alamat: ${selectedPatient!['address'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Tanggal Lahir: ${selectedPatient!['dob'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Jenis Kelamin: ${selectedPatient!['gender'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Nomor Telepon: ${selectedPatient!['phone'] ?? ''}'),
          const SizedBox(height: 16),
          const Text(
            'Tambah Tindakan:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: selectedProcedure,
            hint: const Text('Pilih Tindakan'),
            items: ['Tambal', 'Scaling', 'Cabut'].map((procedure) {
              return DropdownMenuItem<String>(
                value: procedure,
                child: Text(procedure),
              );
            }).toList(),
            onChanged: onProcedureChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: procedureExplanationController,
            decoration: InputDecoration(
              labelText: 'Keterangan (opsional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: onAddProcedure,
              child: const Text('Add Treatment'),
            ),
          ),
        ],
      ),
    );
  }
}
