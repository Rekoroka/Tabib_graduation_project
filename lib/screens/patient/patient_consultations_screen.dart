// lib/screens/patient/patient_consultations_screen.dart
import 'package:flutter/material.dart';

class PatientConsultationsScreen extends StatefulWidget {
  const PatientConsultationsScreen({super.key});

  @override
  State<PatientConsultationsScreen> createState() =>
      _PatientConsultationsScreenState();
}

class _PatientConsultationsScreenState extends State<PatientConsultationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Consultations'),
        backgroundColor: Colors.blue[700],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Active (2)'),
            Tab(text: 'Pending (1)'),
            Tab(text: 'Completed (5)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsultationsList('active'),
          _buildConsultationsList('pending'),
          _buildConsultationsList('completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConsultation,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildConsultationsList(String status) {
    // Sample data
    final List<Map<String, dynamic>> consultations = [
      {
        'id': '1',
        'doctorName': 'Dr. Ahmed Ali',
        'symptoms': 'Skin Rash, Itching',
        'date': 'Today, 10:00 AM',
        'status': 'active',
        'aiDiagnosis': 'Contact Dermatitis',
        'doctorDiagnosis': 'Under review',
      },
      {
        'id': '2',
        'doctorName': 'Dr. Sarah Mohamed',
        'symptoms': 'Fever, Headache',
        'date': 'Yesterday, 3:30 PM',
        'status': 'pending',
        'aiDiagnosis': 'Possible Viral Infection',
        'doctorDiagnosis': 'Waiting for doctor',
      },
      {
        'id': '3',
        'doctorName': 'Dr. Michael Johnson',
        'symptoms': 'Back Pain',
        'date': 'Jan 15, 2024',
        'status': 'completed',
        'aiDiagnosis': 'Muscle Strain',
        'doctorDiagnosis': 'Confirmed muscle strain',
      },
    ];

    final filteredConsultations = consultations
        .where((c) => c['status'] == status)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredConsultations.length,
      itemBuilder: (context, index) {
        final consultation = filteredConsultations[index];
        return _buildConsultationCard(consultation);
      },
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  consultation['doctorName'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(consultation['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    consultation['status'].toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Symptoms: ${consultation['symptoms']}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              consultation['date'],
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            // AI Diagnosis Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, size: 16, color: Colors.purple),
                      SizedBox(width: 4),
                      Text(
                        'AI Diagnosis',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(consultation['aiDiagnosis']),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Doctor Diagnosis Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 16,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Doctor Diagnosis',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(consultation['doctorDiagnosis']),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewConsultationDetails(consultation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                if (consultation['status'] == 'active' ||
                    consultation['status'] == 'pending')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _chatWithDoctor(consultation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                      ),
                      child: const Text('Chat Now'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _viewConsultationDetails(Map<String, dynamic> consultation) {
    Navigator.pushNamed(
      context,
      '/consultation-detail',
      arguments: {
        'consultationId': consultation['id'],
        'patientName': consultation['doctorName'],
      },
    );
  }

  void _chatWithDoctor(Map<String, dynamic> consultation) {
    Navigator.pushNamed(
      context,
      '/patient-chat',
      arguments: {
        'consultationId': consultation['id'],
        'doctorName': consultation['doctorName'],
      },
    );
  }

  void _startNewConsultation() {
    Navigator.pushNamed(context, '/ai-diagnosis');
  }
}
