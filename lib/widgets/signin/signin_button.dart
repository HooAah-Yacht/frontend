import 'package:flutter/material.dart';
import '../common/custom_button.dart';

class SignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const SignInButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: CustomButton(
        text: '회원가입',
        onPressed: isEnabled ? onPressed : () {},
      ),
    );
  }
}

