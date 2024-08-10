// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';

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
            const Icon(Icons.local_hospital, size: 36, color: Colors.blue),
            if (widget.isExpanded) ...[
              const SizedBox(width: 8),
              const Text('Zendenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (widget.isExpanded)
          const ListTile(
            title: Text('Avicena Clinic',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('845 Euclid Avenue, CA'),
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
              label: 'Staff List',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 4,
              onTap: () => _handleItemSelected(4),
            ),
          ],
        ),
        SidebarSection(
          title: 'FINANCE',
          isExpanded: widget.isExpanded,
          items: [
            SidebarItem(
              icon: Icons.account_balance,
              label: 'Accounts',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 5,
              onTap: () => _handleItemSelected(5),
            ),
            SidebarItem(
              icon: Icons.monetization_on,
              label: 'Sales',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 6,
              onTap: () => _handleItemSelected(6),
            ),
            SidebarItem(
              icon: Icons.shopping_cart,
              label: 'Purchases',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 7,
              onTap: () => _handleItemSelected(7),
            ),
            SidebarItem(
              icon: Icons.payment,
              label: 'Payment Method',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 8,
              onTap: () => _handleItemSelected(8),
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
              isActive: _selectedIndex == 9,
              onTap: () => _handleItemSelected(9),
            ),
            SidebarItem(
              icon: Icons.devices,
              label: 'Peripherals',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 10,
              onTap: () => _handleItemSelected(10),
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
              isActive: _selectedIndex == 11,
              onTap: () => _handleItemSelected(11),
            ),
            SidebarItem(
              icon: Icons.support,
              label: 'Customer Support',
              isExpanded: widget.isExpanded,
              isActive: _selectedIndex == 12,
              onTap: () => _handleItemSelected(12),
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
