// lib/screens/shared/consultation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // مكتبة الترجمة

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
    // توحيد اللون الأخضر مع باقي شاشات الطبيب
    final Color primaryGreen = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.white, // توحيد الخلفية البيضاء
      appBar: AppBar(
        title: Text("chat.consultation_details".tr()), // نص مترجم
        backgroundColor: primaryGreen,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // كارت المعلومات الأساسية بتصميم الـ Container الموحد
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_pin, color: primaryGreen, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'auth.patient_info'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  _buildDetailRow("auth.full_name".tr(), patientName),
                  const SizedBox(height: 12),
                  _buildDetailRow("common.id".tr(), consultationId),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // قسم إضافي مقترح (AI Summary) ليعطي طابعاً احترافياً
            Text(
              "ai_diagnosis.analysis_result".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.auto_awesome, color: Colors.blue),
                title: Text("ai_diagnosis.title".tr()),
                subtitle: const Text(
                  "Symptoms and AI detection summary goes here...",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت مساعدة لبناء صفوف التفاصيل بشكل منظم
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
