import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart'; // مكتبة الترجمة
import 'dart:io';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // دالة تسجيل الخروج مع مسح التوكن لضمان الأمان
  Future<void> _logout(BuildContext context) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // مسح توكن الإشعارات عند تسجيل الخروج
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': FieldValue.delete(),
      });

      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        // العودة لشاشة البداية وتصفير سجل التنقل
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${"common.error".tr()}: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // التأكد من وجود مستخدم مسجل دخول
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return const Scaffold(body: Center(child: Text("No User Logged In")));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("profile.title".tr()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF4CAF50),
              ], // درجات الأخضر الطبي
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("profile.no_data".tr()));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          final bool isDoctor = userData['userType'] == 'doctor';

          // تحديد لون السمة بناءً على نوع المستخدم (طبيب أخضر، مريض أزرق)
          final Color themeColor = isDoctor
              ? Colors.green[700]!
              : Colors.blue[700]!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // --- قسم الهيدر (الصورة والاسم) ---
                _buildHeader(context, userData, themeColor),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- قسم إعدادات اللغة ---
                      _buildSectionTitle("profile.language_settings".tr()),
                      _buildLanguageTile(context),

                      const SizedBox(height: 20),

                      // --- قسم معلومات الحساب الأساسية ---
                      _buildSectionTitle("profile.account_info".tr()),
                      _buildProfileTile(
                        context,
                        Icons.person_outline,
                        "auth.full_name".tr(),
                        userData['name'] ?? "N/A",
                        userData,
                        themeColor,
                      ),
                      _buildProfileTile(
                        context,
                        Icons.email_outlined,
                        "auth.email".tr(),
                        userData['email'] ?? "N/A",
                        userData,
                        themeColor,
                      ),
                      _buildProfileTile(
                        context,
                        Icons.phone_android,
                        "auth.phone".tr(),
                        userData['phone'] ?? "profile.add_phone".tr(),
                        userData,
                        themeColor,
                      ),
                      _buildProfileTile(
                        context,
                        Icons.location_on_outlined,
                        "auth.address".tr(),
                        userData['address'] ?? "profile.add_address".tr(),
                        userData,
                        themeColor,
                      ),

                      // --- قسم معلومات الطبيب (يظهر فقط للدكاترة) ---
                      if (isDoctor) ...[
                        const SizedBox(height: 20),
                        _buildSectionTitle("profile.pro_info".tr()),
                        _buildProfileTile(
                          context,
                          Icons.medical_services_outlined,
                          "auth.specialization".tr(),
                          userData['specialization'] ?? "N/A",
                          userData,
                          themeColor,
                        ),
                        _buildProfileTile(
                          context,
                          Icons.verified_user_outlined,
                          "auth.license_number".tr(),
                          userData['licenseNumber'] ?? "N/A",
                          userData,
                          themeColor,
                        ),
                      ],

                      const SizedBox(height: 20),

                      // --- قسم الدعم والمساعدة ---
                      _buildSectionTitle("profile.app_support".tr()),
                      _buildSupportTile(
                        context,
                        Icons.info_outline,
                        "common.about".tr(),
                        themeColor,
                        () => Navigator.pushNamed(context, '/about'),
                      ),

                      const SizedBox(height: 40),

                      // --- زر تسجيل الخروج ---
                      _buildLogoutButton(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ويدجت عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  // بناء الهيدر مع دائرة الصورة الشخصية
  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic> data,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  // عرض الصورة من الرابط إذا وجد، وإلا توليد صورة رمزية بالاسم
                  backgroundImage:
                      (data['profileImage'] != null &&
                          data['profileImage'] != "")
                      ? NetworkImage(data['profileImage'])
                      : NetworkImage(
                              "https://ui-avatars.com/api/?name=${data['name']}&background=random&color=fff",
                            )
                            as ImageProvider,
                ),
              ),
              // زر الكاميرا للانتقال لشاشة التعديل واختيار صورة
              InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/edit-profile',
                  arguments: data,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            data['name'] ?? "User",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data['userType']?.toString().toUpperCase() ?? "PATIENT",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بلاطة تبديل اللغة
  Widget _buildLanguageTile(BuildContext context) {
    bool isArabic = context.locale == const Locale('ar');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.language, color: Colors.orange),
        title: Text(
          "profile.current_language".tr(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic ? "العربية" : "English",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.swap_horiz, size: 18, color: Colors.grey),
          ],
        ),
        onTap: () {
          // التبديل بين اللغتين
          if (isArabic) {
            context.setLocale(const Locale('en'));
          } else {
            context.setLocale(const Locale('ar'));
          }
        },
      ),
    );
  }

  // بلاطة عرض المعلومات (الاسم، الهاتف، الخ)
  Widget _buildProfileTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Map<String, dynamic> userData,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () =>
            Navigator.pushNamed(context, '/edit-profile', arguments: userData),
      ),
    );
  }

  // بلاطة خيارات الدعم
  Widget _buildSupportTile(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  // زر تسجيل الخروج الأحمر
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout),
        label: Text(
          "profile.logout".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[700],
          side: BorderSide(color: Colors.red[700]!, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
