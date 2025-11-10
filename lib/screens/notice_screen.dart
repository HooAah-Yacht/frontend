import 'package:flutter/material.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '알림 페이지',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}


