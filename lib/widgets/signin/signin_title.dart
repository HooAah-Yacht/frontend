import 'package:flutter/material.dart';
import '../common/page_title.dart';

class SignInTitle extends StatelessWidget {
  const SignInTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTitle(
      firstLine: '간단하게 가입하고',
      secondLine: '당신의 요트를 관리해보세요',
    );
  }
}

