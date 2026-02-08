import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'available_requests_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  final ApiService _apiService = ApiService();

  DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("doctor_dashboard.title".tr()),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 25),

            Text(
              "doctor_dashboard.performance".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                // كرت الطلبات الجديدة - يذهب لصفحة المزايدة
                _buildStatCard(
                  context,
                  "doctor_dashboard.new_requests".tr(),
                  "pending",
                  Colors.orange,
                  Icons.notification_important,
                  onTap: () =>
                      Navigator.pushNamed(context, '/available-requests'),
                ),
                const SizedBox(width: 15),
                // كرت الحالات النشطة - يذهب لصفحة إدارة الحالات (الشات)
                _buildStatCard(
                  context,
                  "doctor_dashboard.active_cases".tr(),
                  "active",
                  Colors.green,
                  Icons.chat_bubble,
                  doctorId: uid,
                  onTap: () =>
                      Navigator.pushNamed(context, '/doctor-consultations'),
                ),
              ],
            ),
            const SizedBox(height: 25),

            Text(
              "doctor_dashboard.quick_management".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _buildMenuButton(
              context,
              "doctor_dashboard.manage_consultations".tr(),
              "doctor_dashboard.view_accept_sub".tr(),
              Icons.assignment_ind,
              Colors.blue,
              '/doctor-consultations',
            ),

            _buildMenuButton(
              context,
              "profile.title".tr(),
              "doctor_dashboard.profile_sub".tr(),
              Icons.account_circle,
              Colors.teal,
              '/profile',
            ),

            const SizedBox(height: 25),

            // --- التعديل هنا: تشغيل زر View All ليفتح صفحة إدارة الاستشارات ---
            _buildSectionTitle(
              "doctor_dashboard.history".tr(),
              () => Navigator.pushNamed(context, '/doctor-consultations'),
            ),
            const SizedBox(height: 15),
            _buildRealHistoryConsultations(uid),

            const SizedBox(height: 25),

            _buildMenuButton(
              context,
              "patient_dashboard.support".tr(),
              "doctor_dashboard.about_sub".tr(),
              Icons.info_outline,
              Colors.purple,
              '/about',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _apiService.getUserData(),
      builder: (context, snapshot) {
        String name = snapshot.hasData
            ? snapshot.data!['name']
            : "doctor_dashboard.doctor".tr();
        return Row(
          children: [
            Material(
              elevation: 3,
              shape: const CircleBorder(),
              shadowColor: Colors.black45,
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  "https://ui-avatars.com/api/?name=$name&background=2E7D32&color=fff",
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "doctor_dashboard.welcome_back".tr(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    "${"doctor_dashboard.dr".tr()} $name",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String status,
    Color color,
    IconData icon, {
    String? doctorId,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: _apiService.getConsultationsCountByStatus(
            status,
            doctorId: doctorId,
          ),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 30),
                  const SizedBox(height: 10),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRealHistoryConsultations(String doctorId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('consultations')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'completed')
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "doctor_dashboard.no_history".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.history, color: Colors.green),
                ),
                title: Text(
                  data['patientName'] ?? "auth.patient".tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${"ai_diagnosis.result".tr()}: ${data['aiDiagnosis']}",
                ),
                trailing: const Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text("patient_dashboard.view_all".tr()),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, route),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}
