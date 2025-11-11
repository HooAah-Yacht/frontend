import 'package:flutter/material.dart';

class PartDetailTile extends StatelessWidget {
  const PartDetailTile({
    super.key,
    required this.partName,
    required this.manufacturerName,
    required this.modelName,
  });

  final String partName;
  final String manufacturerName;
  final String modelName;

  Widget _buildLabelValue({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: -0.5,
            color: Color(0xFF47546F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 214,
      height: 261,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF47546F),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelValue(
            label: '장비명',
            value: partName,
          ),
          const SizedBox(height: 20),
          _buildLabelValue(
            label: '제조사명',
            value: manufacturerName,
          ),
          const SizedBox(height: 20),
          _buildLabelValue(
            label: '모델명',
            value: modelName,
          ),
        ],
      ),
    );
  }
}


