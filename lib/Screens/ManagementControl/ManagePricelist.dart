// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../HomePage.dart';

class Price {
  String id;
  String name;
  int price;
  String description;

  Price(
      {required this.id,
      required this.name,
      required this.price,
      required this.description});

  // Factory method to create a Price object from a Map (JSON response)
  factory Price.fromMap(String id, Map<String, dynamic> data) {
    return Price(
      id: id,
      name: data['name'] as String,
      price: data['price'] as int,
      description: data['description'] as String,
    );
  }
}

class ManagementPriceListPage extends StatefulWidget {
  const ManagementPriceListPage({super.key});

  @override
  _ManagementPriceListPageState createState() =>
      _ManagementPriceListPageState();
}

class _ManagementPriceListPageState extends State<ManagementPriceListPage> {
  final String databaseUrl = '$FULLURL/pricelist.json';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Price> priceList = [];
  String? selectedPriceId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPriceList();
  }

  // Fetch pricelist from Firebase
  Future<void> _fetchPriceList() async {
    try {
      final response = await http.get(Uri.parse(databaseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        List<Price> tempList = [];

        data.forEach((key, value) {
          tempList.add(Price.fromMap(key, value));
        });

        setState(() {
          priceList = tempList;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load pricelist');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  // Add or update treatment
  Future<void> _submitPrice() async {
    final String name = _nameController.text.trim();
    final int price = int.tryParse(_priceController.text.trim()) ?? 0;
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || price <= 0 || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields correctly")),
      );
      return;
    }

    try {
      final body = json
          .encode({'name': name, 'price': price, 'description': description});

      if (selectedPriceId == null) {
        // Add new price
        final response = await http.post(
          Uri.parse(databaseUrl),
          body: body,
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          _fetchPriceList();
        }
      } else {
        // Edit existing price
        final editUrl = '$FULLURL/pricelist/$selectedPriceId.json';
        final response = await http.put(
          Uri.parse(editUrl),
          body: body,
          headers: {"Content-Type": "application/json"},
        );
        if (response.statusCode == 200) {
          _fetchPriceList();
        }
      }

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  // Delete treatment
  Future<void> _deletePrice(String priceId) async {
    final deleteUrl = '$FULLURL/pricelist/$priceId.json';
    try {
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        _fetchPriceList();
      } else {
        throw Exception('Failed to delete price');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    setState(() {
      selectedPriceId = null;
    });
  }

  void _editPrice(Price price) {
    setState(() {
      selectedPriceId = price.id;
      _nameController.text = price.name;
      _priceController.text = price.price.toString();
      _descriptionController.text = price.description;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Price List'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Container
            Container(
              width: 400,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.red.withOpacity(0.6), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Treatment Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              TextField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16.0),
                              TextField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: _submitPrice,
                                child: Text(selectedPriceId == null
                                    ? 'Add Treatment'
                                    : 'Update Treatment'),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20.0),
            // List Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.red.withOpacity(0.6), width: 2),
                ),
                child: ListView.builder(
                  itemCount: priceList.length,
                  itemBuilder: (context, index) {
                    final price = priceList[index];
                    return Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(price.name),
                        subtitle: Text(
                            'Price: ${price.price}\nDescription: ${price.description}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editPrice(price);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deletePrice(price.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
