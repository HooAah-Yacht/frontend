import 'package:flutter/material.dart';

class SignInLoginLink extends StatelessWidget {
  final VoidCallback onPressed;

  const SignInLoginLink({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: RichText(
          text: const TextSpan(
            text: '계정이 이미 있으신가요? ',
            style: TextStyle(
              color: Color(0xFF47546F),
              fontSize: 14,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: '로그인',
                style: TextStyle(
                  color: Color(0xFF2B4184),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

