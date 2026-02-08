import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart'; // مكتبة الترجمة

class AIDiagnosisScreen extends StatefulWidget {
  const AIDiagnosisScreen({super.key});

  @override
  State<AIDiagnosisScreen> createState() => _AIDiagnosisScreenState();
}

class _AIDiagnosisScreenState extends State<AIDiagnosisScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  File? _selectedImage;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _runAnalysis() async {
    // التحقق من المدخلات باستخدام نصوص مترجمة
    if (_symptomsController.text.trim().isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ai_diagnosis.validation_error".tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    // محاكاة تأخير معالجة الذكاء الاصطناعي
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isAnalyzing = false);
      Navigator.pushNamed(
        context,
        '/result',
        arguments: {
          'diseaseName':
              'Dermatitis (Example)', // هذا سيأتي مستقبلاً من موديل الـ AI
          'confidence': 0.89,
          'imagePath': _selectedImage!.path,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("ai_diagnosis.title".tr()),
        backgroundColor: Colors.purple[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // وصف الأعراض
            Text(
              "ai_diagnosis.describe_symptoms".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _symptomsController,
              maxLines: 4,
              textAlign: context.locale == const Locale('ar')
                  ? TextAlign.right
                  : TextAlign.left,
              decoration: InputDecoration(
                hintText: "ai_diagnosis.symptoms_hint".tr(),
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // رفع الصورة
            Text(
              "ai_diagnosis.upload_photo".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickImage(ImageSource.camera),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 60,
                            color: Colors.purple[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "ai_diagnosis.capture_hint".tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 40),

            // زر بدء التحليل
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isAnalyzing ? null : _runAnalysis,
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "ai_diagnosis.start_analysis".tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // ملاحظة إخلاء المسؤولية
            Center(
              child: Text(
                "ai_diagnosis.disclaimer".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
