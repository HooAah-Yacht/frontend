import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PartFileListItem extends StatelessWidget {
  const PartFileListItem({
    super.key,
    required this.equipmentName,
    required this.manufacturerName,
    required this.modelName,
    required this.onRemove,
  });

  final String equipmentName;
  final String manufacturerName;
  final String modelName;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/image/tool_icon.svg',
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Color(0xFF47546F),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '[$equipmentName] $manufacturerName $modelName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onRemove,
          child: SvgPicture.asset(
            'assets/image/cancel_icon.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Color(0xFF47546F),
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}


