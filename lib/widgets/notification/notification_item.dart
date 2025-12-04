import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String name;
  final String manufacturer;
  final String model;
  final String scheduledDate; // 점검 예정일 (ISO 8601 문자열)

  const NotificationItem({
    super.key,
    required this.name,
    required this.manufacturer,
    required this.model,
    required this.scheduledDate,
  });

  // 오늘 날짜와 예정일의 차이를 계산하여 일수 반환
  int _calculateDaysRemaining(String scheduledDateStr) {
    try {
      final now = DateTime.now();
      final scheduled = DateTime.parse(scheduledDateStr).toLocal();
      final difference = scheduled.difference(now).inDays;
      return difference;
    } catch (e) {
      print('날짜 파싱 오류: $e');
      return 0;
    }
  }


  @override
  Widget build(BuildContext context) {
    final daysRemaining = _calculateDaysRemaining(scheduledDate);
    final isPast = daysRemaining < 0;
    final daysText = isPast ? '${-daysRemaining}일 지났어요' : '$daysRemaining일 남았어요';
    
    return Container(
      decoration: BoxDecoration(
        color: isPast ? const Color(0xFFECC8C4) : const Color(0xFFF8F3D6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: '[$name] $manufacturer $model',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '의 점검 예정일이 $daysText',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

