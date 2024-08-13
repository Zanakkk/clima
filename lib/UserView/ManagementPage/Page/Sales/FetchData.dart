import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../HomePage.dart';
import 'Model.dart';

Future<Map<String, Treatment>> fetchTreatments() async {
  final response = await http.get(Uri.parse('$FULLURL/tindakan.json'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data.map((key, value) => MapEntry(key, Treatment.fromJson(value)));
  } else {
    throw Exception('Failed to load treatments');
  }
}

Future<Map<String, Patient>> fetchPatients() async {
  final response = await http.get(Uri.parse('$FULLURL/datapasien.json'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data.map((key, value) => MapEntry(key, Patient.fromJson(value)));
  } else {
    throw Exception('Failed to load patients');
  }
}
