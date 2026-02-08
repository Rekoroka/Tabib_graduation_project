import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; //
import 'package:easy_localization/easy_localization.dart';
import 'send_bid_screen.dart';

class AvailableRequestsScreen extends StatelessWidget {
  const AvailableRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentDoctorId =
        FirebaseAuth.instance.currentUser?.uid ?? ""; //

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Patient Requests"),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('consultations')
            .where(
              'status',
              isEqualTo: 'pending',
            ) // عرض الحالات غير المقبولة فقط
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var request = snapshot.data!.docs[index];

              // التحقق هل هذا الطبيب أرسل عرضاً مسبقاً لهذه الحالة أم لا
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('consultations')
                    .doc(request.id)
                    .collection('offers')
                    .doc(currentDoctorId)
                    .get(),
                builder: (context, offerSnapshot) {
                  bool hasBid =
                      offerSnapshot.hasData && offerSnapshot.data!.exists;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      // تمييز الكارت إذا كان هناك عرض مرسل
                      side: hasBid
                          ? BorderSide(color: Colors.green, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: hasBid
                            ? Colors.green[100]
                            : Colors.orange[100],
                        child: Icon(
                          hasBid ? Icons.edit_note : Icons.person,
                          color: hasBid
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                      ),
                      title: Text(
                        "Patient: ${request['patientName']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("AI Diagnosis: ${request['aiDiagnosis']}"),
                          Text(
                            "Confidence: ${(request['confidence'] * 100).toStringAsFixed(1)}%",
                          ),
                          if (hasBid) ...[
                            const SizedBox(height: 5),
                            Text(
                              "You already sent an offer: ${offerSnapshot.data!['price']} EGP",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Icon(
                        hasBid ? Icons.edit : Icons.arrow_forward_ios,
                        size: 18,
                        color: hasBid ? Colors.green : Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SendBidScreen(consultationId: request.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            "No pending cases at the moment",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
