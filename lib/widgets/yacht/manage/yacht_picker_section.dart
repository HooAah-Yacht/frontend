import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/widgets/common/custom_picker.dart';

class YachtPickerSection extends StatelessWidget {
  final List<String> yachtNames;
  final String? selectedYachtName;
  final ValueChanged<String> onYachtSelected;
  final VoidCallback onAddYacht;

  const YachtPickerSection({
    super.key,
    required this.yachtNames,
    this.selectedYachtName,
    required this.onYachtSelected,
    required this.onAddYacht,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomPicker(
            items: yachtNames,
            hintText: '요트를 선택하세요',
            selectedValue: selectedYachtName,
            onSelected: onYachtSelected,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: onAddYacht,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B4184),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/image/plus_icon.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '요트 추가',
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
    );
  }
}

