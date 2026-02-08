import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AiSymptomsBot extends StatefulWidget {
  final String initialDisease; // يستقبل النتيجة: Eczema, Malignant, or Benign
  const AiSymptomsBot({super.key, required this.initialDisease});

  @override
  State<AiSymptomsBot> createState() => _AiSymptomsBotState();
}

class _AiSymptomsBotState extends State<AiSymptomsBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  // قاعدة البيانات الطبية المحلية (Real Medical Content)
  final Map<String, Map<String, String>> _medicalKnowledgeBase = {
    "Eczema": {
      "description": "ai_bot.eczema_desc",
      "symptoms": "ai_bot.eczema_symptoms",
      "advice": "ai_bot.eczema_advice",
    },
    "Malignant": {
      "description": "ai_bot.malignant_desc",
      "symptoms": "ai_bot.malignant_symptoms",
      "advice": "ai_bot.malignant_advice",
    },
    "Benign": {
      "description": "ai_bot.benign_desc",
      "symptoms": "ai_bot.benign_symptoms",
      "advice": "ai_bot.benign_advice",
    },
  };

  @override
  void initState() {
    super.initState();
    // رسالة ترحيبية مخصصة لنوع المرض المكتشف
    _messages.add({
      'text': "ai_bot.welcome".tr(args: [widget.initialDisease.tr()]),
      'isAi': true,
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _processMessage() async {
    final userText = _controller.text.trim().toLowerCase();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({'text': _controller.text, 'isAi': false});
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    await Future.delayed(const Duration(seconds: 1)); // محاكاة واقعية

    String response = "";
    final disease = widget.initialDisease;

    // منطق الرد بناءً على كلمات المستخدم
    if (userText.contains("symptom") ||
        userText.contains("اعراض") ||
        userText.contains("feel")) {
      response =
          _medicalKnowledgeBase[disease]?['symptoms']?.tr() ??
          "ai_bot.general_info".tr();
    } else if (userText.contains("advice") ||
        userText.contains("treat") ||
        userText.contains("علاج") ||
        userText.contains("نصيحة")) {
      response =
          _medicalKnowledgeBase[disease]?['advice']?.tr() ??
          "ai_bot.general_info".tr();
    } else if (userText.contains("what") ||
        userText.contains("explain") ||
        userText.contains("شرح") ||
        userText.contains("ماهو")) {
      response =
          _medicalKnowledgeBase[disease]?['description']?.tr() ??
          "ai_bot.general_info".tr();
    } else {
      response = "ai_bot.default_reply".tr(args: [disease.tr()]);
    }

    setState(() {
      _messages.add({'text': response, 'isAi': true});
      _isTyping = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildChatBubble(_messages[index]),
            ),
          ),
          if (_isTyping) const LinearProgressIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          height: 5,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            "ai_bot.title".tr(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        left: 10,
        right: 10,
        top: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "ai_bot.hint".tr(),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _processMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue[800],
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _processMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isAi = msg['isAi'];
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isAi ? Colors.blue[50] : Colors.blue[800],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          msg['text'],
          style: TextStyle(color: isAi ? Colors.black87 : Colors.white),
        ),
      ),
    );
  }
}
