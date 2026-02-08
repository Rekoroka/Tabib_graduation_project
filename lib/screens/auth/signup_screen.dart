import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart'; // إضافة مكتبة الترجمة

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // المتحكمات (Controllers)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String _userType = 'patient';

  // شروط التحقق التفاعلية
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasNumber = false;
  bool _licenseHasLength = false;
  bool _licenseIsNumeric = false;

  final List<String> _specializations = [
    'Dermatologist',
    'General Practitioner',
    'Pathologist',
    'Cosmetic Dermatologist',
    'Other',
  ];

  // دالة تحديد الموقع الجغرافي
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      setState(() => _loading = true);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _addressController.text =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = _userType == 'doctor'
        ? Colors.green.shade700
        : Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/tabib_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "welcome.signup".tr(), // نص مترجم
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildUserTypeToggle(primaryColor),
                      const SizedBox(height: 20),

                      _buildField(
                        _nameController,
                        "auth.full_name".tr(),
                        Icons.person,
                        (v) => (v == null || v.isEmpty)
                            ? "common.required".tr()
                            : null,
                      ),
                      const SizedBox(height: 15),

                      _buildField(
                        _emailController,
                        "auth.email".tr(),
                        Icons.email,
                        (v) => (v == null || !v.contains('@'))
                            ? "auth.invalid_email".tr()
                            : null,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),

                      _buildField(
                        _phoneController,
                        "auth.phone".tr(),
                        Icons.phone,
                        (v) => (v == null || v.length < 10)
                            ? "auth.invalid_phone".tr()
                            : null,
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),

                      _buildDateField(),
                      const SizedBox(height: 15),

                      _buildField(
                        _addressController,
                        "auth.address".tr(),
                        Icons.location_on,
                        (v) => (v == null || v.isEmpty)
                            ? "common.required".tr()
                            : null,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.my_location,
                            color: Colors.white70,
                          ),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                      const SizedBox(height: 15),

                      if (_userType == 'doctor') ...[
                        const Divider(color: Colors.white30, height: 40),
                        _buildSpecializationDropdown(),
                        const SizedBox(height: 15),
                        _buildLicenseField(),
                        const SizedBox(height: 10),
                        _buildLicenseChecklist(),
                        const SizedBox(height: 15),
                      ],

                      _buildPasswordField(),
                      const SizedBox(height: 10),
                      _buildPasswordChecklist(),

                      const SizedBox(height: 30),
                      _buildSubmitButton(primaryColor),
                      const SizedBox(height: 20),
                      _buildLoginRedirect(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 2.0),
      ),
      errorStyle: const TextStyle(color: Colors.orangeAccent),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    TextInputType keyboard = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: _getInputDecoration(label, icon, suffixIcon: suffixIcon),
      validator: validator,
    );
  }

  Widget _buildUserTypeToggle(Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          _toggleBtn("patient", "auth.patient".tr(), Icons.person, color),
          _toggleBtn(
            "doctor",
            "auth.doctor".tr(),
            Icons.medical_services,
            color,
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String type, String label, IconData icon, Color color) {
    bool selected = _userType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _userType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : Colors.white60,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseField() {
    return TextFormField(
      controller: _licenseController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      onChanged: (v) => setState(() {
        _licenseHasLength = v.length >= 7 && v.length <= 10;
        _licenseIsNumeric = RegExp(r'^[0-9]+$').hasMatch(v);
      }),
      decoration: _getInputDecoration(
        "auth.license_number".tr(),
        Icons.verified_user,
      ),
      validator: (v) =>
          (_userType == 'doctor' && (!_licenseHasLength || !_licenseIsNumeric))
          ? "auth.invalid_license".tr()
          : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      onChanged: (v) => setState(() {
        _hasMinLength = v.length >= 8;
        _hasUpperCase = v.contains(RegExp(r'[A-Z]'));
        _hasNumber = v.contains(RegExp(r'[0-9]'));
      }),
      decoration: _getInputDecoration("auth.password".tr(), Icons.lock)
          .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
      validator: (v) =>
          (v == null || v.length < 8) ? "auth.password_short".tr() : null,
    );
  }

  Widget _buildSpecializationDropdown() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.grey[900],
      style: const TextStyle(color: Colors.white),
      decoration: _getInputDecoration(
        "auth.specialization".tr(),
        Icons.category,
      ),
      items: _specializations
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(s, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => _specializationController.text = val!),
      validator: (v) => (_userType == 'doctor' && (v == null))
          ? "common.selection_required".tr()
          : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: _getInputDecoration("auth.dob".tr(), Icons.calendar_today),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(
            () => _dobController.text = DateFormat('yyyy-MM-dd').format(picked),
          );
        }
      },
      validator: (v) =>
          (v == null || v.isEmpty) ? "common.required".tr() : null,
    );
  }

  Widget _reqRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: isMet ? Colors.green : Colors.white60,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? Colors.green : Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordChecklist() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _reqRow("auth.pass_len".tr(), _hasMinLength),
          const SizedBox(height: 5),
          _reqRow("auth.pass_upper".tr(), _hasUpperCase),
          const SizedBox(height: 5),
          _reqRow("auth.pass_num".tr(), _hasNumber),
        ],
      ),
    );
  }

  Widget _buildLicenseChecklist() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _reqRow("auth.license_len".tr(), _licenseHasLength),
          const SizedBox(height: 5),
          _reqRow("auth.license_numeric".tr(), _licenseIsNumeric),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _loading ? null : _signUp,
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "welcome.signup".tr(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        "auth.has_account".tr(),
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      await userCredential.user!.updateDisplayName(_nameController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'dob': _dobController.text,
            'userType': _userType,
            'fcmToken': fcmToken,
            'specialization': _userType == 'doctor'
                ? _specializationController.text
                : null,
            'licenseNumber': _userType == 'doctor'
                ? _licenseController.text.trim()
                : null,
            'rating': _userType == 'doctor' ? 5.0 : null, // تقييم مبدئي للطبيب
            'isVerified': _userType == 'patient',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("common.success".tr())));
        // التوجه للمسار الرئيسي ليقوم الـ AuthWrapper بالتوجيه للداشبورد الصحيحة
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String error = "common.error".tr();
      if (e.code == 'email-already-in-use') error = "auth.email_in_use".tr();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
