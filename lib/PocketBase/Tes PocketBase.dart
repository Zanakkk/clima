import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final pb = PocketBase('https://pockethosttesting.pockethost.io');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  // Authenticate the user with PocketBase
  Future<void> authenticateUser(String email, String password) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Authenticate using pb.users.authWithPassword (correct method)
      final authData =
          await pb.collection('users').authWithPassword(email, password);

      print(pb.authStore.isValid); // Check if authentication is valid
      print(pb.authStore.token); // Print the token
      print(pb.authStore.model.id); // Print user ID
      print('User authenticated successfully');

      // Navigate to KlinikPage after successful authentication
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                KlinikPage(pb: pb)), // Pass the PocketBase instance
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Authentication failed: $e';
      });

      print(email);
      print(password);
      print('Authentication failed: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login to PocketBase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      final email = emailController.text;
                      final password = passwordController.text;
                      authenticateUser(email, password);
                    },
                    child: Text('Login'),
                  ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class KlinikPage extends StatefulWidget {
  final PocketBase pb; // Accept PocketBase instance from LoginPage

  KlinikPage({required this.pb});

  @override
  _KlinikPageState createState() => _KlinikPageState();
}

class _KlinikPageState extends State<KlinikPage> {
  List<RecordModel> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    try {
      // Fetch all records without filter
      final resultList = await widget.pb.collection('klinik').getList(
            page: 1,
            perPage: 50, // Adjust perPage based on your need
          );
      setState(() {
        records = resultList.items;
        isLoading = false;
      });
      print(records);
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Klinik Data'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  // Access the fields using 'record.data'
                  title: Text(record.data['name'] ?? 'No Name'),
                  subtitle: Text(record.data['address'] ?? 'No Address'),
                  trailing: Text(record.data['created'] ?? 'No Date'),
                );
              },
            ),
    );
  }
}
