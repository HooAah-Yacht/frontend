import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/bottom_navigation.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';
import 'package:frontend/screens/yacht_manage_screen.dart';
import 'package:frontend/screens/calendar_screen.dart';
import 'package:frontend/services/yacht_service.dart';

class NavigationHelper {
  static void handleTabSelection(
    BuildContext context,
    HooaahTab tab,
    HooaahTab currentTab,
  ) async {
    // 현재 탭이면 아무것도 하지 않음
    if (tab == currentTab) {
      return;
    }

    // 홈 탭
    if (tab == HooaahTab.home) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    // 요트 탭
    if (tab == HooaahTab.yacht) {
      // 요트 리스트 확인
      final yachtList = await YachtService.getYachtList();
      if (yachtList.isEmpty) {
        if (context.mounted) {
          CustomSnackBar.showError(
            context,
            message: '등록된 요트가 없습니다.',
          );
        }
        return;
      }
      // 리스트가 있으면 요트 관리 화면으로 이동
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const YachtManageScreen(),
          ),
        );
      }
      return;
    }

    // 캘린더 탭
    if (tab == HooaahTab.calendar) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CalendarScreen(),
          ),
        );
      }
      return;
    }

    // 기타 탭
    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: '해당 기능은 준비 중입니다.',
      );
    }
  }
}

