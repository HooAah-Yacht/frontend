import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/common/custom_button.dart';
import 'package:frontend/widgets/common/custom_text_field.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';

class EditPartBottomSheet extends StatefulWidget {
  final int partId;
  final String initialName;
  final String initialManufacturer;
  final String initialModel;
  final int initialInterval;
  final Function(String name, String manufacturer, String model, int interval) onSubmit;

  const EditPartBottomSheet({
    super.key,
    required this.partId,
    required this.initialName,
    required this.initialManufacturer,
    required this.initialModel,
    required this.initialInterval,
    required this.onSubmit,
  });

  @override
  State<EditPartBottomSheet> createState() => _EditPartBottomSheetState();
}

class _EditPartBottomSheetState extends State<EditPartBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _manufacturerController;
  late TextEditingController _modelController;
  late TextEditingController _intervalController;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _manufacturerController = TextEditingController(text: widget.initialManufacturer);
    _modelController = TextEditingController(text: widget.initialModel);
    _intervalController = TextEditingController(text: widget.initialInterval.toString());

    _nameController.addListener(_checkChanges);
    _manufacturerController.addListener(_checkChanges);
    _modelController.addListener(_checkChanges);
    _intervalController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final hasChanges = _nameController.text != widget.initialName ||
        _manufacturerController.text != widget.initialManufacturer ||
        _modelController.text != widget.initialModel ||
        _intervalController.text != widget.initialInterval.toString();
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final manufacturer = _manufacturerController.text.trim();
    final model = _modelController.text.trim();
    final intervalStr = _intervalController.text.trim();

    if (name.isEmpty || manufacturer.isEmpty || model.isEmpty || intervalStr.isEmpty) {
      CustomSnackBar.showError(
        context,
        message: '모든 필드를 입력해주세요.',
      );
      return;
    }

    final interval = int.tryParse(intervalStr);
    if (interval == null || interval <= 0) {
      CustomSnackBar.showError(
        context,
        message: '정비 주기는 1 이상의 숫자여야 합니다.',
      );
      return;
    }

    // 변경사항이 있으면 확인 dialog 표시
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text(
            '부품 정보를 수정하시겠습니까?',
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
                widget.onSubmit(name, manufacturer, model, interval);
              },
              child: const Text(
                '수정',
                style: TextStyle(
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 변경사항이 없으면 그냥 닫기
      Navigator.of(context).pop();
    }
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
                    controller: _nameController,
                    hintText: '장비명',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _manufacturerController,
                    hintText: '제조사명',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _modelController,
                    hintText: '모델명',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _intervalController,
                    hintText: '정비 주기 (ex. 1년일 경우 숫자 12 작성)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: '수정하기',
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

