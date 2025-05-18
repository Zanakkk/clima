import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String questionText;
  final List<String> options;
  final ValueChanged<int> onOptionSelected;

  const QuestionCard({
    super.key,
    required this.questionText,
    required this.options,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(options.length, (index) {
              return ListTile(
                title: Text(options[index]),
                leading: Radio<int>(
                  value: index,
                  groupValue: null, // This would be managed in parent widget
                  onChanged: (value) {
                    if (value != null) onOptionSelected(value);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
