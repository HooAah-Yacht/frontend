import 'package:flutter/material.dart';

class YachtManageTitle extends StatelessWidget {
  const YachtManageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '요트관리',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
    );
  }
}

