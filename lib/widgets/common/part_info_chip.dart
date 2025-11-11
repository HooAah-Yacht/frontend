import 'package:flutter/material.dart';

class PartInfoChip extends StatelessWidget {
  const PartInfoChip({
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
      children: [
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
          child: const Icon(
            Icons.close,
            size: 20,
            color: Color(0xFF47546F),
          ),
        ),
      ],
    );
  }
}
