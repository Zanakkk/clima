import 'package:flutter/material.dart';

class DiscussionTile extends StatelessWidget {
  final String username;
  final String comment;
  final DateTime datePosted;

  const DiscussionTile({
    super.key,
    required this.username,
    required this.comment,
    required this.datePosted,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(username[0]), // Display the first letter of the username
      ),
      title: Text(username),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment),
          const SizedBox(height: 4),
          Text(
            '${datePosted.day}/${datePosted.month}/${datePosted.year}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
