// ignore_for_file: deprecated_member_use, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LihatProfilKlinik extends StatefulWidget {
  const LihatProfilKlinik({super.key});

  @override
  State<LihatProfilKlinik> createState() => _LihatProfilKlinikState();
}

class _LihatProfilKlinikState extends State<LihatProfilKlinik>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? currentUser;
  Map<String, dynamic>? clinicData;
  bool isLoading = true;
  String? errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getCurrentUser();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _getCurrentUser() {
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      _getClinicData();
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'User tidak login';
      });
    }
  }

  Future<void> _getClinicData() async {
    try {
      if (currentUser?.email != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('clinics')
            .where('email', isEqualTo: currentUser!.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            clinicData =
                querySnapshot.docs.first.data() as Map<String, dynamic>;
            isLoading = false;
          });

          // Start animations
          _fadeController.forward();
          Future.delayed(const Duration(milliseconds: 100), () {
            _slideController.forward();
          });
        } else {
          setState(() {
            errorMessage = 'Data klinik tidak ditemukan';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Tidak tersedia';
    DateTime date = timestamp.toDate();
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;
    final isMobile = screenSize.width <= 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(isDesktop),
      body: SizedBox(
        height: screenSize.height - (isDesktop ? 80 : 56),
        child: isLoading
            ? _buildLoadingState()
            : errorMessage != null
                ? _buildErrorState()
                : clinicData != null
                    ? _buildProfileContent(isDesktop, isTablet, isMobile)
                    : _buildEmptyState(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop) {
    return AppBar(
      title: Text(
        'Profil Klinik',
        style: TextStyle(
          fontSize: isDesktop ? 24 : 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E293B),
      elevation: 1,
      shadowColor: const Color(0xFF1E293B).withOpacity(0.1),
      toolbarHeight: isDesktop ? 80 : 56,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data klinik...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 30,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _getCurrentUser();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Data tidak tersedia',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildProfileContent(bool isDesktop, bool isTablet, bool isMobile) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: EdgeInsets.all(isDesktop
              ? 24
              : isTablet
                  ? 20
                  : 16),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : double.infinity,
                maxHeight: double.infinity,
              ),
              child: isDesktop
                  ? _buildDesktopLayout()
                  : isTablet
                      ? _buildTabletLayout()
                      : _buildMobileLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildProfileCard(isDesktop: true),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(child: _buildInfoCard(isDesktop: true)),
              const SizedBox(height: 16),
              _buildActionButtons(isDesktop: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(child: _buildProfileCard(isDesktop: false)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard(isDesktop: false)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(isDesktop: false),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileCard(isDesktop: false),
                const SizedBox(height: 16),
                _buildInfoCard(isDesktop: false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionButtons(isDesktop: false),
      ],
    );
  }

  Widget _buildProfileCard({required bool isDesktop}) {
    final logoSize = isDesktop ? 80.0 : 70.0;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF1D4ED8).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: clinicData!['logo'] != null &&
                      clinicData!['logo'].toString().isNotEmpty
                  ? Image.network(
                      clinicData!['logo'],
                      fit: BoxFit.cover,
                      width: logoSize,
                      height: logoSize,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF3B82F6)),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return _buildDefaultLogo(logoSize);
                      },
                    )
                  : _buildDefaultLogo(logoSize),
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          Text(
            clinicData!['name'] ?? 'Nama Klinik',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isDesktop ? 12 : 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: clinicData!['activation'] == true
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: clinicData!['activation'] == true
                    ? const Color(0xFF10B981).withOpacity(0.3)
                    : const Color(0xFFF59E0B).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: clinicData!['activation'] == true
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  clinicData!['activation'] == true ? 'Aktif' : 'Tidak Aktif',
                  style: TextStyle(
                    color: clinicData!['activation'] == true
                        ? const Color(0xFF047857)
                        : const Color(0xFFD97706),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.local_hospital_rounded,
        size: size * 0.4,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildInfoCard({required bool isDesktop}) {
    final infoItems = [
      {
        'icon': Icons.email_rounded,
        'label': 'Email',
        'value': clinicData!['email'] ?? '-',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.location_on_rounded,
        'label': 'Alamat',
        'value': clinicData!['address'] ?? '-',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.numbers_rounded,
        'label': 'No. Rekam Medis',
        'value': clinicData!['medicalRecordNumber'] ?? '-',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.vpn_key_rounded,
        'label': 'Endpoint ID',
        'value': clinicData!['endpointId'] ?? '-',
        'color': const Color(0xFF06B6D4),
      },
      {
        'icon': Icons.calendar_today_rounded,
        'label': 'Tanggal Dibuat',
        'value': _formatDate(clinicData!['createdAt']),
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Detail',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          Expanded(
            child: ListView.builder(
              itemCount: infoItems.length,
              itemBuilder: (context, index) {
                final item = infoItems[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: _buildInfoItem(
                          item['icon'] as IconData,
                          item['label'] as String,
                          item['value'] as String,
                          item['color'] as Color,
                          isDesktop,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String label, String value, Color color, bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 10 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: isDesktop ? 20 : 18,
              color: color,
            ),
          ),
          SizedBox(width: isDesktop ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons({required bool isDesktop}) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_rounded,
            label: 'Edit Profil',
            isPrimary: true,
            isDesktop: isDesktop,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Fitur edit akan segera tersedia'),
                  backgroundColor: const Color(0xFF3B82F6),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: isDesktop ? 16 : 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.refresh_rounded,
            label: 'Refresh',
            isPrimary: false,
            isDesktop: isDesktop,
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _fadeController.reset();
              _slideController.reset();
              _getClinicData();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required bool isDesktop,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isDesktop ? 18 : 16),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isDesktop ? 14 : 12,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF3B82F6) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF374151),
        elevation: 0,
        padding: EdgeInsets.symmetric(
            vertical: isDesktop ? 14 : 12, horizontal: isDesktop ? 20 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}
