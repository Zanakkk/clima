class Appointment {
  final String id;
  final String patientName;
  final String complaint;
  final DateTime date;
  final String timeSlot;
  final bool isConfirmed;

  Appointment({
    required this.id,
    required this.patientName,
    required this.complaint,
    required this.date,
    required this.timeSlot,
    this.isConfirmed = false,
  });

  // Konversi dari JSON untuk digunakan ketika mengambil data dari Firebase/database
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientName: json['patientName'],
      complaint: json['complaint'],
      date: DateTime.parse(json['date']),
      timeSlot: json['timeSlot'],
      isConfirmed: json['isConfirmed'] ?? false,
    );
  }

  // Konversi ke JSON untuk dikirim ke Firebase/database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'complaint': complaint,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'isConfirmed': isConfirmed,
    };
  }
}