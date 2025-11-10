import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/image/yacht1_icon.png',
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 24),
        Image.asset(
          'assets/image/hooaah_logo.png',
          width: 100,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
