import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/common/custom_button.dart';
import 'package:frontend/widgets/common/custom_date_picker.dart';
import 'package:frontend/widgets/common/custom_text_field.dart';

class AddPartBottomSheet extends StatefulWidget {
  final Function(String name, String manufacturer, String model, DateTime? lastRepairDate, int interval) onSubmit;

  const AddPartBottomSheet({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AddPartBottomSheet> createState() => _AddPartBottomSheetState();
}

class _AddPartBottomSheetState extends State<AddPartBottomSheet> {
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

    final maintenanceDate = _selectedDate;
    final maintenancePeriod = period.isEmpty ? 12 : int.parse(period);

    // 확인 dialog 표시
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          '부품을 추가하시겠습니까?',
          style: TextStyle(
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              '취소',
              style: TextStyle(
                letterSpacing: -0.5,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
              widget.onSubmit(equipment, manufacturer, model, maintenanceDate, maintenancePeriod);
            },
            child: const Text(
              '추가',
              style: TextStyle(
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
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
                    text: '추가하기',
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

