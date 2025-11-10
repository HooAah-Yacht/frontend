import 'package:flutter/material.dart';

class SignUpLink extends StatelessWidget {
  final VoidCallback? onTap;

  const SignUpLink({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '계정이 없으신가요? ',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            letterSpacing: -0.5,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            '회원가입',
            style: TextStyle(
              color: Color(0xFF2B4184),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

