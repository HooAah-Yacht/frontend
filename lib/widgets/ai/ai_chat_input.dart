import 'package:flutter/material.dart';

class AiChatInput extends StatefulWidget {
  const AiChatInput({super.key});

  @override
  State<AiChatInput> createState() => _AiChatInputState();
}

class _AiChatInputState extends State<AiChatInput> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      // TODO: 메시지 전송 로직 구현
      print('메시지 전송: $message');
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      color: Colors.white,
      child: Row(
        children: [
          // 메시지 입력 필드
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: 2,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: '메시지 입력',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  letterSpacing: -0.5,
                  color: Color(0xFFB0B8C1),
                ),
                filled: true,
                fillColor: const Color(0xFFF4F9FE),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                letterSpacing: -0.5,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 전송 버튼
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B4184),
              borderRadius: BorderRadius.circular(50),
            ),
            child: GestureDetector(
              onTap: _handleSend,
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

