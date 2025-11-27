import 'package:flutter/material.dart';

class CalendarInfoList extends StatelessWidget {
  final String yachtName;
  final String? yachtNickName;
  final String type;
  final Map<String, dynamic>? selectedPart;
  final bool completed;
  final String? review;

  const CalendarInfoList({
    super.key,
    required this.yachtName,
    this.yachtNickName,
    required this.type,
    this.selectedPart,
    required this.completed,
    this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelValue(
          label: '요트',
          value: yachtNickName != null && yachtNickName!.isNotEmpty
              ? '[$yachtName] $yachtNickName'
              : yachtName,
        ),
        const SizedBox(height: 20),
        _buildLabelValue(
          label: '일정 타입',
          value: type,
        ),
        if (type == '정비' && selectedPart != null) ...[
          const SizedBox(height: 20),
          Builder(
            builder: (context) {
              final part = selectedPart!;
              final name = part['name'] as String? ?? '';
              final manufacturer = part['manufacturer'] as String? ?? '';
              final model = part['model'] as String? ?? '';
              return _buildLabelValue(
                label: '부품명',
                value: '[$name] $manufacturer $model',
              );
            },
          ),
        ],
        const SizedBox(height: 20),
        _buildLabelValue(
          label: '참조인',
          value: '참조인이 존재하지 않습니다.',
        ),
        if (completed) ...[
          const SizedBox(height: 20),
          _buildLabelValue(
            label: '리뷰',
            value: review != null && review!.isNotEmpty
                ? review!
                : '등록된 리뷰가 없습니다.',
          ),
        ],
      ],
    );
  }

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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

