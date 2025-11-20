import 'package:flutter/material.dart';

class CalendarContentHeader extends StatelessWidget {
  final String content;
  final bool completed;

  const CalendarContentHeader({
    super.key,
    required this.content,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: completed ? const Color(0xFF87C149) : const Color(0xFFF2C538),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            completed ? '완료' : '진행전',
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

