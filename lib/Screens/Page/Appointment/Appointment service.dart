import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../HomePage.dart';

import 'Appointment model.dart';

class AppointmentService {
  // Method untuk mendapatkan semua janji temu
  static Future<List<Appointment>> getAppointments(String clinicId) async {
    try {
      final response = await http.get(
        Uri.parse('$FULLURL/appointments.json'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data == null || data.isEmpty) {
          return [];
        }

        List<Appointment> appointments = [];
        data.forEach((key, value) {
          value['id'] = key;
          appointments.add(Appointment.fromJson(value));
        });

        return appointments;
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Method untuk mendapatkan janji temu berdasarkan tanggal
  static Future<List<Appointment>> getAppointmentsByDate(
      String clinicId, DateTime date) async {
    try {
      // Format tanggal untuk query
      String formattedDate = date.toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse(
            '$FULLURL/appointments.json?orderBy="date"&equalTo="$formattedDate"'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data == null || data.isEmpty) {
          return [];
        }

        List<Appointment> appointments = [];
        data.forEach((key, value) {
          value['id'] = key;
          appointments.add(Appointment.fromJson(value));
        });

        return appointments;
      } else {
        throw Exception('Failed to load appointments for date $formattedDate');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Method untuk membuat janji temu baru
  static Future<Appointment> createAppointment(
      String clinicId,
      String patientName,
      String complaint,
      DateTime date,
      String timeSlot) async {
    try {
      final appointmentData = {
        'patientName': patientName,
        'complaint': complaint,
        'date': date.toIso8601String().split('T')[0],
        'timeSlot': timeSlot,
        'isConfirmed': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$FULLURL/appointments.json'),
        body: json.encode(appointmentData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Appointment(
          id: responseData['name'],
          patientName: patientName,
          complaint: complaint,
          date: date,
          timeSlot: timeSlot,
        );
      } else {
        throw Exception('Failed to create appointment');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Method untuk memperbarui status janji temu
  static Future<void> updateAppointmentStatus(
      String clinicId, String appointmentId, bool isConfirmed) async {
    try {
      final response = await http.patch(
        Uri.parse('$FULLURL/appointments/$appointmentId.json'),
        body: json.encode({'isConfirmed': isConfirmed}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update appointment status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Method untuk menghapus janji temu
  static Future<void> deleteAppointment(
      String clinicId, String appointmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$FULLURL/appointments/$appointmentId.json'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete appointment');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Method untuk mengecek ketersediaan slot waktu
  static Future<bool> isTimeSlotAvailable(
      String clinicId, DateTime date, String timeSlot) async {
    try {
      String formattedDate = date.toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse(
            '$FULLURL/appointments.json?orderBy="date"&equalTo="$formattedDate"&orderBy="timeSlot"&equalTo="$timeSlot"'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        // Jika data kosong, berarti slot waktu tersedia
        return data == null || data.isEmpty;
      } else {
        throw Exception('Failed to check time slot availability');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
