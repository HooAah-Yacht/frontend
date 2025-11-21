import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_app_bar.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';
import 'package:frontend/widgets/yacht/parts/yacht_parts_page_title.dart';
import 'package:frontend/widgets/yacht/parts/part_list_item.dart';
import 'package:frontend/widgets/yacht/parts/add_part_button.dart';
import 'package:frontend/widgets/yacht/parts/add_part_bottom_sheet.dart';
import 'package:frontend/services/part_service.dart';

class YachtPartScreen extends StatefulWidget {
  final int yachtId;
  final VoidCallback? onPartAdded;

  const YachtPartScreen({
    super.key,
    required this.yachtId,
    this.onPartAdded,
  });

  @override
  State<YachtPartScreen> createState() => _YachtPartScreenState();
}

class _YachtPartScreenState extends State<YachtPartScreen> {
  List<Map<String, dynamic>> _partList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartList();
  }

  Future<void> _loadPartList() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final partList = await PartService.getPartListByYacht(widget.yachtId);
      
      print('요트 ID ${widget.yachtId}의 부품 리스트 로드 성공:');
      print('부품 개수: ${partList.length}');
      
      for (var part in partList) {
        final name = part['name'];
        final manufacturer = part['manufacturer'];
        final model = part['model'];
        final interval = (part['interval'] as num?)?.toInt();
        final lastRepairStr = part['lastRepair'] as String?;
        
        print('부품: $name, 제조사: $manufacturer, 모델: $model, 주기: $interval, 마지막 정비일: $lastRepairStr');
      }

      setState(() {
        _partList = partList;
        _isLoading = false;
      });
    } catch (e) {
      print('부품 리스트 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddPartBottomSheet(BuildContext context) {
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
        return AddPartBottomSheet(
          onSubmit: (name, manufacturer, model, lastRepairDate, interval) async {
            final result = await PartService.addPart(
              yachtId: widget.yachtId,
              name: name,
              manufacturer: manufacturer,
              model: model,
              interval: interval,
              lastRepair: lastRepairDate,
            );

            if (!mounted) return;

            if (result['success'] == true) {
              CustomSnackBar.showSuccess(
                context,
                message: result['message'] as String? ?? '부품이 추가되었습니다.',
              );
              // 부품 리스트 새로고침
              _loadPartList();
              // 부품 등록 성공 시 캘린더 새로고침 콜백 호출
              widget.onPartAdded?.call();
            } else {
              CustomSnackBar.showError(
                context,
                message: result['message'] as String? ?? '부품 추가에 실패했습니다.',
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: '부품 관리'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const YachtPartsPageTitle(),
                  const SizedBox(height: 40),
                  const Text(
                    '부품 목록',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ..._partList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final part = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < _partList.length - 1 ? 12 : 0),
                        child: PartListItem(
                          partId: (part['id'] as num?)?.toInt() ?? 0,
                          name: part['name'] ?? '',
                          manufacturer: part['manufacturer'] ?? '',
                          model: part['model'] ?? '',
                          lastRepairStr: part['lastRepair'] as String?,
                          interval: (part['interval'] as num?)?.toInt(),
                          onPartUpdated: () {
                            _loadPartList();
                          },
                          onPartDeleted: () {
                            _loadPartList();
                          },
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          AddPartButton(
            onPressed: () => _showAddPartBottomSheet(context),
          ),
        ],
      ),
    );
  }
}

