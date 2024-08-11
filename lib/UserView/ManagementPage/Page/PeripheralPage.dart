// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';

class PeripheralsPage extends StatefulWidget {
  const PeripheralsPage({super.key});

  @override
  _PeripheralsPageState createState() => _PeripheralsPageState();
}

class _PeripheralsPageState extends State<PeripheralsPage> {
  List<Map<String, dynamic>> _peripherals = [];
  String? _selectedCategory;
  String? _selectedPeripheralCategory;

  // Kontroller untuk formulir
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPeripherals();
  }

  Future<void> _fetchPeripherals() async {
    // Simulasi data dari server atau database
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _peripherals = [
        {
          'name': 'Printer',
          'category': 'Teknologi',
          'quantity': 3,
          'unit': 'Unit',
          'expiryDate': '2025-01-01',
          'status': 'Operasional'
        },
        {
          'name': 'Monitor',
          'category': 'Teknologi',
          'quantity': 5,
          'unit': 'Unit',
          'expiryDate': '2024-12-01',
          'status': 'Butuh Perawatan'
        },
        {
          'name': 'Stetoskop',
          'category': 'Peralatan Medis',
          'quantity': 10,
          'unit': 'Unit',
          'expiryDate': '2023-06-01',
          'status': 'Operasional'
        },
      ];
    });
  }

  Future<void> _addOrEditPeripheral({int? index}) async {
    final peripheralData = {
      'name': _nameController.text,
      'category': _selectedPeripheralCategory!,
      'quantity': int.parse(_quantityController.text),
      'unit': _unitController.text,
      'expiryDate': _expiryDateController.text,
      'status': _statusController.text,
    };

    setState(() {
      if (index == null) {
        _peripherals.add(peripheralData);
      } else {
        _peripherals[index] = peripheralData;
      }

      _nameController.clear();
      _selectedPeripheralCategory = null;
      _quantityController.clear();
      _unitController.clear();
      _expiryDateController.clear();
      _statusController.clear();
    });
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredPeripherals() {
    if (_selectedCategory == null || _selectedCategory == 'Semua') {
      return _peripherals;
    } else {
      return _peripherals
          .where((peripheral) => peripheral['category'] == _selectedCategory)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peripherals'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryDashboard(),
            const SizedBox(height: 20),
            _buildCategoryFilter(),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: _buildFormAddPeripheral(),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 5,
                    child: _buildPeripheralsTable(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDashboard() {
    int totalItems = _peripherals.length;
    int operationalItems = _peripherals
        .where((item) => item['status'] == 'Operasional')
        .length;
    int needsMaintenanceItems = _peripherals
        .where((item) => item['status'] == 'Butuh Perawatan')
        .length;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDashboardItem('Total Peripherals', totalItems.toString()),
            _buildDashboardItem('Operational', operationalItems.toString()),
            _buildDashboardItem(
                'Needs Maintenance', needsMaintenanceItems.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Row(
      children: [
        const Text('Filter berdasarkan kategori: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _selectedCategory,
          hint: const Text('Pilih Kategori'),
          items: ['Semua', 'Teknologi', 'Peralatan Medis', 'Alat Kantor']
              .map((category) => DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFormAddPeripheral() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah/Edit Peripheral',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Peripheral'),
            ),
            DropdownButton<String>(
              value: _selectedPeripheralCategory,
              hint: const Text('Pilih Kategori'),
              items: ['Teknologi', 'Peralatan Medis', 'Alat Kantor']
                  .map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeripheralCategory = value;
                });
              },
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Jumlah Stok'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
            TextField(
              controller: _expiryDateController,
              decoration: InputDecoration(
                labelText: 'Tanggal Kadaluarsa',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectExpiryDate(context),
                ),
              ),
            ),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Status Operasional'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrEditPeripheral,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]),
              child: const Text('Simpan Peripheral'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeripheralsTable() {
    List<Map<String, dynamic>> filteredPeripherals = _getFilteredPeripherals();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Nama Peripheral')),
              DataColumn(label: Text('Kategori')),
              DataColumn(label: Text('Jumlah Stok')),
              DataColumn(label: Text('Unit')),
              DataColumn(label: Text('Tanggal Kadaluarsa')),
              DataColumn(label: Text('Status Operasional')),
              DataColumn(label: Text('Tindakan')),
            ],
            rows: filteredPeripherals
                .map(
                  (peripheral) => DataRow(
                cells: [
                  DataCell(Text(peripheral['name'])),
                  DataCell(Text(peripheral['category'])),
                  DataCell(Text(peripheral['quantity'].toString())),
                  DataCell(Text(peripheral['unit'])),
                  DataCell(Text(peripheral['expiryDate'])),
                  DataCell(Text(peripheral['status'])),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _nameController.text = peripheral['name'];
                          _selectedPeripheralCategory =
                          peripheral['category'];
                          _quantityController.text =
                              peripheral['quantity'].toString();
                          _unitController.text = peripheral['unit'];
                          _expiryDateController.text =
                          peripheral['expiryDate'];
                          _statusController.text = peripheral['status'];
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _peripherals.remove(peripheral);
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
    );
  }
}
