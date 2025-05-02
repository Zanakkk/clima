// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  // Contoh data metode pembayaran
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Kartu Kredit',
      'description': 'Pembayaran melalui kartu kredit',
      'status': 'Aktif',
    },
    {
      'name': 'Transfer Bank',
      'description': 'Pembayaran melalui transfer bank',
      'status': 'Nonaktif',
    },
  ];

  // Kontroller untuk formulir
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;

  // Fungsi untuk menambah atau mengedit metode pembayaran
  void _addOrEditPaymentMethod({int? index}) {
    setState(() {
      if (index == null) {
        _paymentMethods.add({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'status': _isActive ? 'Aktif' : 'Nonaktif',
        });
      } else {
        _paymentMethods[index] = {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'status': _isActive ? 'Aktif' : 'Nonaktif',
        };
      }
      _nameController.clear();
      _descriptionController.clear();
      _isActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormAddPaymentMethod(),
            const SizedBox(height: 20),
            _buildPaymentMethodsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormAddPaymentMethod() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah/Edit Metode Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(labelText: 'Nama Metode Pembayaran'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            Row(
              children: [
                const Text('Status: '),
                Switch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                Text(_isActive ? 'Aktif' : 'Nonaktif'),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrEditPaymentMethod,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Simpan Metode Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsTable() {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Deskripsi')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Tindakan')),
              ],
              rows: _paymentMethods
                  .map(
                    (method) => DataRow(
                      cells: [
                        DataCell(Text(method['name'])),
                        DataCell(Text(method['description'])),
                        DataCell(Text(method['status'])),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _nameController.text = method['name'];
                                _descriptionController.text =
                                    method['description'];
                                _isActive = method['status'] == 'Aktif';
                                // Simpan perubahan
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _paymentMethods.remove(method);
                                });
                              },
                            ),
                          ],
                        )),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
