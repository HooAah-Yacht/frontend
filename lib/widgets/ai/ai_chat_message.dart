import 'package:flutter/material.dart';

enum ChatMessageType {
  user,
  ai,
}

class AiChatMessage extends StatelessWidget {
  final String message;
  final ChatMessageType type;

  const AiChatMessage({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = type == ChatMessageType.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFF4F9FE) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isUser
              ? null
              : Border.all(
                  color: const Color(0xFFB0B8C1), // 회색 border
                  width: 1,
                ),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

