import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  String _userType = 'patient';

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _userType = userData['userType'] ?? 'patient';
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _navigateToDashboard() {
    if (_userType == 'doctor') {
      Navigator.pushReplacementNamed(context, '/doctor-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/patient-dashboard');
    }
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userName =
        user?.displayName ?? user?.email?.split('@').first ?? "User";

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/tabib_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome,",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _loading
                            ? const SizedBox()
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _userType == 'doctor'
                                      ? Colors.green
                                      : Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _userType == 'doctor'
                                      ? '👨‍⚕️ Doctor'
                                      : '👤 Patient',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.person, color: Colors.blue),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/profile'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Main Action Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.medical_services,
                          size: 64,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'TABIB Medical Consultation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userType == 'doctor'
                              ? 'Manage your consultations and help patients'
                              : 'Get AI diagnosis and consult with doctors',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _navigateToDashboard,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _userType == 'doctor'
                                  ? Colors.green
                                  : Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _userType == 'doctor'
                                  ? 'Go to Doctor Dashboard'
                                  : 'Go to Patient Dashboard',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Quick Actions based on user type
                _userType == 'doctor'
                    ? _buildDoctorQuickActions()
                    : _buildPatientQuickActions(),

                const SizedBox(height: 30),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Doctor Quick Access",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _buildQuickActionCard(
              'Consultations',
              Icons.medical_services,
              Colors.blue,
              () => Navigator.pushNamed(context, '/doctor-consultations'),
            ),
            _buildQuickActionCard(
              'Chat',
              Icons.chat,
              Colors.green,
              () => Navigator.pushNamed(
                context,
                '/doctor-chat',
                arguments: {
                  'consultationId': 'sample-id',
                  'patientName': 'Patient',
                },
              ),
            ),
            _buildQuickActionCard(
              'Profile',
              Icons.person,
              Colors.orange,
              () => Navigator.pushNamed(context, '/profile'),
            ),
            _buildQuickActionCard(
              'AI Review',
              Icons.psychology,
              Colors.purple,
              () => Navigator.pushNamed(context, '/ai-diagnosis'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Patient Quick Access",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _buildQuickActionCard(
              'AI Diagnosis',
              Icons.psychology,
              Colors.purple,
              () => Navigator.pushNamed(context, '/ai-diagnosis'),
            ),
            _buildQuickActionCard(
              'My Consultations',
              Icons.medical_services,
              Colors.blue,
              () => Navigator.pushNamed(context, '/patient-consultations'),
            ),
            _buildQuickActionCard(
              'Chat',
              Icons.chat,
              Colors.green,
              () => Navigator.pushNamed(
                context,
                '/patient-chat',
                arguments: {
                  'consultationId': 'sample-id',
                  'doctorName': 'Doctor',
                },
              ),
            ),
            _buildQuickActionCard(
              'Profile',
              Icons.person,
              Colors.orange,
              () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      color: Colors.white.withOpacity(0.9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
