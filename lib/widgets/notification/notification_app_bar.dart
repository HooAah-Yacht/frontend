import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_app_bar.dart';

class NotificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomAppBar(title: '알림');
  }

  @override
  Size get preferredSize => const CustomAppBar(title: '').preferredSize;
}

