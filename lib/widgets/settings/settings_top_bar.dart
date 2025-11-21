import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_app_bar.dart';

class SettingsTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomAppBar(title: '설정');
  }

  @override
  Size get preferredSize => const CustomAppBar(title: '').preferredSize;
}

