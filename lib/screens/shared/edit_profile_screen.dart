import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // مكتبة الترجمة

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _specialtyController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تهيئة المتحكمات بالبيانات الحالية
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(
      text: widget.userData['phone'] ?? "",
    );
    _addressController = TextEditingController(
      text: widget.userData['address'] ?? "",
    );
    _specialtyController = TextEditingController(
      text: widget.userData['specialization'] ?? "",
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      };

      // إضافة التخصص فقط إذا كان المستخدم طبيباً
      if (widget.userData['userType'] == 'doctor') {
        updatedData['specialization'] = _specialtyController.text.trim();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("profile.update_success".tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // العودة للشاشة السابقة
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${"common.error".tr()}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    bool isDoctor = widget.userData['userType'] == 'doctor';
    // تحديد اللون بناءً على نوع المستخدم لتوحيد الـ UI
    final Color themeColor = isDoctor ? Colors.green[700]! : Colors.blue[700]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("profile.edit_title".tr()),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // صورة بروفايل رمزية تعطي شكلاً جمالياً
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: themeColor.withOpacity(0.1),
                      child: Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildTextField(
                      _nameController,
                      "auth.full_name".tr(),
                      Icons.person,
                      themeColor,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      _phoneController,
                      "auth.phone".tr(),
                      Icons.phone,
                      themeColor,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      _addressController,
                      "auth.address".tr(),
                      Icons.location_on,
                      themeColor,
                    ),

                    if (isDoctor) ...[
                      const SizedBox(height: 15),
                      _buildTextField(
                        _specialtyController,
                        "auth.specialization".tr(),
                        Icons.medical_services,
                        themeColor,
                      ),
                    ],

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "profile.save_changes".tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    Color color, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: context.locale == const Locale('ar')
          ? TextAlign.right
          : TextAlign.left,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: color),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (value) => value!.isEmpty ? "common.required".tr() : null,
    );
  }
}
