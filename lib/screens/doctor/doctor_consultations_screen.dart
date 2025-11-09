// lib/screens/doctor/doctor_consultations_screen.dart
import 'package:flutter/material.dart';

class DoctorConsultationsScreen extends StatefulWidget {
  const DoctorConsultationsScreen({super.key});

  @override
  State<DoctorConsultationsScreen> createState() =>
      _DoctorConsultationsScreenState();
}

class _DoctorConsultationsScreenState extends State<DoctorConsultationsScreen>
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
        backgroundColor: Colors.green[700],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Pending (5)'),
            Tab(text: 'Active (3)'),
            Tab(text: 'Completed (12)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsultationsList('pending'),
          _buildConsultationsList('active'),
          _buildConsultationsList('completed'),
        ],
      ),
    );
  }

  Widget _buildConsultationsList(String status) {
    // Sample data - replace with actual data from backend
    final List<Map<String, dynamic>> consultations = [
      {
        'id': '1',
        'patientName': 'Ahmed Mohamed',
        'symptoms': 'Fever, Headache, Fatigue',
        'time': 'Today, 09:30 AM',
        'status': 'pending',
        'aiDiagnosis': 'Possible Viral Infection',
        'confidence': 85,
      },
      {
        'id': '2',
        'patientName': 'Sarah Ali',
        'symptoms': 'Skin Rash, Itching',
        'time': 'Today, 10:15 AM',
        'status': 'pending',
        'aiDiagnosis': 'Contact Dermatitis',
        'confidence': 78,
      },
      {
        'id': '3',
        'patientName': 'Mohamed Hassan',
        'symptoms': 'Back Pain, Limited Mobility',
        'time': 'Today, 11:00 AM',
        'status': 'pending',
        'aiDiagnosis': 'Muscle Strain',
        'confidence': 92,
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
                  consultation['patientName'],
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
              consultation['symptoms'],
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              consultation['time'],
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            // AI Diagnosis Section
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
                      Icon(Icons.psychology, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        'AI Diagnosis',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    consultation['aiDiagnosis'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${consultation['confidence']}% confidence',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _startChat(consultation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                    child: const Text('Start Chat'),
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
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _viewConsultationDetails(Map<String, dynamic> consultation) {
    // TODO: Navigate to consultation details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${consultation['patientName']}'),
      ),
    );
  }

  void _startChat(Map<String, dynamic> consultation) {
    // TODO: Navigate to chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting chat with ${consultation['patientName']}'),
      ),
    );
  }
}
