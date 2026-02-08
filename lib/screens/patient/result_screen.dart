import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../shared/ai_shatbot.dart';
import '../doctor/offers_list_screen.dart'; // Ensure this path is correct

class ResultScreen extends StatefulWidget {
  final String diseaseName;
  final double confidence;
  final String? imagePath;

  const ResultScreen({
    super.key,
    required this.diseaseName,
    required this.confidence,
    this.imagePath,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isRequesting = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareResult() async {
    try {
      final Uint8List? image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File(
          '${directory.path}/TABIB_Result.png',
        ).create();
        await imagePath.writeAsBytes(image);

        await Share.shareXFiles([
          XFile(imagePath.path),
        ], text: 'Check my AI skin diagnosis result on TABIB app! 🛡️');
      }
    } catch (e) {
      debugPrint("Share Error: $e");
    }
  }

  void _openAiAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: AiSymptomsBot(initialDisease: widget.diseaseName),
      ),
    );
  }

  Future<void> _requestConsultation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isRequesting = true);
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final patientName =
          userDoc.data()?['name'] ?? "patient_dashboard.patient".tr();

      // Create the consultation and get the reference
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('consultations')
          .add({
            'patientId': user.uid,
            'patientName': patientName,
            'aiDiagnosis': widget.diseaseName,
            'confidence': widget.confidence,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'doctorId': null,
            'doctorName': null,
            'symptoms': 'Analyzed via AI Diagnosis',
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("consultation.request_sent_success".tr()),
            backgroundColor: Colors.green[700],
          ),
        );

        // Navigation logic for the new Cycle:
        // Redirecting to the screen where the patient waits for doctor bids
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OffersListScreen(consultationId: docRef.id),
          ),
        );
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
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('ai_diagnosis.result_title'.tr()),
        backgroundColor: mainGreen,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareResult,
            tooltip: 'Share Result',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAiAssistant,
        backgroundColor: Colors.blue[800],
        icon: const Icon(Icons.psychology_outlined, color: Colors.white),
        label: const Text(
          "Ask AI Assistant",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    if (widget.imagePath != null) ...[
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(widget.imagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                    Text(
                      'ai_diagnosis.analysis_result'.tr(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: mainGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
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
                        children: [
                          Text(
                            'ai_diagnosis.disease_detected'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.diseaseName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Divider(color: Colors.grey[100]),
                          const SizedBox(height: 15),
                          Text(
                            'ai_diagnosis.confidence_level'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${(widget.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: widget.confidence > 0.7
                                  ? mainGreen
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: widget.confidence,
                              minHeight: 12,
                              backgroundColor: Colors.grey[100],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.confidence > 0.7
                                    ? mainGreen
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_isRequesting)
              CircularProgressIndicator(color: mainGreen)
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                      ),
                      label: Text(
                        "ai_diagnosis.consult_expert".tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _requestConsultation,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: mainGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      child: Text(
                        "common.back_home".tr(),
                        style: TextStyle(
                          color: mainGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
