import 'package:flutter/material.dart';

class CalendarDateSection extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const CalendarDateSection({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isSameDay = startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSameDay
              ? _formatDate(startDate)
              : '${_formatDate(startDate)} ~ ${_formatDate(endDate)}',
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_formatTime(startDate)} ~ ${_formatTime(endDate)}',
          style: const TextStyle(
            fontSize: 14,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

