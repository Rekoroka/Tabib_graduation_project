import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

// استيراد الشاشات
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/shared/profile_screen.dart';
import 'screens/shared/edit_profile_screen.dart';
import 'screens/patient/patient_dashboard_screen.dart';
import 'screens/patient/patient_consultations_screen.dart';
import 'screens/patient/patient_chat_screen.dart';
import 'screens/patient/ai_diagnosis_screen.dart';
import 'screens/patient/result_screen.dart';
import 'screens/doctor/doctor_dashboard_screen.dart';
import 'screens/doctor/doctor_consultations_screen.dart';
import 'screens/doctor/doctor_chat_screen.dart';
// 1. إضافة استيراد صفحة الطلبات المتاحة
import 'screens/doctor/available_requests_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized(); // تفعيل الترجمة

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations', // مسار ملفات الترجمة
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'), // الإنجليزية هي الديفولت
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, // اللغة الحالية للتطبيق
      title: 'TABIB - Medical App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          centerTitle: true,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),

      home: const AuthWrapper(),

      routes: {
        // --- شاشات المصادقة (Auth) ---
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),

        // --- الشاشات المشتركة (Shared) ---
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return EditProfileScreen(userData: args);
        },
        '/about': (context) => const AboutScreen(),

        // --- شاشات المريض (Patient) ---
        '/patient-dashboard': (context) => const PatientDashboardScreen(),
        '/patient-consultations': (context) => PatientConsultationsScreen(),
        '/ai-diagnosis': (context) => const AIDiagnosisScreen(),
        '/result': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ResultScreen(
            diseaseName: args['diseaseName'] ?? 'Unknown',
            confidence: (args['confidence'] ?? 0.0).toDouble(),
            imagePath: args['imagePath'],
          );
        },
        '/patient-chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return PatientChatScreen(
            consultationId: args['consultationId'] ?? '',
            doctorName: args['doctorName'] ?? 'Doctor',
          );
        },

        // --- شاشات الطبيب (Doctor) ---
        '/doctor-dashboard': (context) => DoctorDashboardScreen(),
        '/doctor-consultations': (context) => const DoctorConsultationsScreen(),
        '/doctor-chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return DoctorChatScreen(
            consultationId: args['consultationId'] ?? '',
            patientName: args['patientName'] ?? 'Patient',
          );
        },
        // 2. تعريف مسار صفحة الطلبات المتاحة
        '/available-requests': (context) => const AvailableRequestsScreen(),
      },

      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(child: Text('Page ${settings.name} not found')),
        ),
      ),
    );
  }
}

// --- ويدجت التوجيه الذكي (AuthWrapper) ---
// يقوم بفحص نوع المستخدم من قاعدة البيانات ويوجهه للداشبورد الصحيحة فوراً
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // إذا لم يكن مسجل دخول، اذهب لشاشة الترحيب
        if (!snapshot.hasData || snapshot.data == null) {
          return const WelcomeScreen();
        }

        // إذا كان مسجل دخول، ابحث عن نوع المستخدم في Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              String userType = userSnapshot.data!.get('userType') ?? 'patient';

              if (userType == 'doctor') {
                return DoctorDashboardScreen();
              } else {
                return const PatientDashboardScreen();
              }
            }

            // في حالة وجود خطأ في البيانات، أرجعه للترحيب
            return const WelcomeScreen();
          },
        );
      },
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("common.about".tr())), // استخدام الترجمة
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                "assets/images/tabib.jpg",
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.medical_services,
                    size: 80,
                    color: Colors.green,
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "TABIB App",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "about_desc".tr(), // استخدام الترجمة
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            const Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            const Text(
              "Developed for Graduation Project",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Developed by TABIB Developers",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
