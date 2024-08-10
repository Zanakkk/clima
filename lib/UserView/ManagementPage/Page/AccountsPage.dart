// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('John Doe'),
              subtitle: const Text('johndoe@example.com'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Navigate to profile editing page
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Financial Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Current Balance'),
              subtitle: Text('\$2,345.67'),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Linked Accounts'),
              subtitle: const Text('2 bank accounts, 1 credit card'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to linked accounts page
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Security & Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Enabled'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Navigate to security settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Login History'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to login history page
              },
            ),
          ],
        ),
      ),
    );
  }
}

