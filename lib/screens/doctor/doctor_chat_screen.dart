// lib/screens/doctor/doctor_chat_screen.dart
import 'package:flutter/material.dart';

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
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text':
          'Hello Doctor, I have been experiencing fever and headache for 2 days.',
      'isDoctor': false,
      'time': '10:00 AM',
      'files': [],
    },
    {
      'id': '2',
      'text': 'Hello Ahmed. Can you describe your symptoms in more detail?',
      'isDoctor': true,
      'time': '10:02 AM',
      'files': [],
    },
    {
      'id': '3',
      'text': 'I have temperature around 38.5°C, body aches, and fatigue.',
      'isDoctor': false,
      'time': '10:05 AM',
      'files': [],
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': _messageController.text,
        'isDoctor': true,
        'time': _getCurrentTime(),
        'files': [],
      });
    });

    _messageController.clear();
  }

  String _getCurrentTime() {
    return '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
  }

  void _attachFile() {
    // TODO: Implement file attachment
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('File attachment feature')));
  }

  void _viewAIDiagnosis() {
    // TODO: View AI diagnosis
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Viewing AI Diagnosis')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.patientName),
            const Text(
              'Online',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: _viewAIDiagnosis,
            tooltip: 'AI Diagnosis',
          ),
          IconButton(
            icon: const Icon(Icons.attachment),
            onPressed: _attachFile,
            tooltip: 'Attach File',
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Diagnosis Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Diagnosis: Possible Viral Infection',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '85% confidence - Review recommended',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility, size: 16),
                  onPressed: _viewAIDiagnosis,
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _attachFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green[700],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isDoctor = message['isDoctor'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isDoctor
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isDoctor) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isDoctor
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDoctor ? Colors.green[100] : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isDoctor
                          ? const Radius.circular(12)
                          : const Radius.circular(4),
                      bottomRight: isDoctor
                          ? const Radius.circular(4)
                          : const Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: isDoctor ? Colors.green[900] : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message['time'],
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (isDoctor) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.medical_services,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
