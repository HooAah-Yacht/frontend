import 'package:flutter/widgets.dart';

import '../../common/page_title.dart';

class CreateYachtPartsPageTitle extends StatelessWidget {
  const CreateYachtPartsPageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTitle(
      firstLine: '내 요트에 필요한 부품만',
      secondLine: '직접 관리해요',
    );
  }
}


