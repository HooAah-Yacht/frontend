import 'package:flutter/material.dart';

class HomeEmptyMessage extends StatelessWidget {
  const HomeEmptyMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/image/yacht2_icon.png',
          width: 192,
          height: 253,
        ),
        const SizedBox(height: 16),
        const Text(
          '아직 등록된 요트가 없어요.\n당신의 요트를 추가해 관리해보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}


