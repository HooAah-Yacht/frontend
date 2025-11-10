import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_button.dart';

class AuthLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthLoginButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: '로그인',
      onPressed: onPressed ?? () {},
    );
  }
}

