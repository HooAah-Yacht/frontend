import 'package:flutter/material.dart';
import 'package:frontend/screens/calendar_detail_screen.dart';

class CalendarEventItem extends StatelessWidget {
  const CalendarEventItem({
    super.key,
    required this.type,
    required this.content,
    required this.startDate,
    required this.endDate,
    required this.completed,
    this.calendarData,
    this.onDeleted,
    this.onUpdated,
  });

  final String type;
  final String content;
  final DateTime startDate;
  final DateTime endDate;
  final bool completed;
  final Map<String, dynamic>? calendarData;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getTypeDisplayText() {
    if (type == '정비' && calendarData != null) {
      final partId = calendarData!['partId'] as int?;
      final partList = calendarData!['partList'] as List<dynamic>?;
      
      if (partId != null && partList != null) {
        try {
          final selectedPart = partList.firstWhere(
            (part) => (part as Map<String, dynamic>)['id'] == partId,
            orElse: () => null,
          );
          
          if (selectedPart != null) {
            final partMap = selectedPart as Map<String, dynamic>;
            final partName = partMap['name'] as String? ?? '';
            return '[정비] $partName';
          }
        } catch (e) {
          // 부품을 찾지 못한 경우 기본 type 반환
        }
      }
    }
    return type;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (calendarData != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CalendarDetailScreen(
                calendarData: calendarData!,
              ),
            ),
          ).then((result) {
            // 삭제 또는 수정 시 목록 새로고침
            if (context.mounted) {
              if (result == true) {
                // 삭제 성공
                onDeleted?.call();
              } else if (result == 'updated') {
                // 수정 성공
                onUpdated?.call();
              }
            }
          });
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFDEF3D6) : const Color(0xFFF8F3D6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 좌측 박스
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // type 이름
                  Text(
                    _getTypeDisplayText(),
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // content
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 시간
                  Text(
                    '${_formatTime(startDate)} ~ ${_formatTime(endDate)}',
                    style: const TextStyle(
                      fontSize: 14,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // 우측 박스
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: completed ? const Color(0xFF87C149) : const Color(0xFFF2C538),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    completed ? '완료' : '진행전',
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

