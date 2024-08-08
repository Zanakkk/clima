// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

import 'odontogram/odontogram.dart';

class PatientDetailPage extends StatefulWidget {
  const PatientDetailPage({super.key});

  @override
  _PatientDetailPageState createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  bool isExpanded = true;

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isExpanded ? 250 : 72,
            color: Colors.white,
            child: Column(
              children: [
                IconButton(
                  icon:
                      Icon(isExpanded ? Icons.arrow_back : Icons.arrow_forward),
                  onPressed: toggleSidebar,
                ),
                Expanded(child: Sidebar(isExpanded: isExpanded)),
              ],
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Breadcrumb(),
                  SizedBox(height: 16),
                  Header(),
                  SizedBox(height: 16),
                  Expanded(
                    child: PatientInfo(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final bool isExpanded;

  const Sidebar({super.key, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Icon(Icons.local_hospital, size: 36, color: Colors.blue),
            if (isExpanded) ...[
              const SizedBox(width: 8),
              const Text('Zendenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (isExpanded)
          const ListTile(
            title: Text('Avicena Clinic',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('845 Euclid Avenue, CA'),
          ),
        const Divider(),
        SidebarSection(
          title: 'CLINIC',
          isExpanded: isExpanded,
          items: [
            SidebarItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                isExpanded: isExpanded),
            SidebarItem(
                icon: Icons.event,
                label: 'Reservations',
                isExpanded: isExpanded),
            SidebarItem(
                icon: Icons.people,
                label: 'Patients',
                isExpanded: isExpanded,
                isActive: true),
            SidebarItem(
                icon: Icons.medical_services,
                label: 'Treatments',
                isExpanded: isExpanded),
            SidebarItem(
                icon: Icons.person,
                label: 'Staff List',
                isExpanded: isExpanded),
          ],
        ),
        SidebarSection(
          title: 'FINANCE',
          isExpanded: isExpanded,
          items: [
            SidebarItem(
                icon: Icons.account_balance,
                label: 'Accounts',
                isExpanded: isExpanded),
            SidebarItem(
                icon: Icons.monetization_on,
                label: 'Sales',
                isExpanded: isExpanded),
            SidebarItem(
                icon: Icons.shopping_cart,
                label: 'Purchases',
                isExpanded: isExpanded),
            SidebarItem(
                icon: Icons.payment,
                label: 'Payment Method',
                isExpanded: isExpanded),
          ],
        ),
        SidebarSection(
          title: 'PHYSICAL ASSET',
          isExpanded: isExpanded,
          items: [
            SidebarItem(
                icon: Icons.store, label: 'Stocks', isExpanded: isExpanded),
            SidebarItem(
                icon: Icons.devices,
                label: 'Peripherals',
                isExpanded: isExpanded),
          ],
        ),
        SidebarSection(
          title: '',
          isExpanded: isExpanded,
          items: [
            SidebarItem(
                icon: Icons.report, label: 'Report', isExpanded: isExpanded),
            SidebarItem(
                icon: Icons.support,
                label: 'Customer Support',
                isExpanded: isExpanded),
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

  const SidebarItem(
      {super.key,
      required this.icon,
      required this.label,
      this.isActive = false,
      required this.isExpanded});

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
      onPressed: () {},
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

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Patient List > Patient Detail',
      style: TextStyle(color: Colors.grey),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Patient',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Create Appointment'),
        ),
      ],
    );
  }
}

class PatientInfo extends StatelessWidget {
  const PatientInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Willie Jennie',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Have uneven jawline',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Patient Information'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Appointment History'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Medical Record'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            OutlinedButton(
              onPressed: () {},
              child: const Text('Medical'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Cosmetic'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Odontogram',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      // Add Odontogram content here
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  const HomePage()));
                          },
                          child: const Text('odontogram'))
                    ],
                  ),
                ),
              ),
              Card(
                color: Colors.grey[100],
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Maxillary Left Lateral Incisor',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      MedicalRecordItem(
                          date: 'May 03',
                          condition: 'Caries',
                          treatment: 'Tooth filling',
                          status: 'Done'),
                      SizedBox(height: 8),
                      MedicalRecordItem(
                          date: 'April 12',
                          condition: 'Caries',
                          treatment: 'Tooth filling',
                          status: 'Pending',
                          reason: 'Not enough time'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MedicalRecordItem extends StatelessWidget {
  final String date;
  final String condition;
  final String treatment;
  final String status;
  final String? reason;

  const MedicalRecordItem(
      {super.key,
      required this.date,
      required this.condition,
      required this.treatment,
      required this.status,
      this.reason});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date, style: const TextStyle(color: Colors.grey)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(condition,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(treatment, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Text(status,
                style: TextStyle(
                    color: status == 'Done' ? Colors.green : Colors.orange)),
          ],
        ),
        if (reason != null)
          Text('Reason: $reason', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
