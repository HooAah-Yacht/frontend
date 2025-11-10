import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final String firstLine;
  final String secondLine;

  const PageTitle({
    super.key,
    required this.firstLine,
    required this.secondLine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstLine,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.5, // 150% line height
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
        Text(
          secondLine,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

