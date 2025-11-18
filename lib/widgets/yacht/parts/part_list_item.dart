import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/utils/part_repair_status.dart';
import 'package:frontend/screens/part_detail_screen.dart';

class PartListItem extends StatelessWidget {
  final int partId;
  final String name;
  final String manufacturer;
  final String model;
  final String? lastRepairStr;
  final int? interval;
  final VoidCallback? onPartUpdated;
  final VoidCallback? onPartDeleted;

  const PartListItem({
    super.key,
    required this.partId,
    required this.name,
    required this.manufacturer,
    required this.model,
    this.lastRepairStr,
    this.interval,
    this.onPartUpdated,
    this.onPartDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final status = PartRepairStatusCalculator.calculateStatus(lastRepairStr, interval);
    
    // 기본값 설정 (status가 null인 경우)
    final bgColor = status?.bgColor ?? 0xFFF5F5F5;
    final iconPath = status?.iconPath ?? 'assets/image/good_icon.png';
    final title = status?.title ?? '정비 정보 없음';

    // 최근 정비일 포맷팅
    String lastRepairText = '최근 정비일: -';
    final lastRepairStrValue = lastRepairStr;
    if (lastRepairStrValue != null) {
      try {
        final lastRepair = DateTime.parse(lastRepairStrValue);
        lastRepairText = '최근 정비일: ${lastRepair.year}.${lastRepair.month.toString().padLeft(2, '0')}.${lastRepair.day.toString().padLeft(2, '0')}';
      } catch (e) {
        lastRepairText = '최근 정비일: -';
      }
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PartDetailScreen(
              partId: partId,
              name: name,
              manufacturer: manufacturer,
              model: model,
              lastRepairStr: lastRepairStr,
              interval: interval,
              onPartUpdated: onPartUpdated,
              onPartDeleted: onPartDeleted,
            ),
          ),
        );
        
        // 삭제된 경우 콜백 호출
        if (result == true) {
          onPartDeleted?.call();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(bgColor),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
          // 왼쪽: 아이콘 + 제목 + 부품 정보 + 최근 정비일
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 아이콘과 제목
                Row(
                  children: [
                    Image.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 부품 정보
                Text(
                  '[$name] $manufacturer $model',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 최근 정비일
                Text(
                  lastRepairText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF47546F),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 오른쪽: 화살표 아이콘 (검정색, 오른쪽을 가리키도록 회전)
          Transform.rotate(
            angle: -1.5708, // -90도 회전 (라디안: -π/2)
            child: SvgPicture.asset(
              'assets/image/arrow_icon.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

