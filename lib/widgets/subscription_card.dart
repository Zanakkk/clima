import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final String planName;
  final double price;
  final String description;
  final VoidCallback onSubscribe;

  const SubscriptionCard({
    super.key,
    required this.planName,
    required this.price,
    required this.description,
    required this.onSubscribe,
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
              planName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$$price/month',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onSubscribe,
                child: const Text('Subscribe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
