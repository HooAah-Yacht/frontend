import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String name;
  final String manufacturer;
  final String model;
  final String scheduledDate; // 점검 예정일 (ISO 8601 문자열)
  final String? createdAt; // 알림 생성 날짜 (ISO 8601 문자열, 선택적)
  final int? bgColor; // 배경색 (선택적, 기본값: 0xFFF5F5F5)

  const NotificationItem({
    super.key,
    required this.name,
    required this.manufacturer,
    required this.model,
    required this.scheduledDate,
    this.createdAt,
    this.bgColor,
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

  // 날짜를 yyyy.mm.dd 포맷으로 변환
  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      print('날짜 포맷팅 오류: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = _calculateDaysRemaining(scheduledDate);
    final isPast = daysRemaining < 0;
    final daysText = isPast ? '${-daysRemaining}일 지났어요' : '$daysRemaining일 남았어요';
    
    return Container(
      decoration: BoxDecoration(
        color: Color(bgColor ?? 0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
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
                const TextSpan(text: '의 '),
                TextSpan(
                  text: '점검 예정일이 $daysText',
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatDate(createdAt),
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: -0.5,
                color: Color(0xFF47546F),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

