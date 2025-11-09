// lib/screens/shared/file_upload_screen.dart
import 'package:flutter/material.dart';

class FileUploadScreen extends StatelessWidget {
  final String consultationId;
  final Function(List<String>)? onFilesUploaded;

  const FileUploadScreen({
    super.key,
    required this.consultationId,
    this.onFilesUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Files'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Upload medical documents, images, or test results',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Add file upload functionality here
            ElevatedButton(
              onPressed: () {
                // TODO: Implement file upload
              },
              child: const Text('Select Files'),
            ),
          ],
        ),
      ),
    );
  }
}
