import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import '../../common/custom_button.dart';
import '../../common/custom_date_picker.dart';
import '../../common/custom_text_field.dart';
import '../../common/part_file_list_item.dart';
import '../../../models/yacht_part.dart';

class CreateYachtPartsRegistrationSection extends StatelessWidget {
  const CreateYachtPartsRegistrationSection({
    super.key,
    required this.onPartAdded,
    required this.onPartRemoved,
    required this.parts,
  });

  final ValueChanged<YachtPart> onPartAdded;
  final ValueChanged<YachtPart> onPartRemoved;
  final List<YachtPart> parts;

  void _showAddBottomSheet(BuildContext context) {
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
        return _CreateYachtPartBottomSheet(
          onSubmit: (data) {
            debugPrint('장비명: ${data.equipmentName}');
            debugPrint('제조사명: ${data.manufacturerName}');
            debugPrint('모델명: ${data.modelName}');
            debugPrint(
              '최근 정비일: ${data.latestMaintenanceDate.year}년 ${data.latestMaintenanceDate.month}월 ${data.latestMaintenanceDate.day}일',
            );
            debugPrint('정비 주기: ${data.maintenancePeriodInMonths}');
            Navigator.of(sheetContext).pop();
            onPartAdded(
              YachtPart(
                equipmentName: data.equipmentName,
                manufacturerName: data.manufacturerName,
                modelName: data.modelName,
                latestMaintenanceDate: data.latestMaintenanceDate,
                maintenancePeriodInMonths: data.maintenancePeriodInMonths,
              ),
            );
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
                '부품 등록',
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: -0.5,
                  color: Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showAddBottomSheet(context),
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
        if (parts.isEmpty)
          const Center(
            child: Text(
              '등록된 부품이 없어요\n필요할 때 언제든 추가할 수 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                letterSpacing: -0.5,
                color: Color(0xFF47546F),
              ),
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < parts.length; i++) ...[
                PartFileListItem(
                  equipmentName: parts[i].equipmentName,
                  manufacturerName: parts[i].manufacturerName,
                  modelName: parts[i].modelName,
                  onRemove: () => onPartRemoved(parts[i]),
                ),
                if (i != parts.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
      ],
    );
  }
}

class _CreateYachtPartBottomSheet extends StatefulWidget {
  const _CreateYachtPartBottomSheet({
    required this.onSubmit,
  });

  final ValueChanged<_PartFormData> onSubmit;

  @override
  State<_CreateYachtPartBottomSheet> createState() =>
      _CreateYachtPartBottomSheetState();
}

class _CreateYachtPartBottomSheetState
    extends State<_CreateYachtPartBottomSheet> {
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _cycleController = TextEditingController();
  DateTime? _selectedDate;

  final ValueNotifier<String?> _equipmentError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _manufacturerError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _modelError = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _equipmentController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _cycleController.dispose();
    _equipmentError.dispose();
    _manufacturerError.dispose();
    _modelError.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final equipment = _equipmentController.text.trim();
    final manufacturer = _manufacturerController.text.trim();
    final model = _modelController.text.trim();
    final period = _cycleController.text.trim();

    _equipmentError.value =
        equipment.isEmpty ? '장비명을 입력해주세요' : null;
    _manufacturerError.value =
        manufacturer.isEmpty ? '제조사명을 입력해주세요' : null;
    _modelError.value =
        model.isEmpty ? '모델명을 입력해주세요' : null;

    if (_equipmentError.value != null ||
        _manufacturerError.value != null ||
        _modelError.value != null) {
      return;
    }

    final maintenanceDate = _selectedDate ?? DateTime.now();
    final maintenancePeriod = period.isEmpty ? 12 : int.parse(period);

    widget.onSubmit(
      _PartFormData(
        equipmentName: equipment,
        manufacturerName: manufacturer,
        modelName: model,
        latestMaintenanceDate: maintenanceDate,
        maintenancePeriodInMonths: maintenancePeriod,
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
                    controller: _equipmentController,
                    hintText: '장비명',
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String?>(
                    valueListenable: _equipmentError,
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
                  CustomTextField(
                    controller: _manufacturerController,
                    hintText: '제조사명',
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String?>(
                    valueListenable: _manufacturerError,
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
                  CustomTextField(
                    controller: _modelController,
                    hintText: '모델명',
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String?>(
                    valueListenable: _modelError,
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
                    hintText: '최근 정비일',
                    selectedDate: _selectedDate,
                    onChanged: (date) {
                      setState(() {
                        _selectedDate = DateTime(date.year, date.month, date.day);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _cycleController,
                    hintText: '정비 주기 (ex. 1년일 경우 숫자 12 작성)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

class _PartFormData {
  const _PartFormData({
    required this.equipmentName,
    required this.manufacturerName,
    required this.modelName,
    required this.latestMaintenanceDate,
    required this.maintenancePeriodInMonths,
  });

  final String equipmentName;
  final String manufacturerName;
  final String modelName;
  final DateTime latestMaintenanceDate;
  final int maintenancePeriodInMonths;
}



