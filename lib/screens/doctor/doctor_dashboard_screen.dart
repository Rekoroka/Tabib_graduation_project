// lib/screens/doctor/doctor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: Colors.green[700],
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final bool isVerified = userData['isVerified'] ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                _buildWelcomeCard(userData, isVerified),
                const SizedBox(height: 20),

                // Quick Stats
                _buildStatsSection(),
                const SizedBox(height: 20),

                // Pending Consultations
                _buildPendingConsultations(),
                const SizedBox(height: 20),

                // Quick Actions
                _buildQuickActions(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeCard(Map<String, dynamic> userData, bool isVerified) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green[100],
              child: Icon(
                Icons.medical_services,
                size: 30,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${userData['name']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userData['specialization'] ?? 'General Practitioner',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  if (!isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        '⏳ Pending Verification',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
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
                        '✅ Verified Doctor',
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

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Overview",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildStatCard('Pending', '5', Colors.orange)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard('Completed', '12', Colors.green)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard('Total', '17', Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingConsultations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Consultations',
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
                  'Ahmed Mohamed',
                  'Fever & Headache',
                  '09:30 AM',
                ),
                const Divider(),
                _buildConsultationItem('Sarah Ali', 'Skin Rash', '10:15 AM'),
                const Divider(),
                _buildConsultationItem(
                  'Mohamed Hassan',
                  'Back Pain',
                  '11:00 AM',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationItem(
    String patientName,
    String symptoms,
    String time,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: const Icon(Icons.person, color: Colors.blue),
      ),
      title: Text(
        patientName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(symptoms),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(fontSize: 10, color: Colors.orange),
            ),
          ),
        ],
      ),
      onTap: () {
        _viewConsultationDetails(patientName);
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
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
              'My Consultations',
              Icons.medical_services,
              Colors.blue,
              _navigateToConsultations,
            ),
            _buildActionCard(
              'Chat with Patients',
              Icons.chat_bubble_outline,
              Colors.green,
              _navigateToChat,
            ),
            _buildActionCard(
              'AI Diagnosis Review',
              Icons.psychology_outlined,
              Colors.purple,
              _navigateToAIDiagnosis,
            ),
            _buildActionCard(
              'My Schedule',
              Icons.calendar_today,
              Colors.orange,
              _navigateToSchedule,
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

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green[700],
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
  void _navigateToConsultations() {
    // TODO: Navigate to consultations list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to Consultations')),
    );
  }

  void _navigateToChat() {
    // TODO: Navigate to chat list
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Chat')));
  }

  void _navigateToAIDiagnosis() {
    // TODO: Navigate to AI diagnosis review
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to AI Diagnosis Review')),
    );
  }

  void _navigateToSchedule() {
    // TODO: Navigate to schedule
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Schedule')));
  }

  void _navigateToProfile() {
    // TODO: Navigate to doctor profile
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigating to Profile')));
  }

  void _showNotifications() {
    // TODO: Show notifications
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Showing Notifications')));
  }

  void _viewConsultationDetails(String patientName) {
    // TODO: View consultation details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing consultation with $patientName')),
    );
  }
}
