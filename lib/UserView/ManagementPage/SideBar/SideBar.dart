// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'dart:convert';

import '../HomePage.dart';

class Sidebar extends StatefulWidget {
  final bool isExpanded;
  final Function(int) onItemSelected;
  final List<bool> pageVisibility; // Tambahkan daftar visibilitas halaman

  const Sidebar({
    super.key,
    required this.isExpanded,
    required this.onItemSelected,
    required this.pageVisibility, // Tambahkan parameter ini
  });

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedIndex = 0;
  String _clinicName = 'Loading...';
  String _clinicAddress = '';
  String _clinicLogo = '';

  @override
  void initState() {
    super.initState();
    _fetchClinicData();
  }

  Future<void> _fetchClinicData() async {
    final url = '$FULLURL/.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _clinicName = data['name'] ?? 'Unknown Clinic';
          _clinicAddress = data['address'] ?? 'Unknown Address';
          _clinicLogo = data['logo'] ?? '';
        });
      } else {
        setState(() {
          _clinicName = 'Error Loading Data';
        });
      }
    } catch (e) {
      setState(() {
        _clinicName = 'Error Loading Data';
      });
    }
  }

  void _handleItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: (_clinicLogo.isNotEmpty)
                    ? Image.network(
                        _clinicLogo,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _clinicName.isNotEmpty
                                ? _clinicName[0].toUpperCase()
                                : '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            if (widget.isExpanded) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _clinicName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (widget.isExpanded)
          ListTile(
            title: Text(
              _clinicName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _clinicAddress,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const Divider(),
        SidebarSection(
          title: 'CLINIC',
          isExpanded: widget.isExpanded,
          items: [
            if (widget.pageVisibility[0])
              SidebarItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                isExpanded: widget.isExpanded,
                isActive: _selectedIndex == 0,
                onTap: () => _handleItemSelected(0),
              ),
            if (widget.pageVisibility[1])
              SidebarItem(
                icon: Icons.event,
                label: 'Reservations',
                isExpanded: widget.isExpanded,
                isActive: _selectedIndex == 1,
                onTap: () => _handleItemSelected(1),
              ),
            if (widget.pageVisibility[2])
              SidebarItem(
                icon: Icons.people,
                label: 'Patients',
                isExpanded: widget.isExpanded,
                isActive: _selectedIndex == 2,
                onTap: () => _handleItemSelected(2),
              ),
            if (widget.pageVisibility[3])
              SidebarItem(
                icon: Icons.medical_services,
                label: 'Treatments',
                isExpanded: widget.isExpanded,
                isActive: _selectedIndex == 3,
                onTap: () => _handleItemSelected(3),
              ),
            if (widget.pageVisibility[4])
              SidebarItem(
                icon: Icons.person,
                label: 'Medical record',
                isExpanded: widget.isExpanded,
                isActive: _selectedIndex == 4,
                onTap: () => _handleItemSelected(4),
              ),
            if (widget.pageVisibility[5])
              SidebarItem(
                icon: Icons.receipt,
                label: 'Receipt',
                isExpanded: widget.isExpanded,
                isActive: _selectedIndex == 5,
                onTap: () => _handleItemSelected(5),
              ),
            SidebarItem(
              icon: Icons.admin_panel_settings,
              label: 'Management',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 6,
              onTap: () => _handleItemSelected(6),
            ),
          ],
        ),
        if (widget.pageVisibility[7] ||
            widget.pageVisibility[8] ||
            widget.pageVisibility[9] ||
            widget.pageVisibility[10])
          SidebarSection(
            title: 'PHYSICAL ASSET',
            isExpanded: widget.isExpanded,
            items: [
              if (widget.pageVisibility[7])
                SidebarItem(
                  icon: Icons.person,
                  label: 'Staff List',
                  isExpanded: widget.isExpanded,
                  isActive: _selectedIndex == 7,
                  onTap: () => _handleItemSelected(7),
                ),
              if (widget.pageVisibility[8])
                SidebarItem(
                  icon: Icons.store,
                  label: 'Stocks',
                  isExpanded: widget.isExpanded,
                  isActive: _selectedIndex == 8,
                  onTap: () => _handleItemSelected(8),
                ),
              if (widget.pageVisibility[9])
                SidebarItem(
                  icon: Icons.devices,
                  label: 'Peripherals',
                  isExpanded: widget.isExpanded,
                  isActive: _selectedIndex == 9,
                  onTap: () => _handleItemSelected(9),
                ),
              if (widget.pageVisibility[10])
                SidebarItem(
                  icon: Icons.report,
                  label: 'Absen',
                  isExpanded: widget.isExpanded,
                  isActive: _selectedIndex == 10,
                  onTap: () => _handleItemSelected(10),
                ),
            ],
          ),
        SidebarSection(
          title: 'CLIMA',
          isExpanded: widget.isExpanded,
          items: [
            if (widget.pageVisibility[11])
              SidebarItem(
                icon: Icons.support,
                label: 'Customer Support',
                isExpanded: widget.isExpanded,
                isActive: _selectedIndex == 11,
                onTap: () => _handleItemSelected(11),
              ),
            SidebarItem(
              icon: Icons.warning_amber,
              label: 'Log Out',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 12,
              onTap: () => _handleItemSelected(12),
            ),
            SidebarItem(
              icon: LineIcons.medicalClinic,
              label: 'CLIMA',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 100, // Check if 100 is selected
              onTap: () => _handleItemSelected(100), // Set selectedIndex to 100
            ),
          ],
        ),
      ],
    );
  }
}

class SidebarSection extends StatelessWidget {
  final String title;
  final List<SidebarItem> items;
  final bool isExpanded;

  const SidebarSection({
    super.key,
    required this.title,
    required this.items,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty && isExpanded)
          Text(
            title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ...items.map((item) => item),
        const SizedBox(height: 16),
      ],
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: isActive ? Colors.blue : Colors.black,
        backgroundColor: isActive ? Colors.blue[50] : Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding:
            EdgeInsets.symmetric(vertical: 12, horizontal: isExpanded ? 16 : 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: isActive ? Colors.blue : Colors.grey),
          if (isExpanded) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.blue : Colors.black,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
