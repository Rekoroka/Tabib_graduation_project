import 'package:cloud_firestore/cloud_firestore.dart';

class Consultation {
  final String id;
  final String patientName;
  final String aiDiagnosis;
  final String status;
  final DateTime? createdAt;

  Consultation({
    required this.id,
    required this.patientName,
    required this.aiDiagnosis,
    required this.status,
    this.createdAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] ?? '',
      patientName: json['patientName'] ?? 'Patient',
      aiDiagnosis: json['aiDiagnosis'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
