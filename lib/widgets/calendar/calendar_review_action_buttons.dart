import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_button.dart';

class CalendarReviewActionButtons extends StatelessWidget {
  final VoidCallback? onLater;
  final VoidCallback? onSubmit;

  const CalendarReviewActionButtons({
    super.key,
    this.onLater,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 나중에 하기 버튼
        Expanded(
          child: OutlinedButton(
            onPressed: onLater,
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
              '나중에 하기',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 등록하기 버튼
        Expanded(
          child: CustomButton(
            text: '등록하기',
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}

