import 'package:flutter/material.dart';

import '../../common/part_detail_tile.dart';

class RecommendedPartsList extends StatelessWidget {
  const RecommendedPartsList({super.key});

  static const List<_RecommendedPart> _dummyParts = [
    _RecommendedPart(
      partName: '임펠러',
      manufacturerName: '야마하',
      modelName: '6CE-44352-00 IMPELLER',
    ),
    _RecommendedPart(
      partName: '기어오일',
      manufacturerName: '야마하',
      modelName: 'GL-4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 261,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dummyParts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final part = _dummyParts[index];
          return PartDetailTile(
            partName: part.partName,
            manufacturerName: part.manufacturerName,
            modelName: part.modelName,
          );
        },
      ),
    );
  }
}

class _RecommendedPart {
  const _RecommendedPart({
    required this.partName,
    required this.manufacturerName,
    required this.modelName,
  });

  final String partName;
  final String manufacturerName;
  final String modelName;
}


