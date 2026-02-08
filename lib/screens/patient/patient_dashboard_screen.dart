import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import 'package:easy_localization/easy_localization.dart'; // مكتبة الترجمة
import '../doctor/offers_list_screen.dart'; // استيراد شاشة العروض

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final ApiService _apiService = ApiService();
  final User? user = FirebaseAuth.instance.currentUser;

  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getUserData();
      if (mounted && userData != null) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // دالة إلغاء الطلب من الداشبورد
  Future<void> _cancelConsultation(BuildContext context, String docId) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("common.confirm".tr()),
            content: const Text(
              "Are you sure you want to cancel this request?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("common.cancel".tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "common.confirm".tr(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('consultations')
            .doc(docId)
            .update({'status': 'cancelled'});

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Request cancelled")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('app_name'.tr()), // اسم التطبيق مترجم
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(),
                  const SizedBox(height: 25),
                  _buildQuickActionsGrid(),
                  const SizedBox(height: 30),
                  _buildSectionTitle(
                    "patient_dashboard.recent".tr(),
                    () =>
                        Navigator.pushNamed(context, '/patient-consultations'),
                  ),
                  const SizedBox(height: 15),
                  _buildRealRecentConsultations(),
                  const SizedBox(height: 30),
                  _buildHealthTipsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[400]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            backgroundImage: NetworkImage(
              "https://ui-avatars.com/api/?name=${_userData?['name'] ?? 'User'}&background=fff&color=0D47A1",
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${"patient_dashboard.hello".tr()} ${_userData?['name'] ?? 'patient_dashboard.patient'.tr()}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "patient_dashboard.subtitle".tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _actionCard(
          'patient_dashboard.ai_diagnosis'.tr(),
          Icons.psychology,
          Colors.purple,
          () => Navigator.pushNamed(context, '/ai-diagnosis'),
        ),
        _actionCard(
          'patient_dashboard.my_cases'.tr(),
          Icons.folder_shared,
          Colors.blue,
          () => Navigator.pushNamed(context, '/patient-consultations'),
        ),
        _actionCard(
          'profile.title'.tr(),
          Icons.manage_accounts,
          Colors.orange,
          () => Navigator.pushNamed(context, '/profile'),
        ),
        _actionCard(
          'patient_dashboard.support'.tr(),
          Icons.help_outline,
          Colors.green,
          () => Navigator.pushNamed(context, '/about'),
        ),
      ],
    );
  }

  Widget _actionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealRecentConsultations() {
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _apiService.getRecentConsultations(user!.uid, limit: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("${"common.error".tr()}: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text("patient_dashboard.no_activity".tr()),
            ),
          );
        }

        var docs = snapshot.data!.docs;
        docs.sort((a, b) {
          var aTime =
              (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          var bTime =
              (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        return Column(
          children: docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return _consultationTile(data, doc.id);
          }).toList(),
        );
      },
    );
  }

  Widget _consultationTile(Map<String, dynamic> data, String docId) {
    String status = data['status'] ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          if (status == 'pending') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OffersListScreen(consultationId: docId),
              ),
            );
          } else if (status == 'active') {
            Navigator.pushNamed(
              context,
              '/patient-chat',
              arguments: {
                'consultationId': docId,
                'doctorName':
                    data['doctorName'] ?? 'doctor_dashboard.doctor'.tr(),
              },
            );
          }
        },
        leading: CircleAvatar(
          backgroundColor: status == 'cancelled'
              ? Colors.red[50]
              : Colors.blue[50],
          child: Icon(
            status == 'cancelled'
                ? Icons.cancel_presentation
                : Icons.medical_information,
            color: status == 'cancelled' ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(
          data['doctorName'] ?? "patient_dashboard.searching".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${"ai_diagnosis.result".tr()}: ${data['aiDiagnosis']}"),
        trailing: status == 'pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر الإلغاء السريع
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () => _cancelConsultation(context, docId),
                  ),
                  // زر عرض العروض
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OffersListScreen(consultationId: docId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Offers",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'active'
                      ? Colors.green[100]
                      : (status == 'cancelled'
                            ? Colors.red[100]
                            : Colors.orange[100]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: status == 'active'
                        ? Colors.green[900]
                        : (status == 'cancelled'
                              ? Colors.red[900]
                              : Colors.orange[900]),
                  ),
                ),
              ),
      ),
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

  Widget _buildHealthTipsSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: const Icon(Icons.lightbulb, color: Colors.amber),
        title: Text("patient_dashboard.health_tip_title".tr()),
        subtitle: Text("patient_dashboard.health_tip_content".tr()),
      ),
    );
  }
}
