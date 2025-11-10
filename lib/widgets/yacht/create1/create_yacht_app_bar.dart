import 'package:flutter/widgets.dart';

import '../../common/custom_app_bar.dart';

class CreateYachtAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreateYachtAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomAppBar(
      title: '요트 등록하기',
    );
  }

  @override
  Size get preferredSize =>
      const CustomAppBar(title: '요트 등록하기').preferredSize;
}


