import 'package:flutter/widgets.dart';

import '../../common/page_title.dart';

class CreateYachtPageTitle extends StatelessWidget {
  const CreateYachtPageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTitle(
      firstLine: '요트를 등록하고',
      secondLine: '편하게 관리해보세요',
    );
  }
}


