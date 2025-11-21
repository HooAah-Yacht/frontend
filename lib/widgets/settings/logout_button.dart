import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? width;

  const LogoutButton({
    super.key,
    this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF47546F),
          side: const BorderSide(
            color: Color(0xFF47546F),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
        ),
        child: const Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 16,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

