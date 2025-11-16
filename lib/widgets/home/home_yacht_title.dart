import 'package:flutter/material.dart';

class HomeYachtTitle extends StatelessWidget {
  const HomeYachtTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '내 요트',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

