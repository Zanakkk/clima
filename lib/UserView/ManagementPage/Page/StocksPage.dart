// ignore_for_file: empty_catches, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../main.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  _StocksPageState createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  List<Map<String, dynamic>> _stocks = [];
  String? _selectedCategory;
  String? _selectedStockCategory;
  String? _expiryFilter;

  Timer? _timer;

  // Kontroller untuk formulir
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _expiryDateController = TextEditingController();

  final String apiUrl =
      '$URL/stokbarang.json'; // Ganti dengan URL API Anda

  @override
  void initState() {
    super.initState();
    _fetchStocks();
    _startPolling(); // Mulai polling
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hentikan polling ketika halaman ditutup
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchStocks(); // Ambil data setiap 5 detik
    });
  }

  Future<void> _fetchStocks() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          setState(() {
            _stocks = data.entries.map((entry) {
              return {
                'id': entry.key,
                ...entry.value as Map<String, dynamic>,
              };
            }).toList();
          });
        } else {
        }
      } else {
      }
    } catch (e) {
    }
  }

  Future<void> _postStock(Map<String, dynamic> stockData) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(stockData),
      );

      if (response.statusCode == 201) {
        _fetchStocks(); // Refresh data
      } else {
      }
    } catch (e) {
    }
  }

  // Fungsi untuk menambah atau mengedit stok barang
  void _addOrEditStock({int? index}) {
    final stockData = {
      'name': _nameController.text,
      'category': _selectedStockCategory!,
      'quantity': int.parse(_quantityController.text),
      'unit': _unitController.text,
      'expiryDate': _expiryDateController.text,
    };

    _postStock(stockData);

    setState(() {
      _nameController.clear();
      _selectedStockCategory = null;
      _quantityController.clear();
      _unitController.clear();
      _expiryDateController.clear();
    });
  }

  // Fungsi untuk memilih tanggal kadaluarsa
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

  // Fungsi untuk mendapatkan daftar stok yang difilter berdasarkan kategori dan kadaluarsa
  List<Map<String, dynamic>> _getFilteredStocks() {
    return _stocks.where((stock) {
      final isCategoryMatch = _selectedCategory == null || _selectedCategory == 'Semua' || stock['category'] == _selectedCategory;
      final isExpiryMatch = _expiryFilter == null || _expiryFilter == 'Semua' || _isExpiryMatch(stock);

      return isCategoryMatch && isExpiryMatch;
    }).toList();
  }

  bool _isExpiryMatch(Map<String, dynamic> stock) {
    DateTime expiryDate = DateTime.parse(stock['expiryDate']);
    if (_expiryFilter == 'Kadaluarsa') {
      return expiryDate.isBefore(DateTime.now());
    } else if (_expiryFilter == 'Belum Kadaluarsa') {
      return expiryDate.isAfter(DateTime.now());
    }
    return true; // Default to match all
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks'),
        automaticallyImplyLeading: false, // Nonaktifkan tombol kembali
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryDashboard(),
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: _buildFormAddStock(),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 5,
                    child: _buildStocksTable(),
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
    int totalItems = _stocks.length;
    int lowStockItems = _stocks.where((item) => item['quantity'] < 50).length;
    int expiredItems = _stocks.where((item) {
      DateTime expiryDate = DateTime.parse(item['expiryDate']);
      return expiryDate.isBefore(DateTime.now());
    }).length;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDashboardItem('Total Item', totalItems.toString()),
            _buildDashboardItem('Low Stock', lowStockItems.toString()),
            _buildDashboardItem('Expired', expiredItems.toString()),
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
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        const Text('Filter berdasarkan kategori: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _selectedCategory,
          hint: const Text('Pilih Kategori'),
          items: ['Semua', 'APD', 'Alat', 'Bahan']
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
        const SizedBox(width: 20),
        const Text('Filter berdasarkan kadaluarsa: ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _expiryFilter,
          hint: const Text('Pilih Status Kadaluarsa'),
          items: ['Semua', 'Kadaluarsa', 'Belum Kadaluarsa']
              .map((status) => DropdownMenuItem<String>(
            value: status,
            child: Text(status),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _expiryFilter = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFormAddStock() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah/Edit Stok Barang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Barang'),
            ),
            DropdownButton<String>(
              value: _selectedStockCategory,
              hint: const Text('Pilih Kategori'),
              items: ['APD', 'Alat', 'Bahan']
                  .map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStockCategory = value;
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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrEditStock,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]),
              child: const Text('Simpan Stok Barang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStocksTable() {
    List<Map<String, dynamic>> filteredStocks = _getFilteredStocks();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Nama Barang')),
              DataColumn(label: Text('Kategori')),
              DataColumn(label: Text('Jumlah Stok')),
              DataColumn(label: Text('Unit')),
              DataColumn(label: Text('Tanggal Kadaluarsa')),
              DataColumn(label: Text('Tindakan')),
            ],
            rows: filteredStocks
                .map(
                  (stock) => DataRow(
                cells: [
                  DataCell(Text(stock['name'])),
                  DataCell(Text(stock['category'])),
                  DataCell(Text(stock['quantity'].toString())),
                  DataCell(Text(stock['unit'])),
                  DataCell(Text(stock['expiryDate'])),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _nameController.text = stock['name'];
                          _selectedStockCategory = stock['category'];
                          _quantityController.text =
                              stock['quantity'].toString();
                          _unitController.text = stock['unit'];
                          _expiryDateController.text = stock['expiryDate'];
                          // Implement edit functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _stocks.remove(stock);
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
