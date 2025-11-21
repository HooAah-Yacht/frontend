import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';
import 'package:frontend/widgets/yacht/parts/part_detail_section.dart';
import 'package:frontend/widgets/yacht/parts/repair_history_section.dart';
import 'package:frontend/widgets/yacht/parts/edit_part_bottom_sheet.dart';
import 'package:frontend/services/part_service.dart';

class PartDetailScreen extends StatefulWidget {
  final int partId;
  final String name;
  final String manufacturer;
  final String model;
  final String? lastRepairStr;
  final int? interval;
  final VoidCallback? onPartUpdated;
  final VoidCallback? onPartDeleted;

  const PartDetailScreen({
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
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  late String _currentName;
  late String _currentManufacturer;
  late String _currentModel;
  late int? _currentInterval;
  String? _currentLastRepairStr;
  final GlobalKey<RepairHistorySectionState> _repairHistoryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentName = widget.name;
    _currentManufacturer = widget.manufacturer;
    _currentModel = widget.model;
    _currentInterval = widget.interval;
    _currentLastRepairStr = widget.lastRepairStr;
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          '정말 삭제하시겠습니까?',
          style: TextStyle(
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              '취소',
              style: TextStyle(
                letterSpacing: -0.5,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(
                letterSpacing: -0.5,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await PartService.deletePart(widget.partId);
      
      if (!mounted) return;

      if (result['success'] == true) {
        CustomSnackBar.showSuccess(
          context,
          message: result['message'] as String? ?? '부품이 삭제되었습니다.',
        );
        widget.onPartDeleted?.call();
        Navigator.of(context).pop(true);
      } else {
        CustomSnackBar.showError(
          context,
          message: result['message'] as String? ?? '부품 삭제에 실패했습니다.',
        );
      }
    }
  }

  void _handleEdit() {
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
        return EditPartBottomSheet(
          partId: widget.partId,
          initialName: _currentName,
          initialManufacturer: _currentManufacturer,
          initialModel: _currentModel,
          initialInterval: _currentInterval ?? 0,
          onSubmit: (name, manufacturer, model, interval) async {
            final result = await PartService.updatePart(
              partId: widget.partId,
              name: name,
              manufacturer: manufacturer,
              model: model,
              interval: interval,
            );

            if (!mounted) return;

            if (result['success'] == true) {
              setState(() {
                _currentName = name;
                _currentManufacturer = manufacturer;
                _currentModel = model;
                _currentInterval = interval;
              });

              // 정비 이력 새로고침
              _repairHistoryKey.currentState?.loadRepairList();

              CustomSnackBar.showSuccess(
                context,
                message: result['message'] as String? ?? '부품 정보가 수정되었습니다.',
              );

              widget.onPartUpdated?.call();
            } else {
              CustomSnackBar.showError(
                context,
                message: result['message'] as String? ?? '부품 수정에 실패했습니다.',
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        leadingWidth: 56,
        title: const Text(
          '부품 관리',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            PartDetailSection(
              name: _currentName,
              manufacturer: _currentManufacturer,
              model: _currentModel,
              lastRepairStr: _currentLastRepairStr,
              interval: _currentInterval,
              onDelete: _handleDelete,
              onEdit: _handleEdit,
            ),
            const SizedBox(height: 40),
            RepairHistorySection(
              key: _repairHistoryKey,
              partId: widget.partId,
            ),
          ],
        ),
      ),
    );
  }
}

