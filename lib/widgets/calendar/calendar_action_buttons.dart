import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_button.dart';

class CalendarActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CalendarActionButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 일정 수정 버튼
        Expanded(
          child: OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF47546F),
              side: const BorderSide(
                color: Color(0xFF47546F),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              '일정 수정',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 일정 삭제 버튼
        Expanded(
          child: CustomButton(
            text: '일정 삭제',
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}

