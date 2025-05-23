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

class _PricelistPageState extends State<PricelistPage>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Color scheme
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF64B5F6);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadClinicId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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
        _animationController.forward();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _editingItemId = null;
  }

  void _showAddEditForm({
    String? itemId,
    String? name,
    String? description,
    double? price,
  }) {
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
      elevation: 0,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEBF8FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _editingItemId != null ? Icons.edit : Icons.add,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _editingItemId != null
                                    ? 'Edit Layanan'
                                    : 'Tambah Layanan Baru',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                _editingItemId != null
                                    ? 'Perbarui informasi layanan'
                                    : 'Isi detail layanan medis',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: textSecondary),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() => _isAddingItem = false);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Name field
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama Layanan',
                      hint: 'Contoh: Konsultasi Umum',
                      icon: Icons.medical_services_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama layanan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Description field
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Deskripsi',
                      hint: 'Jelaskan detail layanan yang diberikan',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Price field
                    _buildTextField(
                      controller: _priceController,
                      label: 'Harga (IDR)',
                      hint: 'Contoh: 150000',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _editingItemId != null ? Icons.update : Icons.add,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _editingItemId != null
                                  ? 'Perbarui Layanan'
                                  : 'Tambah Layanan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() => _isAddingItem = false);
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: textSecondary),
            prefixIcon: Icon(icon, color: primaryColor, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_clinicId == null) {
      _showSnackBar(
        'Tidak dapat menemukan akun klinik. Pastikan Anda sudah login.',
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);
    Navigator.pop(context);

    try {
      double price = double.tryParse(_priceController.text) ?? 0;

      if (_editingItemId != null) {
        await _firestore.collection('pricelist').doc(_editingItemId).update({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': price,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _showSnackBar('Layanan berhasil diperbarui', accentColor);
      } else {
        await _firestore.collection('pricelist').add({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': price,
          'clinicId': _clinicId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _showSnackBar('Layanan berhasil ditambahkan', accentColor);
      }

      _resetForm();
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePricelistItem(String itemId) async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('pricelist').doc(itemId).delete();
      _showSnackBar('Layanan berhasil dihapus', accentColor);
    } catch (e) {
      _showSnackBar('Error saat menghapus layanan: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmation(String itemId, String serviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 12),
            Text('Hapus Layanan'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus layanan "$serviceName"? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePricelistItem(itemId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildServiceCard({
    required String id,
    required String name,
    required String description,
    required double price,
    required int index,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAddEditForm(
              itemId: id,
              name: name,
              description: description,
              price: price,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEBF8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _showAddEditForm(
                                itemId: id,
                                name: name,
                                description: description,
                                price: price,
                              );
                              break;
                            case 'delete':
                              _showDeleteConfirmation(id, name);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16, color: primaryColor),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Hapus'),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            size: 16,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF8FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatCurrency(price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFEBF8FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 64,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Layanan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai tambahkan layanan medis\nyang tersedia di klinik Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddEditForm(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Tambah Layanan Pertama',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Daftar Layanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,

      ),
      body: _isLoading && !_isAddingItem
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : _clinicId == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login,
                        size: 64,
                        color: textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Anda harus login sebagai klinik\nuntuk melihat daftar layanan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('pricelist')
                      .where('clinicId', isEqualTo: _clinicId)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    final documents = snapshot.data?.docs ?? [];

                    if (documents.isEmpty) {
                      return _buildEmptyState();
                    }

                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final data =
                              documents[index].data() as Map<String, dynamic>;
                          final id = documents[index].id;
                          final name = data['name'] ?? 'Layanan Tanpa Nama';
                          final description = data['description'] ?? '';
                          final price = (data['price'] is int)
                              ? (data['price'] as int).toDouble()
                              : (data['price'] ?? 0.0);

                          return _buildServiceCard(
                            id: id,
                            name: name,
                            description: description,
                            price: price,
                            index: index,
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: _clinicId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showAddEditForm(),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              label: const Text(
                'Tambah Layanan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}
