import 'package:flutter/material.dart';
import 'dart:io';

class ResultScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Result'),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imagePath != null) ...[
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(imagePath!), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
            ],

            Text(
              'Detection Result',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Disease Detected:',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      diseaseName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Confidence Level:',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${(confidence * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: confidence > 0.7 ? Colors.green : Colors.orange,
                      ),
                    ),

                    const SizedBox(height: 15),

                    LinearProgressIndicator(
                      value: confidence,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        confidence > 0.7 ? Colors.green : Colors.orange,
                      ),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // التعديل هنا فقط: Row -> Wrap
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/upload');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Analyze Another',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    // TODO: إضافة وظيفة المشاركة لاحقاً
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature will be implemented soon'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Share Result',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                minimumSize: const Size(200, 50),
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
