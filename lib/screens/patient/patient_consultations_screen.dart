import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import 'package:easy_localization/easy_localization.dart'; // مكتبة الترجمة
import '../doctor/offers_list_screen.dart'; // استيراد شاشة العروض

class PatientConsultationsScreen extends StatelessWidget {
  final ApiService _apiService = ApiService();

  PatientConsultationsScreen({super.key});

  // دالة لإلغاء طلب الاستشارة وتغيير حالته في قاعدة البيانات
  Future<void> _cancelConsultation(BuildContext context, String docId) async {
    // إظهار رسالة تأكيد للمريض
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("common.confirm".tr()),
            content: const Text(
              "Are you sure you want to cancel this request? All received offers will be hidden.",
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
        // تحديث حالة الاستشارة في Firestore إلى ملغاة
        await FirebaseFirestore.instance
            .collection('consultations')
            .doc(docId)
            .update({'status': 'cancelled'});

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request cancelled successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("patient_dashboard.my_cases".tr()),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                icon: const Icon(Icons.medical_services),
                text: "doctor_dashboard.active_cases".tr(),
              ),
              Tab(
                icon: const Icon(Icons.history),
                text: "doctor_dashboard.history".tr(),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, ['pending', 'active']),
            _buildList(context, ['completed']),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<String> statuses) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return Center(child: Text("auth.login_required".tr()));

    return StreamBuilder<QuerySnapshot>(
      stream: _apiService.getConsultationsByStatus(userId, statuses),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("${"common.error".tr()}: ${snapshot.error}"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text(
                  "patient_dashboard.no_activity".tr(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
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

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String status = data['status'] ?? 'pending';
            String docId = docs[index].id;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(status).withOpacity(0.1),
                  child: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                  ),
                ),
                title: Text(
                  status == 'completed'
                      ? "${"chat.prescription_from".tr()} ${"doctor_dashboard.dr".tr()} ${data['doctorName']}"
                      : (data['doctorName'] != null
                            ? "${"doctor_dashboard.dr".tr()} ${data['doctorName']}"
                            : "patient_dashboard.searching".tr()),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${"ai_diagnosis.result".tr()}: ${data['aiDiagnosis']}\n${"common.date".tr()}: ${data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate().toString().split(' ')[0] : 'N/A'}",
                ),
                // تم تعديل هذا الجزء ليحتوي على زر الإلغاء وزر العروض معاً
                trailing: status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // زر إلغاء الطلب
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () =>
                                _cancelConsultation(context, docId),
                            tooltip: "Cancel Request",
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Offers",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  if (status == 'pending') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OffersListScreen(consultationId: docId),
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/patient-chat',
                      arguments: {
                        'consultationId': docId,
                        'doctorName': data['doctorName'] ?? 'Doctor',
                      },
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'active') return Colors.green;
    if (status == 'completed') return Colors.blue;
    return Colors.orange;
  }

  IconData _getStatusIcon(String status) {
    if (status == 'active') return Icons.chat;
    if (status == 'completed') return Icons.assignment_turned_in;
    return Icons.hourglass_empty;
  }
}
