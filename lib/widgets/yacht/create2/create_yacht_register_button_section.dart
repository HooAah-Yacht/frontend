import 'package:flutter/material.dart';

import '../../common/custom_button.dart';

class CreateYachtRegisterButtonSection extends StatelessWidget {
  const CreateYachtRegisterButtonSection({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 116,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00FFFFFF),
            Color(0x00FFFFFF),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.17, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: CustomButton(
            text: '등록하기',
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}


