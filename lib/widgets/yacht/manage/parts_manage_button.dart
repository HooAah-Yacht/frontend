import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PartsManageButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const PartsManageButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF47546F),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 28),
        elevation: 0,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/image/tool_icon.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              '부품 관리',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: -0.5,
                color: Colors.black,
              ),
            ),
          ),
          Transform.rotate(
            angle: -1.5708, // -90도 회전 (오른쪽 화살표)
            child: SvgPicture.asset(
              'assets/image/arrow_icon.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

