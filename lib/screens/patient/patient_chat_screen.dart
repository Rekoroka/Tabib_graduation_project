// lib/screens/patient/patient_chat_screen.dart
import 'package:flutter/material.dart';

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
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Hello Doctor, I have been experiencing skin rash for 2 days.',
      'isPatient': true,
      'time': '10:00 AM',
    },
    {
      'id': '2',
      'text': 'Hello! Can you describe the rash in more detail?',
      'isPatient': false,
      'time': '10:02 AM',
    },
    {
      'id': '3',
      'text': 'It\'s red, itchy, and appears on my arms and chest.',
      'isPatient': true,
      'time': '10:05 AM',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': _messageController.text,
        'isPatient': true,
        'time': _getCurrentTime(),
      });
    });

    _messageController.clear();
  }

  String _getCurrentTime() {
    return '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
  }

  void _attachFile() {
    // TODO: Implement file attachment
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 200,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Upload Image'),
              onTap: () {
                Navigator.pop(context);
                // Implement image upload
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Upload Document'),
              onTap: () {
                Navigator.pop(context);
                // Implement document upload
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doctorName),
            const Text(
              'Online',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.attachment),
            onPressed: _attachFile,
            tooltip: 'Attach File',
          ),
        ],
      ),
      body: Column(
        children: [
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
                  backgroundColor: Colors.blue[700],
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
    final isPatient = message['isPatient'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isPatient
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isPatient) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.medical_services,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isPatient
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPatient ? Colors.blue[100] : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isPatient
                          ? const Radius.circular(12)
                          : const Radius.circular(4),
                      bottomRight: isPatient
                          ? const Radius.circular(4)
                          : const Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: isPatient ? Colors.blue[900] : Colors.black87,
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
          if (isPatient) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
