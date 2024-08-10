// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'ManagementPage/UserManagementPage.dart';
import 'RekamMedis/rekammedis.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic Management Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    const DaftarPasienPage(),
    const DaftarTindakanPage(),
    const UsersManagementPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(onItemTapped: _onItemTapped),
          Expanded(
            child: _pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  final Function(int) onItemTapped;

  const NavigationDrawer({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(
            height: 120,
          ),
          DrawerItem(
            title: 'Daftar Pasien',
            index: 0,
            onTap: onItemTapped,
          ),
          DrawerItem(
            title: 'Daftar Tindakan',
            index: 1,
            onTap: onItemTapped,
          ),
          const Divider(),
          DrawerItem(
            title: 'User Management',
            index: 2,
            onTap: onItemTapped,
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final int index;
  final Function(int) onTap;

  const DrawerItem({
    super.key,
    required this.title,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        onTap(index);
      },
    );
  }
}

class DaftarPasienPage extends StatelessWidget {
  const DaftarPasienPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('ini 0'),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RekamMedis(),
              ),
            );
          },
          child: const Text('Daftar Pasien'),
        ),
      ],
    );
  }
}

class DaftarTindakanPage extends StatelessWidget {
  const DaftarTindakanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('ini 1'),
      ],
    );
  }
}
