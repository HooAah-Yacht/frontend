import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateYachtPartsRegistrationSection extends StatelessWidget {
  const CreateYachtPartsRegistrationSection({
    super.key,
    this.parts = const [],
    this.onAddParts,
  });

  final List<String> parts;
  final VoidCallback? onAddParts;

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Text(
              '안녕하세요',
              style: TextStyle(
                fontSize: 18,
                letterSpacing: -0.5,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      onAddParts?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasParts = parts.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                '부품 등록',
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: -0.5,
                  color: Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showAddBottomSheet(context),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B4184),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/image/plus_icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!hasParts)
          const Center(
            child: Text(
              '등록된 부품이 없어요\n필요할 때 언제든 추가할 수 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                letterSpacing: -0.5,
                color: Color(0xFF47546F),
              ),
            ),
          )
        else
          Column(
            children: parts
                .map(
                  (part) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      part,
                      style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: -0.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}


