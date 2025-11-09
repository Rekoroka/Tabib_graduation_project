// lib/screens/patient/patient_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (user == null) {
        setState(() {
          _error = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (mounted) {
        if (doc.exists) {
          setState(() {
            _userData = doc.data()!;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'User data not found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your dashboard...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          _buildWelcomeCard(),
          const SizedBox(height: 20),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 20),

          // Recent Consultations
          _buildRecentConsultations(),
          const SizedBox(height: 20),

          // Health Tips
          _buildHealthTips(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, size: 30, color: Colors.blue[700]),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_userData?['name'] ?? 'Patient'}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'How are you feeling today?',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      '✅ Active Patient',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _buildActionCard(
              'AI Diagnosis',
              Icons.psychology_outlined,
              Colors.purple,
              _navigateToAIDiagnosis,
            ),
            _buildActionCard(
              'My Consultations',
              Icons.medical_services,
              Colors.blue,
              _navigateToConsultations,
            ),
            _buildActionCard(
              'Chat with Doctors',
              Icons.chat_bubble_outline,
              Colors.green,
              _navigateToChat,
            ),
            _buildActionCard(
              'Upload Documents',
              Icons.upload_file,
              Colors.orange,
              _navigateToFileUpload,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentConsultations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Consultations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'View All',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildConsultationItem(
                  'Dr. Ahmed Ali',
                  'Skin Rash',
                  'Yesterday',
                  'completed',
                ),
                const Divider(),
                _buildConsultationItem(
                  'Dr. Sarah Mohamed',
                  'Fever & Cough',
                  '2 days ago',
                  'active',
                ),
                const Divider(),
                _buildConsultationItem(
                  'Dr. Michael Johnson',
                  'Back Pain',
                  '1 week ago',
                  'completed',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationItem(
    String doctorName,
    String symptoms,
    String time,
    String status,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: const Icon(Icons.medical_services, color: Colors.blue),
      ),
      title: Text(
        doctorName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(symptoms),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      ),
      onTap: () => _viewConsultationDetails(doctorName),
    );
  }

  Widget _buildHealthTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Tips',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.water_drop, color: Colors.blue),
                  title: Text('Stay Hydrated'),
                  subtitle: Text('Drink at least 8 glasses of water daily'),
                ),
                ListTile(
                  leading: Icon(Icons.fitness_center, color: Colors.green),
                  title: Text('Regular Exercise'),
                  subtitle: Text('30 minutes of moderate activity daily'),
                ),
                ListTile(
                  leading: Icon(Icons.bedtime, color: Colors.purple),
                  title: Text('Adequate Sleep'),
                  subtitle: Text('7-9 hours of quality sleep per night'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[700],
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: 'Consultations',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  // Navigation Methods
  void _navigateToAIDiagnosis() {
    Navigator.pushNamed(context, '/ai-diagnosis');
  }

  void _navigateToConsultations() {
    Navigator.pushNamed(context, '/patient-consultations');
  }

  void _navigateToChat() {
    Navigator.pushNamed(
      context,
      '/patient-chat',
      arguments: {
        'consultationId': 'sample-consultation-id',
        'doctorName': 'Dr. Ahmed Ali',
      },
    );
  }

  void _navigateToFileUpload() {
    Navigator.pushNamed(
      context,
      '/file-upload',
      arguments: {'consultationId': 'sample-consultation-id'},
    );
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _showNotifications() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No new notifications')));
  }

  void _viewConsultationDetails(String doctorName) {
    Navigator.pushNamed(
      context,
      '/consultation-detail',
      arguments: {'consultationId': 'sample-id', 'doctorName': doctorName},
    );
  }
}
