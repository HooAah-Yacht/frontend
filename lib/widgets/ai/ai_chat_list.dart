import 'package:flutter/material.dart';
import 'package:frontend/widgets/ai/ai_chat_message.dart';

class AiChatList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final ScrollController? scrollController;

  const AiChatList({
    super.key,
    required this.messages,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {    
    if (messages.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            '메시지가 없습니다.',
            style: TextStyle(
              fontSize: 16,
              letterSpacing: -0.5,
              color: Color(0xFFB0B8C1),
            ),
          ),
        ),
      );
    }
    
    return Container(
      color: Colors.white, // 흰색 배경
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AiChatMessage(
              message: message['text'] as String? ?? '',
              type: message['type'] == 'user'
                  ? ChatMessageType.user
                  : ChatMessageType.ai,
            ),
          );
        },
      ),
    );
  }
}

