import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // مكتبة اختيار الملفات
import 'package:record/record.dart'; // مكتبة تسجيل الصوت
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/api_service.dart';
import 'package:easy_localization/easy_localization.dart';

class DoctorChatScreen extends StatefulWidget {
  final String consultationId;
  final String patientName;

  const DoctorChatScreen({
    super.key,
    required this.consultationId,
    required this.patientName,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  final String? doctorId = FirebaseAuth.instance.currentUser?.uid;

  // متغيرات الوسائط
  bool _isUploading = false;
  bool _isRecording = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordingPath;

  // إرسال رسالة (هيكل موحد يدعم كل الأنواع)
  void _sendMessage({
    String? text,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    String? audioUrl,
  }) async {
    if ((text == null || text.trim().isEmpty) &&
        imageUrl == null &&
        fileUrl == null &&
        audioUrl == null)
      return;

    final messageData = {
      'senderId': doctorId,
      'text': text ?? '',
      'imageUrl': imageUrl, // رابط الصورة
      'fileUrl': fileUrl, // رابط الملف (PDF/Doc)
      'fileName': fileName, // اسم الملف للعرض
      'audioUrl': audioUrl, // رابط الفويس نوت
      'isDoctor': true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _apiService.sendMessage(widget.consultationId, messageData);
    _messageController.clear();
  }

  // --- اختيار الوسائط ---

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _attachmentOption(
              Icons.image,
              "Gallery",
              () => _pickImage(ImageSource.gallery),
            ),
            _attachmentOption(
              Icons.camera_alt,
              "Camera",
              () => _pickImage(ImageSource.camera),
            ),
            _attachmentOption(Icons.insert_drive_file, "File", _pickFile),
          ],
        ),
      ),
    );
  }

  Widget _attachmentOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green[50],
            child: Icon(icon, color: Colors.green[700]),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() => _isUploading = true);
      // هنا سيتم الرفع لـ Firebase Storage مستقبلاً
      _sendMessage(imageUrl: image.path);
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _isUploading = true);
      _sendMessage(
        fileUrl: result.files.single.path,
        fileName: result.files.single.name,
      );
      setState(() => _isUploading = false);
    }
  }

  // --- تسجيل الصوت ---

  Future<void> _handleVoiceNote() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
      if (_recordingPath != null) {
        _sendMessage(audioUrl: _recordingPath);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    }
  }

  // --- إنهاء الاستشارة وتحديث الإحصائيات ---

  void _showCompleteConsultationDialog() {
    final TextEditingController prescriptionController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("chat.final_diagnosis".tr()),
        content: TextField(
          controller: prescriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "chat.prescription_hint".tr(),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("common.cancel".tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            onPressed: () async {
              if (prescriptionController.text.trim().isEmpty) return;

              // 1. تحديث حالة الاستشارة
              await FirebaseFirestore.instance
                  .collection('consultations')
                  .doc(widget.consultationId)
                  .update({
                    'status': 'completed',
                    'finalPrescription': prescriptionController.text.trim(),
                    'completedAt': FieldValue.serverTimestamp(),
                  });

              // 2. تحديث إحصائيات الطبيب (زيادة الحالات المكتملة)
              if (doctorId != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(doctorId)
                    .update({'completedCases': FieldValue.increment(1)});
              }

              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("chat.consultation_completed".tr())),
                );
              }
            },
            child: Text(
              "chat.submit_finish".tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${"chat.patient".tr()}: ${widget.patientName}"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: "chat.complete_case".tr(),
            onPressed: _showCompleteConsultationDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAIDiagnosisBanner(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('consultations')
                  .doc(widget.consultationId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var msg =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                    return _buildMessageBubble(
                      msg,
                      msg['senderId'] == doctorId,
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploading) const LinearProgressIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildAIDiagnosisBanner() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.consultationId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.data() == null)
          return const SizedBox.shrink();
        var data = snapshot.data!.data() as Map<String, dynamic>;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ai_diagnosis.title".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                "${"ai_diagnosis.result".tr()}: ${data['aiDiagnosis']} (${((data['confidence'] ?? 0) * 100).toStringAsFixed(0)}%)",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.green),
            onPressed: _showAttachmentSheet,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "chat.type_medical_advice".tr(),
                border: InputBorder.none,
              ),
            ),
          ),
          // زر الفويس نوت
          GestureDetector(
            onLongPress: _handleVoiceNote,
            onLongPressUp: _handleVoiceNote,
            child: IconButton(
              icon: Icon(
                _isRecording ? Icons.stop_circle : Icons.mic,
                color: _isRecording ? Colors.red : Colors.green,
              ),
              onPressed: _handleVoiceNote,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () => _sendMessage(text: _messageController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (msg['imageUrl'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(msg['imageUrl']),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (msg['fileUrl'] != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(
                    msg['fileName'] ?? "File",
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            if (msg['audioUrl'] != null)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_fill, color: Colors.green),
                  SizedBox(width: 5),
                  Text("Voice Note"),
                ],
              ),
            if (msg['text'] != null && msg['text'].toString().isNotEmpty)
              Text(msg['text'], style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
