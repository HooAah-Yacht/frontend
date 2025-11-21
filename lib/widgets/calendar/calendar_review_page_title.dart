import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/page_title.dart';

class CalendarReviewPageTitle extends StatelessWidget {
  const CalendarReviewPageTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageTitle(
      firstLine: '일정을 마치셨나요?',
      secondLine: '후기를 남겨주세요',
    );
  }
}

