// ignore_for_file: non_constant_identifier_names

import 'dart:html' as html;

import 'package:clima/Screens/Page/PatientsPage/PatientsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

import '../main.dart';
import '../utils/LiveClock.dart';
import 'Dashboard.dart';
import 'ManagementControl/ManagementControl.dart';
import 'Page/AbsenPage.dart';
import 'Page/AddDoctorsPage.dart';
import 'Page/CustomerSupportPage.dart';
import 'Page/MedicalRecord/MedicalRecord.dart';
import 'Page/PeripheralPage.dart';
import 'Page/PriceListPage.dart';
import 'Page/ReservationPage/AdminReserv.dart';
import 'Page/ReservationPage/ReservationPage.dart';
import 'Page/StaffListPage.dart';
import 'Page/StocksPage.dart';
import 'Page/TreatmentPage/TreatmentPage.dart';
import 'RegisterLogin/Login.dart';

String FULLURL = '';

// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_web_libraries_in_flutter

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.clinicId});

  final String clinicId;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isExpanded = true; // Default expanded on desktop
  int? _hoveredIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Ambil data pengguna jika tersedia
  String displayName = 'User';
  String displayType = 'Standard';
  String? photoURL;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start expanded
    _animationController.value = 1.0;
  }

  Future<void> _fetchUserData() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('userdata')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();

        setState(() {
          displayName = userData['name'] ?? 'User';
          displayType = userData['userType'] ?? 'Standard';
          photoURL = userData['photoURL'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Container()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Container()), // Replace with SettingsScreen when ready
        );
        break;
      case 'logout':
        _handleLogout();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        break;
    }
  }

  // List dari semua screen
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ReservationsPage(),
    const AdminReservationsPage(),
    const PatientsPage(),
    const TreatmentsPage(),
    const MedicalRecord(),
    const PricelistPage(),
    const DaftarDoktor(),
    const ManagementControl(),
    const StaffListPage(),
    const StocksPage(),
    const PeripheralsPage(),
    const Absen(),
    const CustomerSupportPage(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
  ];

  // Daftar menu dengan ikon dan label
  final List<Map<String, dynamic>> _menuItems = [
    {
      "icon": Icons.dashboard_outlined,
      "iconSelected": Icons.dashboard,
      "label": "Dashboard"
    },
    {
      "icon": Icons.calendar_today,
      "iconSelected": Icons.calendar_month,
      "label": "Reservation Page"
    }, {
      "icon": Icons.calendar_today,
      "iconSelected": Icons.calendar_month,
      "label": "Admin Reserv"
    },
    {
      "icon": Icons.person_outline,
      "iconSelected": Icons.person,
      "label": "Patient Page"
    },
    {
      "icon": Icons.healing_outlined,
      "iconSelected": Icons.healing,
      "label": "Treatment Page"
    },
    {
      "icon": Icons.assignment_outlined,
      "iconSelected": Icons.assignment,
      "label": "Medical Record Page"
    },
    {
      "icon": Icons.receipt_long_outlined,
      "iconSelected": Icons.medical_services,
      "label": "Service & Training"
    },
    {
      "icon": Icons.receipt_long_outlined,
      "iconSelected": LineIcons.doctor,
      "label": "Tambah Dokter"
    },
    {
      "icon": Icons.receipt_long_outlined,
      "iconSelected": Icons.receipt,
      "label": "Receipt - advanced"
    },
    {
      "icon": Icons.settings_outlined,
      "iconSelected": Icons.settings,
      "label": "Management Control"
    },
    {
      "icon": Icons.people_outline,
      "iconSelected": Icons.people,
      "label": "Staff List Page"
    },
    {
      "icon": Icons.inventory_2_outlined,
      "iconSelected": Icons.inventory_2,
      "label": "Stocks Page"
    },
    {
      "icon": Icons.devices_other,
      "iconSelected": Icons.devices,
      "label": "Peripheral Page"
    },
    {
      "icon": Icons.access_time,
      "iconSelected": Icons.access_time_filled,
      "label": "Absen Page"
    },
    {
      "icon": Icons.support_agent,
      "iconSelected": Icons.headset_mic,
      "label": "Customer Support Page"
    },
    {
      "icon": Icons.logout,
      "iconSelected": Icons.logout,
      "label": "Logout Page"
    },
    {
      "icon": Icons.medical_services_outlined,
      "iconSelected": Icons.medical_services,
      "label": "Management Doctor"
    },
    {
      "icon": Icons.manage_accounts_outlined,
      "iconSelected": Icons.manage_accounts,
      "label": "Management Staff"
    },
    {
      "icon": Icons.list_alt_outlined,
      "iconSelected": Icons.list_alt,
      "label": "Management Price List"
    },
    {
      "icon": Icons.local_pharmacy_outlined,
      "iconSelected": Icons.local_pharmacy,
      "label": "Laporan Stok Obat"
    },
    {
      "icon": Icons.point_of_sale,
      "iconSelected": Icons.shopping_cart,
      "label": "Sales Page"
    },
    {
      "icon": Icons.monetization_on_outlined,
      "iconSelected": Icons.monetization_on,
      "label": "Payroll"
    },
    {
      "icon": Icons.print_outlined,
      "iconSelected": Icons.print,
      "label": "Cetak Invoice"
    },
    {
      "icon": Icons.send_to_mobile,
      "iconSelected": Icons.send,
      "label": "Kirim Invoice WA"
    },
    {
      "icon": Icons.file_download_outlined,
      "iconSelected": Icons.file_download,
      "label": "Ekspor Laporan Ke EXCEL"
    },
  ];

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          // Mobile layout
          return _buildMobileLayout();
        } else {
          // Desktop layout
          return _buildDesktopLayout();
        }
      },
    );
  }

  Scaffold _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MedColors.primary,
        elevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const Image(
                image: AssetImage('assets/LOGO.jpg'),
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'CLIMA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon:
                const Icon(Icons.account_circle_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildMobileBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Text(
                  _menuItems[_selectedIndex]["label"],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const LiveClock(
                  isDesktop: true,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari pasien atau dokter...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.search, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Action buttons row with consistent styling
                InkWell(
                  onTap: () => _showUserMenu(),
                  borderRadius: BorderRadius.circular(30),
                  child: _buildUserProfileContainer(),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: GNav(
            rippleColor: MedColors.primary.withOpacity(0.2),
            hoverColor: MedColors.primary.withOpacity(0.1),
            gap: 8,
            activeColor: MedColors.primary,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 300),
            tabBackgroundColor: MedColors.primary.withOpacity(0.1),
            color: Colors.grey.shade600,
            tabs: _menuItems
                .map((item) => GButton(
                      icon: _selectedIndex == _menuItems.indexOf(item)
                          ? item["iconSelected"]
                          : item["icon"],
                      text: item["label"],
                    ))
                .toList(),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Scaffold _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Animated sidebar
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final width =
                  Tween<double>(begin: 80.0, end: 280.0).evaluate(_animation);
              return Container(
                width: width,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: MedColors.primary, // Keep the green color
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16), // Reduced top padding
                    // App Logo and title - kept mostly the same
                    Row(
                      mainAxisAlignment: _isExpanded
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: _isExpanded ? 16 : 12), // Smaller padding
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8), // Smaller radius
                          child: const Image(
                            image: AssetImage('assets/LOGO.jpg'),
                            width: 32, // Smaller logo
                            height: 32, // Smaller logo
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(width: 12), // Smaller spacing
                          const Text(
                            'CLIMA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18, // Smaller font
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24), // Reduced spacing

                    // Navigation menu - main area to modify
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: _isExpanded ? 12 : 8,
                            vertical: 4), // Smaller padding
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          final isSelected = _selectedIndex == index;
                          final isHovered = _hoveredIndex == index;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2), // Reduced padding
                            child: MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _hoveredIndex = index),
                              onExit: (_) =>
                                  setState(() => _hoveredIndex = null),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? MedColors.primary.shade800
                                      : (isHovered
                                          ? MedColors.primary.shade700
                                          : Colors.transparent),
                                  borderRadius: BorderRadius.circular(
                                      8), // Smaller radius
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                        8), // Smaller radius
                                    onTap: () =>
                                        setState(() => _selectedIndex = index),
                                    splashColor: MedColors.primary.shade600,
                                    highlightColor: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10, // Reduced padding
                                        horizontal: 12, // Reduced padding
                                      ),
                                      child: Row(
                                        mainAxisAlignment: _isExpanded
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isSelected
                                                ? item["iconSelected"]
                                                : item["icon"],
                                            color: isSelected || isHovered
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.7),
                                            size: 18, // Smaller icon
                                          ),
                                          if (_isExpanded) ...[
                                            const SizedBox(
                                                width: 12), // Smaller spacing
                                            Text(
                                              item["label"],
                                              style: TextStyle(
                                                fontSize: 14, // Smaller font
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                color: isSelected || isHovered
                                                    ? Colors.white
                                                    : Colors.white
                                                        .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                          if (isSelected && _isExpanded) ...[
                                            const Spacer(),
                                            Container(
                                              width: 4, // Smaller indicator
                                              height: 4, // Smaller indicator
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Setting & Logout buttons at bottom
                    // Setting & Logout buttons at bottom
                    Column(
                      children: [
                        const Divider(color: Colors.white24, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              // Setting Button
                              MouseRegion(
                                onEnter: (_) => setState(
                                    () => _hoveredIndex = _menuItems.length),
                                onExit: (_) =>
                                    setState(() => _hoveredIndex = null),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _hoveredIndex == _menuItems.length
                                        ? MedColors.primary.shade700
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        // Aksi ke halaman setting
                                      },
                                      splashColor: MedColors.primary.shade600,
                                      highlightColor: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12),
                                        child: Row(
                                          mainAxisAlignment: _isExpanded
                                              ? MainAxisAlignment.start
                                              : MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.settings,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              size: 18,
                                            ),
                                            if (_isExpanded) ...[
                                              const SizedBox(width: 12),
                                              Text(
                                                'Settings',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Logout Button
                              MouseRegion(
                                onEnter: (_) => setState(() =>
                                    _hoveredIndex = _menuItems.length + 1),
                                onExit: (_) =>
                                    setState(() => _hoveredIndex = null),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _hoveredIndex ==
                                            _menuItems.length + 1
                                        ? Colors.red.shade300.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title:
                                                const Text('Konfirmasi Logout'),
                                            content: const Text(
                                                'Apakah kamu yakin ingin keluar dari akun?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text(
                                                  'Batal',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red.shade400,
                                                ),
                                                onPressed: () {
                                                  _handleLogout();
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Logout',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      splashColor: Colors.red.shade100,
                                      highlightColor: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12),
                                        child: Row(
                                          mainAxisAlignment: _isExpanded
                                              ? MainAxisAlignment.start
                                              : MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.logout,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              size: 18,
                                            ),
                                            if (_isExpanded) ...[
                                              const SizedBox(width: 12),
                                              Text(
                                                'Logout',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 1),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    // Sidebar toggle button - also needs to be smaller
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: MedColors.primary.shade700,
                          borderRadius:
                              BorderRadius.circular(6), // Smaller radius
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isExpanded
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: Colors.white,
                            size: 18, // Smaller icon
                          ),
                          onPressed: _toggleSidebar,
                          tooltip: _isExpanded ? 'Collapse' : 'Expand',
                          padding: const EdgeInsets.all(6), // Smaller padding
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              );
            },
          ),

          // Content area
          Expanded(
            child: Column(
              children: [
                // Desktop header/toolbar
                _buildHeader(),

                // Main content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    color: Colors.grey.shade50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _screens[_selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() {});

    try {
      await FirebaseAuth.instance.signOut();
      html.window.localStorage['isLoggedIn'] = '';
      html.window.localStorage['status'] = '';
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildUserProfileContainer() {
    return Row(
      children: [
        _buildUserAvatar(),
        const SizedBox(width: 12),
        Text(
          displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return Hero(
      tag: 'profile-avatar',
      child: photoURL != null
          ? CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(photoURL!),
              backgroundColor: MedColors.primary,
            )
          : CircleAvatar(
              radius: 18,
              backgroundColor: MedColors.primary,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
    );
  }

  void _showUserMenu() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 10, 0),
      items: [
        _buildMenuItem(
          value: 'profile',
          icon: Icons.person,
          text: 'Lihat Profil',
          color: MedColors.primary,
        ),
        _buildMenuItem(
          value: 'settings',
          icon: Icons.settings,
          text: 'Ganti Password',
          color: MedColors.primary,
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuSelection(value);
      }
    });
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: value == 'logout' ? Colors.redAccent : null,
            ),
          ),
        ],
      ),
    );
  }
}
