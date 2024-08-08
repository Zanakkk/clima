// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:clima/Model/UserModel.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  _UsersManagementPageState createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  List<User> users = [
    User(id: '1', name: 'John Doe', email: 'john@example.com', role: 'Admin'),
    User(
        id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'Doctor'),
  ];

  Future<void> _addUser(User user) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      users.add(user);
    });
  }

  Future<void> _editUser(User user) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      int index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = user;
      }
    });
  }

  Future<void> _deleteUser(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      users.removeWhere((user) => user.id == id);
    });
  }

  void _showUserDialog({User? user}) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final roleController = TextEditingController(text: user?.role ?? '');
    final isEditing = user != null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit User' : 'Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isEditing) {
                  await _editUser(User(
                    id: user.id,
                    name: nameController.text,
                    email: emailController.text,
                    role: roleController.text,
                  ));
                } else {
                  await _addUser(User(
                    id: Random().nextInt(1000).toString(),
                    name: nameController.text,
                    email: emailController.text,
                    role: roleController.text,
                  ));
                }
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
      ),
      body: SizedBox(
          width: MediaQuery.of(context).size.width - 200,
          child: Column(
            children: [
              ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showUserDialog(user: user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteUser(user.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
