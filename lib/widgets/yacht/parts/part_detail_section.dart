import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PartDetailSection extends StatelessWidget {
  final String name;
  final String manufacturer;
  final String model;
  final String? lastRepairStr;
  final int? interval;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PartDetailSection({
    super.key,
    required this.name,
    required this.manufacturer,
    required this.model,
    this.lastRepairStr,
    this.interval,
    this.onDelete,
    this.onEdit,
  });

  String _formatLastRepairDate(String? lastRepairStr) {
    if (lastRepairStr == null) {
      return '-';
    }
    try {
      final date = DateTime.parse(lastRepairStr);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF47546F),
          width: 1,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // 위 박스: 부품 정보
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                _buildLabelValue(
                  label: '장비명',
                  value: name,
                ),
                const SizedBox(height: 20),
                _buildLabelValue(
                  label: '제조사명',
                  value: manufacturer,
                ),
                const SizedBox(height: 20),
                _buildLabelValue(
                  label: '모델명',
                  value: model,
                ),
                const SizedBox(height: 20),
                _buildLabelValue(
                  label: '최근 정비일',
                  value: _formatLastRepairDate(lastRepairStr),
                ),
                const SizedBox(height: 20),
                _buildLabelValue(
                  label: '정비 주기',
                  value: interval != null ? '$interval개월' : '-',
                ),
              ],
            ),
            ),
          ),
          // 아래 박스: 버튼들
          Row(
            children: [
              // 왼쪽 버튼: 부품 삭제
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFF2B4184),
                        width: 1,
                      ),
                    ),
                  ),
                  child: OutlinedButton(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2B4184),
                      side: BorderSide.none,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/image/cancel_icon.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF2B4184),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '부품 삭제',
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 오른쪽 버튼: 부품 정보 수정
              Expanded(
                child: ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B4184),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/image/tool_icon.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '부품 정보 수정',
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

