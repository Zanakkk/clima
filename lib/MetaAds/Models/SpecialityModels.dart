// lib/models/specialty_model.dart
class SpecialtyModel {
  final String type;
  final List<String> services;
  final String primaryFocus;

  SpecialtyModel({
    required this.type,
    required this.services,
    required this.primaryFocus,
  });

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      type: json['type'] ?? 'general',
      services: List<String>.from(json['services'] ?? []),
      primaryFocus: json['primary_focus'] ?? 'general_health',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'services': services,
      'primary_focus': primaryFocus,
    };
  }

  // Predefined specialties
  static SpecialtyModel get generalClinic => SpecialtyModel(
        type: 'general',
        services: [
          'general_checkup',
          'consultation',
          'vaccination',
          'health_screening',
          'medical_certificate'
        ],
        primaryFocus: 'general_health',
      );

  static SpecialtyModel get dentalClinic => SpecialtyModel(
        type: 'dental',
        services: [
          'general_checkup',
          'dental_cleaning',
          'scaling',
          'tooth_extraction',
          'dental_filling',
          'root_canal',
          'dental_implant',
          'orthodontics',
          'pediatric_dentistry',
          'cosmetic_dentistry'
        ],
        primaryFocus: 'dental_care',
      );
}
