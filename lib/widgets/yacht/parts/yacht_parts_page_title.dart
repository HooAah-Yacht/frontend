import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/page_title.dart';

class YachtPartsPageTitle extends StatelessWidget {
  const YachtPartsPageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTitle(
      firstLine: '부품을 등록하고',
      secondLine: '쉽게 관리해보세요',
    );
  }
}

