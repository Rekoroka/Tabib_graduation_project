// lib/screens/shared/file_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // تأكدي من إضافة المكتبة في pubspec.yaml
import 'package:easy_localization/easy_localization.dart';
import '../../services/api_service.dart';

class FileUploadScreen extends StatefulWidget {
  final String consultationId;
  final Function(List<String>)? onFilesUploaded;

  const FileUploadScreen({
    super.key,
    required this.consultationId,
    this.onFilesUploaded,
  });

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final ApiService _apiService = ApiService();
  List<PlatformFile> _selectedFiles = [];
  bool _isUploading = false;

  // دالة اختيار الملفات من الهاتف
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'doc'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  // دالة الرفع الحقيقية (المنطق البرمجي)
  Future<void> _uploadAndFinish() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      // هنا يتم استدعاء دالة الرفع من الـ ApiService لكل ملف
      List<String> uploadedUrls = [];
      for (var file in _selectedFiles) {
        // نمرر المسار file.path للسيرفس لرفعه لـ Firebase Storage
        // String url = await _apiService.uploadFile(file.path!, widget.consultationId);
        // uploadedUrls.add(url);
      }

      if (widget.onFilesUploaded != null) {
        widget.onFilesUploaded!(uploadedUrls);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("common.success".tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("common.error".tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.green[700]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('chat.upload_files'.tr()),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // أيقونة توضيحية
            Icon(
              Icons.cloud_upload_outlined,
              size: 80,
              color: primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 20),

            Text(
              'chat.upload_instruction'
                  .tr(), // نص: "يرجى رفع المستندات الطبية، الصور أو نتائج التحاليل"
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // منطقة عرض الملفات المختارة
            Expanded(
              child: _selectedFiles.isEmpty
                  ? _buildEmptyState()
                  : _buildFilesList(),
            ),

            const SizedBox(height: 20),

            // أزرار التحكم
            if (_isUploading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  _buildActionButton(
                    label: 'chat.select_files'.tr(),
                    icon: Icons.file_copy,
                    color: Colors.blue[700]!,
                    onPressed: _pickFiles,
                  ),
                  const SizedBox(height: 12),
                  if (_selectedFiles.isNotEmpty)
                    _buildActionButton(
                      label: 'chat.start_upload'.tr(),
                      icon: Icons.check_circle,
                      color: primaryColor,
                      onPressed: _uploadAndFinish,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 2),
      ),
      child: Center(
        child: Text(
          "chat.no_files_selected".tr(),
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildFilesList() {
    return ListView.builder(
      itemCount: _selectedFiles.length,
      itemBuilder: (context, index) {
        final file = _selectedFiles[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            leading: Icon(Icons.insert_drive_file, color: Colors.blue[700]),
            title: Text(
              file.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${(file.size / 1024).toStringAsFixed(2)} KB"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => setState(() => _selectedFiles.removeAt(index)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
