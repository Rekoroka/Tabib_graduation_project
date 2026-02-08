import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:io';
import '../../services/api_service.dart';
import 'package:easy_localization/easy_localization.dart';

class PatientChatScreen extends StatefulWidget {
  final String consultationId;
  final String doctorName;

  const PatientChatScreen({
    super.key,
    required this.consultationId,
    required this.doctorName,
  });

  @override
  State<PatientChatScreen> createState() => _PatientChatScreenState();
}

class _PatientChatScreenState extends State<PatientChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  final String? patientId = FirebaseAuth.instance.currentUser?.uid;

  bool _isUploading = false;
  bool _isRecording = false;
  bool _ratingShown = false; // لمنع تكرار نافذة التقييم
  final AudioRecorder _audioRecorder = AudioRecorder();

  // --- إرسال الرسائل ---
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
      'senderId': patientId,
      'text': text ?? '',
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'audioUrl': audioUrl,
      'isDoctor': false, // مريض
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _apiService.sendMessage(widget.consultationId, messageData);
    _messageController.clear();
  }

  // --- نظام التقييم التلقائي ---
  void _showRatingDialog(String doctorId) {
    double selectedRating = 5.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text("rate doctor".tr())),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 50),
            const SizedBox(height: 15),
            Text("${"rate experience".tr()} ${widget.doctorName}"),
            const SizedBox(height: 20),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => selectedRating = rating,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              onPressed: () async {
                await _submitRating(doctorId, selectedRating);
                if (mounted) Navigator.pop(context);
              },
              child: Text(
                "common submit".tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating(String doctorId, double rating) async {
    try {
      await FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.consultationId)
          .update({'patientRating': rating});

      DocumentReference doctorRef = FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot doctorSnap = await transaction.get(doctorRef);
        if (!doctorSnap.exists) return;

        double currentTotalSum = (doctorSnap.get('totalRatingSum') ?? 0)
            .toDouble();
        int currentRatingCount = (doctorSnap.get('ratingCount') ?? 0).toInt();

        transaction.update(doctorRef, {
          'totalRatingSum': currentTotalSum + rating,
          'ratingCount': currentRatingCount + 1,
          'rating': (currentTotalSum + rating) / (currentRatingCount + 1),
        });
      });
    } catch (e) {
      debugPrint("Error rating: $e");
    }
  }

  // --- التعامل مع الوسائط (كما في شاشة الطبيب) ---
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() => _isUploading = true);
      _sendMessage(imageUrl: image.path);
      setState(() => _isUploading = false);
    }
  }

  Future<void> _handleVoiceNote() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) _sendMessage(audioUrl: path);
    } else {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/v_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dr/ ${widget.doctorName}"),
        backgroundColor: Colors.blue[700],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('consultations')
            .doc(widget.consultationId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var consultationData = snapshot.data!.data() as Map<String, dynamic>;
          String status = consultationData['status'] ?? 'active';
          String doctorId = consultationData['doctorId'] ?? '';

          // تفعيل نافذة التقييم فور اكتمال الاستشارة
          if (status == 'completed' &&
              !_ratingShown &&
              consultationData['patientRating'] == null) {
            _ratingShown = true;
            Future.delayed(Duration.zero, () => _showRatingDialog(doctorId));
          }

          return Column(
            children: [
              if (status == 'completed')
                _buildFinalPrescriptionBanner(
                  consultationData['finalPrescription'],
                ),
              Expanded(child: _buildMessagesStream()),
              if (_isUploading) const LinearProgressIndicator(),
              if (status == 'active')
                _buildInputArea()
              else
                _buildClosedChatNote(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('consultations')
          .doc(widget.consultationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(15),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var msg = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(msg, msg['senderId'] == patientId);
          },
        );
      },
    );
  }

  Widget _buildFinalPrescriptionBanner(String? prescription) {
    return Container(
      width: double.infinity,
      color: Colors.green[50],
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            "final prescription".tr(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            prescription ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
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
            icon: const Icon(Icons.add_a_photo, color: Colors.blue),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "chat type message".tr(),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onLongPress: _handleVoiceNote,
            onLongPressUp: _handleVoiceNote,
            child: Icon(
              _isRecording ? Icons.stop_circle : Icons.mic,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => _sendMessage(text: _messageController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedChatNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.grey[100],
      child: Center(
        child: Text(
          "chat was closed".tr(),
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (msg['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(msg['imageUrl']),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            if (msg['audioUrl'] != null)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle, color: Colors.blue),
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
