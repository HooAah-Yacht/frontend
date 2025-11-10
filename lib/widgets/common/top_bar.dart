import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HooaahTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HooaahTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/hooaah_logo.png',
              width: 80,
              height: 23,
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/notice');
              },
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                'assets/image/notice_icon.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


