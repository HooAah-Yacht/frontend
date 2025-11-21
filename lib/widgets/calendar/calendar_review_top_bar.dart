import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_app_bar.dart';

class CalendarReviewTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CalendarReviewTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomAppBar(title: '일정 후기');
  }

  @override
  Size get preferredSize => const CustomAppBar(title: '').preferredSize;
}

