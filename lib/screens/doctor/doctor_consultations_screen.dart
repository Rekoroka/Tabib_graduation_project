import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'send_bid_screen.dart'; // استيراد شاشة إرسال العروض

class DoctorConsultationsScreen extends StatefulWidget {
  const DoctorConsultationsScreen({super.key});

  @override
  State<DoctorConsultationsScreen> createState() =>
      _DoctorConsultationsScreenState();
}

class _DoctorConsultationsScreenState extends State<DoctorConsultationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // التبويبات: طلبات جديدة (للمزايدة) وحالات نشطة (بعد دفع المريض)
    _tabController = TabController(length: 2, vsync: this);
  }

  // تم حذف دالة _acceptCase القديمة لأن التفعيل يتم الآن عبر الدفع من المريض

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text("consultation management".tr()),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "doctor_dashboard.new_requests".tr()), // طلبات للمزايدة
            Tab(
              text: "doctor_dashboard.active_cases".tr(),
            ), // حالات قيد المتابعة
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // التبويب الأول: الحالات المتاحة حالياً (Pending)
          _buildList(
            _apiService.getConsultationsForDoctor(status: 'pending'),
            true,
          ),
          // التبويب الثاني: الحالات التي اختار فيها المريض هذا الطبيب ودفع (Active)
          _buildList(
            _apiService.getConsultationsForDoctor(
              doctorId: uid,
              status: 'active',
            ),
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildList(Stream<QuerySnapshot> stream, bool isPending) {
    final String currentDoctorId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              isPending
                  ? "doctor_dashboard.no_new_requests".tr()
                  : "doctor_dashboard.no_active_cases".tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        var docs = snapshot.data!.docs;

        // ترتيب يدوي: الأحدث أولاً
        docs.sort((a, b) {
          var aData = a.data() as Map<String, dynamic>;
          var bData = b.data() as Map<String, dynamic>;
          var aTime = aData['createdAt'] as Timestamp?;
          var bTime = bData['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            var data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: isPending
                      ? Colors.orange[50]
                      : Colors.green[50],
                  child: Icon(
                    isPending
                        ? Icons.gavel
                        : Icons.chat, // أيقونة المطرقة للمزايدة
                    color: isPending ? Colors.orange : Colors.green,
                  ),
                ),
                title: Text(
                  data['patientName'] ?? "auth.patient".tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${"ai_diagnosis.result".tr()}: ${data['aiDiagnosis'] ?? 'N/A'}",
                ),
                trailing: isPending
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // التعديل: الزر الآن يفتح شاشة إرسال العرض بدلاً من القبول المباشر
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SendBidScreen(consultationId: doc.id),
                          ),
                        ),
                        child: const Text("Bid"),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.green,
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/doctor-chat',
                          arguments: {
                            'consultationId': doc.id,
                            'patientName': data['patientName'],
                          },
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
