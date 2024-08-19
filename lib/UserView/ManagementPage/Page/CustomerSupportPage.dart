// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomerSupportPage extends StatefulWidget {
  const CustomerSupportPage({super.key});

  @override
  _CustomerSupportPageState createState() => _CustomerSupportPageState();
}

class _CustomerSupportPageState extends State<CustomerSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedIssueType;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Simulate sending the message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent!')),
      );

      // Clear the form
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      setState(() {
        _selectedIssueType = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Support'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.blue[50],
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('How can we help you?'),
              const SizedBox(height: 10),
              _buildFAQSection(),
              const SizedBox(height: 20),
              _buildSectionTitle('Contact Us'),
              const SizedBox(height: 10),
              _buildContactForm(),
              const SizedBox(height: 20),
              _buildSectionTitle('Our Contact Information'),
              const SizedBox(height: 10),
              _buildContactDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildFAQSection() {
    return const Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: ExpansionTile(
          title: Text('Frequently Asked Questions (FAQ)'),
          children: [
            ListTile(
              title: Text('How do I reset my password?'),
              subtitle: Text(
                  'You can reset your password by going to the Settings page and selecting "Forgot Password".'),
            ),
            ListTile(
              title: Text('How do I update my profile information?'),
              subtitle: Text(
                  'You can update your profile information from the Profile page in the app.'),
            ),
            ListTile(
              title: Text('What should I do if I find a bug?'),
              subtitle: Text(
                  'If you find a bug, please report it to us using the contact form below.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIssueType,
                decoration: const InputDecoration(labelText: 'Issue Type'),
                items: ['Technical Issue', 'Billing Issue', 'General Inquiry']
                    .map((issue) => DropdownMenuItem<String>(
                          value: issue,
                          child: Text(issue),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIssueType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select an issue type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Send Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactDetails() {
    return const Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blue),
              title: Text('Phone'),
              subtitle: Text('+1 800 123 4567'),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text('Email'),
              subtitle: Text('support@example.com'),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.blue),
              title: Text('Address'),
              subtitle: Text('123 Support Street, Help City, USA'),
            ),
          ],
        ),
      ),
    );
  }
}
