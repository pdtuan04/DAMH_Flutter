import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/chat_service.dart';

class ChatBoxScreen extends StatefulWidget {
  const ChatBoxScreen({super.key});

  @override
  State<ChatBoxScreen> createState() => _ChatBoxScreenState();
}

class _ChatBoxScreenState extends State<ChatBoxScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    _sessionId = const Uuid().v4(); // Tự động gen mã Guid cho BE

    // Tin nhắn chào mừng ban đầu
    _messages.add({
      "role": "ai",
      "text": "Xin chào! Tôi là trợ lý Luật Giao Thông. Bạn cần tôi giải đáp thắc mắc gì không?"
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true;
      _controller.clear();
    });

    // Gọi BE với mã Guid và câu hỏi
    String response = await ChatService.getAIResponse(_sessionId, text);

    setState(() {
      _messages.add({"role": "ai", "text": response});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hỏi đáp Luật Giao Thông"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                bool isUser = m["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(m["text"]!, style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "Nhập câu hỏi...", border: OutlineInputBorder()),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.indigo), onPressed: _isLoading ? null : _sendMessage),
        ],
      ),
    );
  }
}