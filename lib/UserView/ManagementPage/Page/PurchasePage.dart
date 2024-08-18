// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../../../Component/FormatUmum.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  _PurchasesPageState createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  // Data contoh untuk tabel
  final List<Map<String, dynamic>> _purchases = [
    {
      'tanggal': '2024-08-10',
      'namaBarang': 'Masker N95',
      'kategori': 'Alat Medis',
      'jumlah': 50,
      'hargaSatuan': 15000,
      'totalHarga': 750000,
      'supplier': 'PT. Medis Sehat',
      'status': 'Lunas',
    },
    {
      'tanggal': '2024-08-11',
      'namaBarang': 'Obat Parasetamol',
      'kategori': 'Obat-obatan',
      'jumlah': 100,
      'hargaSatuan': 2000,
      'totalHarga': 200000,
      'supplier': 'PT. Apotek Sentosa',
      'status': 'Belum Lunas',
    },
  ];

  // Kontroller untuk formulir
  final _namaBarangController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _hargaSatuanController = TextEditingController();
  final _supplierController = TextEditingController();

  // Fungsi untuk menambahkan pembelian baru
  void _addPurchase() {
    setState(() {
      _purchases.add({
        'tanggal': DateTime.now().toString().split(' ')[0],
        'namaBarang': _namaBarangController.text,
        'kategori': _kategoriController.text,
        'jumlah': int.parse(_jumlahController.text),
        'hargaSatuan': int.parse(_hargaSatuanController.text),
        'totalHarga': int.parse(_jumlahController.text) *
            int.parse(_hargaSatuanController.text),
        'supplier': _supplierController.text,
        'status': 'Belum Lunas',
      });
      _namaBarangController.clear();
      _kategoriController.clear();
      _jumlahController.clear();
      _hargaSatuanController.clear();
      _supplierController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryDashboard(),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: _buildFormAddPurchase(),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 5,
                    child: _buildPurchasesTable(),
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
    int totalPembelian = _purchases.length;
    int totalPengeluaran = _purchases
        .map((p) => p['totalHarga'] as int)
        .reduce((value, element) => value + element);

    return Card(
      color: Colors.tealAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDashboardItem('Total Pembelian', totalPembelian.toString()),
            _buildDashboardItem(
                'Total Pengeluaran', formatRupiahManual(totalPengeluaran)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFormAddPurchase() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Pembelian Baru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _namaBarangController,
              decoration: const InputDecoration(labelText: 'Nama Barang'),
            ),
            TextField(
              controller: _kategoriController,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            TextField(
              controller: _jumlahController,
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _hargaSatuanController,
              decoration: const InputDecoration(labelText: 'Harga Satuan'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _supplierController,
              decoration: const InputDecoration(labelText: 'Supplier'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPurchase,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Simpan Pembelian'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasesTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Tanggal')),
              DataColumn(label: Text('Nama Barang')),
              DataColumn(label: Text('Kategori')),
              DataColumn(label: Text('Jumlah')),
              DataColumn(label: Text('Harga Satuan')),
              DataColumn(label: Text('Total Harga')),
              DataColumn(label: Text('Supplier')),
              DataColumn(label: Text('Status')),
            ],
            rows: _purchases
                .map(
                  (purchase) => DataRow(
                    cells: [
                      DataCell(Text(purchase['tanggal'])),
                      DataCell(Text(purchase['namaBarang'])),
                      DataCell(Text(purchase['kategori'])),
                      DataCell(Text(purchase['jumlah'].toString())),
                      DataCell(Text('Rp ${purchase['hargaSatuan']}')),
                      DataCell(Text('Rp ${purchase['totalHarga']}')),
                      DataCell(Text(purchase['supplier'])),
                      DataCell(Text(purchase['status'])),
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
