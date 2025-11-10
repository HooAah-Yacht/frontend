import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DocumentFileListItem extends StatelessWidget {
  const DocumentFileListItem({
    super.key,
    required this.fileName,
    required this.onRemove,
  });

  final String fileName;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/image/document_icon.svg',
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
            fileName,
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


