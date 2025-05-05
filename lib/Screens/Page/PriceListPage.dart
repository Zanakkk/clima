// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PricelistItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String clinicId;
  final DateTime? createdAt;

  PricelistItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.clinicId,
    this.createdAt,
  });

  // Factory constructor to create a PricelistItem from a Firestore document
  factory PricelistItem.fromFirestore(String id, Map<String, dynamic> data) {
    return PricelistItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] ?? 0.0),
      clinicId: data['clinicId'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert PricelistItem to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'clinicId': clinicId,
      'createdAt': createdAt,
    };
  }
}

class PricelistPage extends StatefulWidget {
  const PricelistPage({super.key});

  @override
  _PricelistPageState createState() => _PricelistPageState();
}

class _PricelistPageState extends State<PricelistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers for add/edit form
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String? _clinicId;
  bool _isLoading = true;
  bool _isAddingItem = false;
  String? _editingItemId;

  @override
  void initState() {
    super.initState();
    _loadClinicId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Get the clinic ID for the current user
  Future<void> _loadClinicId() async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('clinics')
          .where('email', isEqualTo: currentUser.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _clinicId = querySnapshot.docs.first.id;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Format price as Indonesian Rupiah
  String _formatCurrency(double amount) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  // Reset form fields
  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _editingItemId = null;
  }

  // Show bottom sheet with form
  void _showAddEditForm(
      {String? itemId, String? name, String? description, double? price}) {
    // If itemId is provided, we're editing an existing item
    if (itemId != null) {
      _editingItemId = itemId;
      _nameController.text = name ?? '';
      _descriptionController.text = description ?? '';
      _priceController.text = price?.toString() ?? '';
    } else {
      _resetForm();
    }

    setState(() {
      _isAddingItem = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _editingItemId != null
                          ? 'Edit Treatment/Service'
                          : 'Add New Treatment/Service',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => _isAddingItem = false);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a service name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Price field
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (IDR)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _editingItemId != null ? 'Update Service' : 'Add Service',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() => _isAddingItem = false);
    });
  }

  // Save or update a pricelist item
  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form validation failed
    }

    if (_clinicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Cannot find clinic account. Please make sure you are logged in.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    Navigator.pop(context); // Close the bottom sheet

    try {
      // Parse price from text field
      double price = double.tryParse(_priceController.text) ?? 0;

      if (_editingItemId != null) {
        // Update existing item
        await _firestore.collection('pricelist').doc(_editingItemId).update({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': price,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );
      } else {
        // Add new item
        await _firestore.collection('pricelist').add({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': price,
          'clinicId': _clinicId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service added successfully')),
        );
      }

      // Reset form after successful operation
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Delete a pricelist item
  Future<void> _deletePricelistItem(String itemId) async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('pricelist').doc(itemId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting service: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePricelistItem(itemId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading && !_isAddingItem
          ? const Center(child: CircularProgressIndicator())
          : _clinicId == null
              ? const Center(
                  child: Text(
                      'You must be logged in as a clinic to view pricelists'),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('pricelist')
                      .where('clinicId', isEqualTo: _clinicId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final documents = snapshot.data?.docs ?? [];

                    if (documents.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.medical_services_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No services added yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _showAddEditForm(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Your First Service'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final data =
                            documents[index].data() as Map<String, dynamic>;
                        final id = documents[index].id;
                        final name = data['name'] ?? 'Unnamed Service';
                        final description = data['description'] ?? '';
                        final price = (data['price'] is int)
                            ? (data['price'] as int).toDouble()
                            : (data['price'] ?? 0.0);

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(description),
                                const SizedBox(height: 8),
                                Text(
                                  _formatCurrency(price),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _showAddEditForm(
                                      itemId: id,
                                      name: name,
                                      description: description,
                                      price: price,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _showDeleteConfirmation(id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: _clinicId != null
          ? FloatingActionButton(
              onPressed: () => _showAddEditForm(),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
