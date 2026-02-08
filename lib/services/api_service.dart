import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ApiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- إدارة بيانات المستخدمين ---

  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  Future<void> saveFCMToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _db.collection('users').doc(user.uid).set(
            {'fcmToken': token},
            SetOptions(merge: true),
          );
        }
      }
    } catch (e) {
      print("Error saving FCM token: $e");
    }
  }

  // --- إدارة الاستشارات للمريض ---

  // تعديل: شلنا الـ orderBy من هنا عشان ميحصلش الوميض والاختفاء لو مفيش Index
  Stream<QuerySnapshot> getRecentConsultations(String userId, {int limit = 3}) {
    return _db.collection('consultations')
        .where('patientId', isEqualTo: userId)
        .limit(limit)
        .snapshots();
  }

  // تعديل: شلنا الـ orderBy وجاري معالجة الترتيب داخل الـ UI عشان نضمن ثبات البيانات
  Stream<QuerySnapshot> getConsultationsByStatus(String userId, List<String> statuses) {
    return _db.collection('consultations')
        .where('patientId', isEqualTo: userId)
        .where('status', whereIn: statuses)
        .snapshots();
  }

  // --- إدارة الاستشارات للطبيب ---

  Stream<QuerySnapshot> getConsultationsCountByStatus(String status, {String? doctorId}) {
    Query query = _db.collection('consultations').where('status', isEqualTo: status);
    if (doctorId != null) {
      query = query.where('doctorId', isEqualTo: doctorId);
    }
    return query.snapshots();
  }

  Stream<QuerySnapshot> getConsultationsForDoctor({String? doctorId, String? status}) {
    Query query = _db.collection('consultations');
    if (status != null) query = query.where('status', isEqualTo: status);
    if (doctorId != null) query = query.where('doctorId', isEqualTo: doctorId);

    // شلنا الـ orderBy لضمان استقرار العرض مؤقتاً
    return query.snapshots();
  }

  Future<void> acceptConsultation(String consultationId, String doctorId, String doctorName) async {
    await _db.collection('consultations').doc(consultationId).update({
      'status': 'active',
      'doctorId': doctorId,
      'doctorName': doctorName,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- إدارة المحادثة (Chat) ---

  Future<void> sendMessage(String consultationId, Map<String, dynamic> messageData) async {
    await _db.collection('consultations')
        .doc(consultationId)
        .collection('messages')
        .add(messageData);
  }
}