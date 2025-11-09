import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../patient/result_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _loading = true;
      });

      // محاكاة عملية تحميل وتحليل الصورة
      await Future.delayed(const Duration(seconds: 2));

      // الانتقال إلى شاشة النتيجة بعد تحميل الصورة
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              diseaseName: "Plant Disease",
              confidence: 0.87,
              imagePath: pickedFile.path,
            ),
          ),
        );
      }

      setState(() {
        _loading = false;
      });
    }
  }

  void _navigateToProfile() {
    // TODO: تنفيذ شاشة الملف الشخصي لاحقًا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile screen will be implemented soon")),
    );
  }

  void _signOut() async {
    // TODO: تنفيذ تسجيل الخروج لاحقًا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sign out will be implemented soon")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/tabib_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // طبقة سوداء شبه شفافة لتسهيل قراءة النص
          Container(color: Colors.black.withOpacity(0.4)),

          // المحتوى فوق الخلفية
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Upload Plant Image",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Detect diseases in your plants by uploading an image",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  if (_image != null) ...[
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_loading) ...[
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Analyzing image...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, size: 24),
                      label: const Text(
                        "Take Photo",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(250, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 24),
                      label: const Text(
                        "Choose from Gallery",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(250, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
