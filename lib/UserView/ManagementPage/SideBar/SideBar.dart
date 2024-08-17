// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../HomePage.dart';

class Sidebar extends StatefulWidget {
  final bool isExpanded;
  final Function(int) onItemSelected;

  const Sidebar(
      {super.key, required this.isExpanded, required this.onItemSelected});

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
          _clinicName = data['name'];
          _clinicAddress = data['address'];
          _clinicLogo = data['logo'];
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
                borderRadius: BorderRadius.circular(
                    18), // Half of the width/height to make it circular
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(18), // Make sure it's circular
                child: (_clinicLogo.isNotEmpty)
                    ? Image.network(
                        _clinicLogo,
                        width: 32,
                        height: 32,
                        fit:
                            BoxFit.cover, // Cover the entire area of the circle
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
                              color: Colors.blue, // Color of the initial
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            if (widget.isExpanded) ...[
              const SizedBox(width: 8),
              Expanded(
                // Ensures the text wraps or fits within the available space
                child: Text(
                  _clinicName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
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
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
            subtitle: Text(
              _clinicAddress,
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
          ),
        const Divider(),
        SidebarSection(
          title: 'CLINIC',
          isExpanded: widget.isExpanded,
          items: [
            SidebarItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 0,
              onTap: () => _handleItemSelected(0),
            ),
            SidebarItem(
              icon: Icons.event,
              label: 'Reservations',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 1,
              onTap: () => _handleItemSelected(1),
            ),
            SidebarItem(
              icon: Icons.people,
              label: 'Patients',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 2,
              onTap: () => _handleItemSelected(2),
            ),
            SidebarItem(
              icon: Icons.medical_services,
              label: 'Treatments',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 3,
              onTap: () => _handleItemSelected(3),
            ),
            SidebarItem(
              icon: Icons.person,
              label: 'Medical record',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 16,
              onTap: () => _handleItemSelected(16),
            ),
            SidebarItem(
              icon: Icons.person,
              label: 'Staff List',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 4,
              onTap: () => _handleItemSelected(4),
            ),
            SidebarItem(
              icon: Icons.person,
              label: 'Management',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 15,
              onTap: () => _handleItemSelected(15),
            ),
          ],
        ),
        SidebarSection(
          title: 'PHYSICAL ASSET',
          isExpanded: widget.isExpanded,
          items: [
            SidebarItem(
              icon: Icons.store,
              label: 'Stocks',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 10,
              onTap: () => _handleItemSelected(10),
            ),
            SidebarItem(
              icon: Icons.devices,
              label: 'Peripherals',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 11,
              onTap: () => _handleItemSelected(11),
            ),
          ],
        ),
        SidebarSection(
          title: '',
          isExpanded: widget.isExpanded,
          items: [
            SidebarItem(
              icon: Icons.report,
              label: 'Report',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 12,
              onTap: () => _handleItemSelected(12),
            ),
            SidebarItem(
              icon: Icons.support,
              label: 'Customer Support',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 13,
              onTap: () => _handleItemSelected(13),
            ),
            SidebarItem(
              icon: Icons.warning_amber,
              label: 'Log Out',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 14,
              onTap: () => _handleItemSelected(14),
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

  const SidebarSection(
      {super.key,
      required this.title,
      required this.items,
      required this.isExpanded});

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

  const SidebarItem(
      {super.key,
      required this.icon,
      required this.label,
      this.isActive = false,
      required this.isExpanded,
      required this.onTap});

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
