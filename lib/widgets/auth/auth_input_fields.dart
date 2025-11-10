import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_text_field.dart';

class AuthInputFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const AuthInputFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: emailController,
          hintText: '이메일',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: passwordController,
          hintText: '비밀번호',
          obscureText: true,
        ),
      ],
    );
  }
}

