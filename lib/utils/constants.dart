import 'package:flutter/material.dart';

class Constants {
  // Firestore Collection Names
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String resultsCollection = 'results';
  static const String subscriptionsCollection = 'subscriptions';

  // App Colors
  static const Color primaryColor = Color(0xFF6200EE); // Ungu
  static const Color secondaryColor = Color(0xFF03DAC6); // Teal
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color textColor = Color(0xFF000000); // Black

  // Other Constants
  static const double defaultPadding = 16.0;
  static const Duration tryoutDuration =
      Duration(minutes: 90); // 90 minutes for a tryout
  static const String dateFormat = 'dd MMM yyyy'; // Format for date display
}

List<String> examtag = [
  'pcpm',
  'cpns',
];
