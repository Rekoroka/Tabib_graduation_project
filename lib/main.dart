//C:\Users\DELL\Desktop\graduation project\final_tabib\final_tabib\build\app\outputs\flutter-apk\app-release.apk

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// استيراد الشاشات
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/shared/upload_screen.dart';
import 'screens/patient/result_screen.dart';
import 'screens/shared/home_screen.dart';
import 'screens/shared/profile_screen.dart';
import 'screens/doctor/doctor_dashboard_screen.dart';
import 'screens/doctor/doctor_consultations_screen.dart';
import 'screens/doctor/doctor_chat_screen.dart';
// removed: import 'screens/doctor/doctor_profile_screen.dart'; // مش محتاجينها
import 'screens/patient/patient_dashboard_screen.dart';
import 'screens/patient/patient_consultations_screen.dart';
import 'screens/patient/patient_chat_screen.dart';
import 'screens/patient/ai_diagnosis_screen.dart';
import 'screens/shared/consultation_detail_screen.dart';
import 'screens/shared/file_upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تنظيف الذاكرة المؤقتة في وضع التصحيح
  if (kDebugMode) {
    try {
      await FirebaseAuth.instance.signOut();
      print("تم تنظيف جلسة المستخدم للتصحيح");
    } catch (e) {
      print("لا يوجد مستخدم لتسجيل الخروج: $e");
    }
  }

  await Firebase.initializeApp();

  // إعادة تعيين حالة التطبيق بالكامل
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TABIB - Medical Consultation App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          elevation: 4,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        // Auth Routes
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),

        // Shared Routes
        '/home': (context) => const HomeScreen(),
        '/upload': (context) => const UploadScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/file-upload': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return FileUploadScreen(
            consultationId: args?['consultationId'] ?? '',
            onFilesUploaded: args?['onFilesUploaded'],
          );
        },
        '/consultation-detail': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return ConsultationDetailScreen(
            consultationId: args?['consultationId'] ?? '',
            patientName: args?['patientName'] ?? 'Patient',
          );
        },

        // Patient Routes
        '/patient-dashboard': (context) => const PatientDashboardScreen(),
        '/patient-consultations': (context) =>
            const PatientConsultationsScreen(),
        '/patient-chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return PatientChatScreen(
            consultationId: args?['consultationId'] ?? '',
            doctorName: args?['doctorName'] ?? 'Doctor',
          );
        },
        '/ai-diagnosis': (context) => const AIDiagnosisScreen(),
        '/result': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return ResultScreen(
            diseaseName: args?['diseaseName'] ?? "Unknown Disease",
            confidence: args?['confidence']?.toDouble() ?? 0.0,
            imagePath: args?['imagePath'],
          );
        },

        // Doctor Routes
        '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
        '/doctor-consultations': (context) => const DoctorConsultationsScreen(),
        '/doctor-chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          return DoctorChatScreen(
            consultationId: args?['consultationId'] ?? '',
            patientName: args?['patientName'] ?? 'Patient',
          );
        },
        // removed: '/doctor-profile': (context) => const DoctorProfileScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Page Not Found'),
              backgroundColor: Colors.red,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Page Not Found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The page "${settings.name}" was not found.',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
