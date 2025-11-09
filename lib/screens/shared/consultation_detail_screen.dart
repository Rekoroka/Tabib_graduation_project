// lib/screens/shared/consultation_detail_screen.dart
import 'package:flutter/material.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final String consultationId;
  final String patientName;

  const ConsultationDetailScreen({
    super.key,
    required this.consultationId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultation Details - $patientName'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Name: $patientName'),
                    Text('Consultation ID: $consultationId'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Add more consultation details here
          ],
        ),
      ),
    );
  }
}
