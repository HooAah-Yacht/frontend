import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      leadingWidth: 56,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        defaultTargetPlatform == TargetPlatform.iOS ? 44.0 : 56.0,
      );
}

