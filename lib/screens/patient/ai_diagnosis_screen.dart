// lib/screens/patient/ai_diagnosis_screen.dart
import 'package:flutter/material.dart';

class AIDiagnosisScreen extends StatefulWidget {
  const AIDiagnosisScreen({super.key});

  @override
  State<AIDiagnosisScreen> createState() => _AIDiagnosisScreenState();
}

class _AIDiagnosisScreenState extends State<AIDiagnosisScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  bool _analyzing = false;

  void _analyzeSymptoms() {
    if (_symptomsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your symptoms')),
      );
      return;
    }

    setState(() => _analyzing = true);

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _analyzing = false);

      Navigator.pushNamed(
        context,
        '/result',
        arguments: {
          'diseaseName': 'Contact Dermatitis',
          'confidence': 0.85,
          'imagePath': null,
        },
      );
    });
  }

  void _uploadImage() {
    // TODO: Implement image upload for skin conditions
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Image upload feature')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Diagnosis'),
        backgroundColor: Colors.purple[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Describe Your Symptoms',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide detailed information about your symptoms for accurate AI analysis',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // Symptoms Input
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Symptoms Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _symptomsController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe your symptoms in detail...\nExample: Red rash on arms, itchy, started 2 days ago...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Tips for better diagnosis:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text('• Describe when symptoms started'),
                    const Text('• Mention affected body parts'),
                    const Text('• Note any pain or discomfort level'),
                    const Text('• Include any other relevant information'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Image Upload Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Images (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'For skin conditions, upload clear photos of affected areas',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _uploadImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take or Upload Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _analyzing
                  ? const ElevatedButton(
                      onPressed: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 10),
                          Text('Analyzing Symptoms...'),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _analyzeSymptoms,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                      ),
                      child: const Text(
                        'Analyze with AI',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Disclaimer
            Card(
              color: Colors.orange[50],
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '⚠️ Disclaimer: AI diagnosis is for informational purposes only. '
                  'Always consult with a healthcare professional for accurate medical diagnosis and treatment.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }
}
