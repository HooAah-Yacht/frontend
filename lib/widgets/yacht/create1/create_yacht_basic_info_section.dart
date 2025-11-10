import 'package:flutter/material.dart';

import '../../common/custom_picker.dart';
import '../../common/custom_text_field.dart';

class CreateYachtBasicInfoSection extends StatelessWidget {
  const CreateYachtBasicInfoSection({
    super.key,
    required this.selectedYacht,
    required this.onYachtSelected,
    required this.aliasController,
  });

  final String? selectedYacht;
  final ValueChanged<String> onYachtSelected;
  final TextEditingController aliasController;

  static const List<String> _dummyYachts = [
    'FarEast 28',
    'Farr 40',
    'Benetaur 473',
    'J/24',
    'Laser',
    'Swan 50',
    'X-35',
    'Melges 32',
    'TP52',
    'Beneteau First 36',
    'Jeanneau Sun Fast 3300',
    'Dehler 38',
    'X-Yachts XP 44',
    'Hanse 458',
    'Beneteau Oceanis 46',
    'Nautor Swan 48',
    'Grand Soleil GC 42',
    'RS21',
    'J/70',
    'Solaris 44',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '요트 기본 정보',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        CustomPicker(
          hintText: '요트를 선택해주세요',
          items: _dummyYachts,
          selectedValue: selectedYacht,
          onSelected: onYachtSelected,
        ),
        const SizedBox(height: 16),
        const Text(
          '요트 별칭',
          style: TextStyle(
            fontSize: 16,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: aliasController,
          hintText: '요트 별칭',
        ),
        const SizedBox(height: 8),
        const Text(
          '별칭이 없으면 요트 이름으로 자동 저장돼요',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: -0.5,
            color: Color(0xFF47546F),
          ),
        ),
      ],
    );
  }
}

