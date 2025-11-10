import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_button.dart';

class HomeRegisterYachtButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HomeRegisterYachtButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: '요트 등록하기',
      onPressed: onPressed,
    );
  }
}


