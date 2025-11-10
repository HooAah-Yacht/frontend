import 'package:flutter/material.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class SignInInputFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback? onEmailDuplicateCheck;
  final bool isEmailVerified;
  final bool isEmailChecking;
  final String? emailStatusMessage;
  final Color? emailStatusColor;

  const SignInInputFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.onEmailDuplicateCheck,
    this.isEmailVerified = false,
    this.isEmailChecking = false,
    this.emailStatusMessage,
    this.emailStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isEmailVerified || isEmailChecking;
    final String buttonText = isEmailVerified
        ? '확인완료'
        : isEmailChecking
            ? '확인중'
            : '중복확인';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: nameController,
          hintText: '이름',
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: emailController,
                hintText: '이메일',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(width: 8),
            CustomButton(
              text: buttonText,
              onPressed: isButtonDisabled
                  ? () {}
                  : (onEmailDuplicateCheck ?? () {}),
              width: 100,
            ),
          ],
        ),
        if (emailStatusMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              emailStatusMessage!,
              style: TextStyle(
                fontSize: 14,
                letterSpacing: -0.5,
                color: emailStatusColor ?? const Color(0xFF47546F),
              ),
            ),
          ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: passwordController,
          hintText: '비밀번호',
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(height: 8),
        const Text(
          '6-20자/영문 소문자, 특수문자 조합',
          style: TextStyle(
            color: Color(0xFF47546F),
            fontSize: 14,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: confirmPasswordController,
          hintText: '비밀번호 확인',
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),
      ],
    );
  }
}

