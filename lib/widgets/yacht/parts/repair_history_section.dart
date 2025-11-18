import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/services/repair_service.dart';
import 'package:frontend/widgets/common/custom_button.dart';
import 'package:frontend/widgets/common/custom_date_picker.dart';
import 'package:frontend/widgets/common/custom_text_field.dart';

class RepairHistorySection extends StatefulWidget {
  final int partId;

  const RepairHistorySection({
    super.key,
    required this.partId,
  });

  @override
  State<RepairHistorySection> createState() => RepairHistorySectionState();
}

class RepairHistorySectionState extends State<RepairHistorySection> {
  List<Map<String, dynamic>> _repairList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRepairList();
  }

  Future<void> loadRepairList() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final repairList = await RepairService.getRepairListByPart(widget.partId);
      
      setState(() {
        _repairList = repairList;
        _isLoading = false;
      });
    } catch (e) {
      print('정비 이력 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatRepairDate(String? repairDateStr) {
    if (repairDateStr == null) {
      return '-';
    }
    try {
      final date = DateTime.parse(repairDateStr);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  String _getUserName(Map<String, dynamic>? user) {
    if (user == null) {
      return '-';
    }
    return user['name'] as String? ?? '-';
  }

  void _showAddRepairBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return _AddRepairBottomSheet(
          partId: widget.partId,
          onSubmit: (data) {
            // RepairController.addRepair 참고
            final repairData = {
              'id': data.partId,
              'date': data.repairDate.toUtc().toIso8601String(),
              'content': data.content,
            };
            
            debugPrint('정비 이력 등록 데이터:');
            repairData.forEach((key, value) {
              debugPrint('  $key: $value');
            });
            
            // TODO: API 연결
            // RepairService.addRepair 구현 필요
            // RequestRepairDto에 content 필드 추가 필요
            
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                '정비 이력',
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: -0.5,
                  color: Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showAddRepairBottomSheet(context),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B4184),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/image/plus_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_repairList.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F9FE),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: const Center(
              child: Text(
                '등록된 정비 이력이 없습니다.',
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: -0.5,
                  color: Color(0xFF47546F),
                ),
              ),
            ),
          )
        else
          ..._repairList.map((repair) {
            final user = repair['user'] as Map<String, dynamic>?;
            final repairDate = repair['repairDate'] as String?;
            final content = repair['content'] as String?;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F9FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사용자와 날짜 (양 옆 끝으로 배치)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getUserName(user),
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: -0.5,
                            color: Color(0xFF47546F),
                          ),
                        ),
                        Text(
                          _formatRepairDate(repairDate),
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: -0.5,
                            color: Color(0xFF47546F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Content (더미 또는 실제 값)
                    Text(
                      content ?? 'content',
                      style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: -0.5,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}

class _AddRepairBottomSheet extends StatefulWidget {
  const _AddRepairBottomSheet({
    required this.partId,
    required this.onSubmit,
  });

  final int partId;
  final ValueChanged<_RepairFormData> onSubmit;

  @override
  State<_AddRepairBottomSheet> createState() => _AddRepairBottomSheetState();
}

class _AddRepairBottomSheetState extends State<_AddRepairBottomSheet> {
  final TextEditingController _repairerController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime? _selectedDate;

  final ValueNotifier<String?> _repairerError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _dateError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _contentError = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _repairerController.dispose();
    _contentController.dispose();
    _repairerError.dispose();
    _dateError.dispose();
    _contentError.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final repairer = _repairerController.text.trim();
    final content = _contentController.text.trim();

    _repairerError.value = repairer.isEmpty ? '정비자를 입력해주세요' : null;
    _dateError.value = _selectedDate == null ? '정비일을 선택해주세요' : null;
    _contentError.value = content.isEmpty ? '정비내용을 입력해주세요' : null;

    if (_repairerError.value != null ||
        _dateError.value != null ||
        _contentError.value != null) {
      return;
    }

    widget.onSubmit(
      _RepairFormData(
        partId: widget.partId,
        repairer: repairer,
        repairDate: _selectedDate!,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _repairerController,
                    hintText: '정비자',
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String?>(
                    valueListenable: _repairerError,
                    builder: (context, error, _) {
                      if (error == null) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        error,
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.5,
                          color: Color(0xFFFF4D4F),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDatePicker(
                    hintText: '정비일',
                    selectedDate: _selectedDate,
                    onChanged: (date) {
                      setState(() {
                        _selectedDate = DateTime(date.year, date.month, date.day);
                        _dateError.value = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String?>(
                    valueListenable: _dateError,
                    builder: (context, error, _) {
                      if (error == null) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        error,
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.5,
                          color: Color(0xFFFF4D4F),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 112,
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: -0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: '정비내용',
                        hintStyle: const TextStyle(
                          color: Color(0xFF47546F),
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF47546F),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF2B4184),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String?>(
                    valueListenable: _contentError,
                    builder: (context, error, _) {
                      if (error == null) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        error,
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: -0.5,
                          color: Color(0xFFFF4D4F),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: '등록하기',
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: SvgPicture.asset(
                'assets/image/cancel_icon.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepairFormData {
  const _RepairFormData({
    required this.partId,
    required this.repairer,
    required this.repairDate,
    required this.content,
  });

  final int partId;
  final String repairer;
  final DateTime repairDate;
  final String content;
}

