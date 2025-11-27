import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum HooaahTab {
  home,
  yacht,
  ai,
  calendar,
  settings,
  none, // 알림 화면 등에서 사용 (어떤 탭도 활성화되지 않음)
}

class HooaahBottomNavigation extends StatelessWidget {
  final HooaahTab currentTab;
  final ValueChanged<HooaahTab>? onTabSelected;

  const HooaahBottomNavigation({
    super.key,
    required this.currentTab,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kBottomNavigationBarHeight + 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFB0B8C1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NavigationItem(
            assetPath: 'assets/image/home_icon.svg',
            label: '홈',
            isActive: currentTab == HooaahTab.home,
            onTap: () => onTabSelected?.call(HooaahTab.home),
          ),
          const SizedBox(width: 44),
          _NavigationItem(
            assetPath: 'assets/image/yacht_icon.svg',
            label: '요트',
            isActive: currentTab == HooaahTab.yacht,
            onTap: () => onTabSelected?.call(HooaahTab.yacht),
          ),
          const SizedBox(width: 44),
          _NavigationItem(
            assetPath: 'assets/image/ai_icon.svg',
            label: 'AI',
            isActive: currentTab == HooaahTab.ai,
            onTap: () => onTabSelected?.call(HooaahTab.ai),
          ),
          const SizedBox(width: 44),
          _NavigationItem(
            assetPath: 'assets/image/calendar_icon.svg',
            label: '달력',
            isActive: currentTab == HooaahTab.calendar,
            onTap: () => onTabSelected?.call(HooaahTab.calendar),
          ),
          const SizedBox(width: 44),
          _NavigationItem(
            assetPath: 'assets/image/settings_icon.svg',
            label: '설정',
            isActive: currentTab == HooaahTab.settings,
            onTap: () => onTabSelected?.call(HooaahTab.settings),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final String assetPath;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavigationItem({
    required this.assetPath,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? Colors.black : const Color(0xFFB0B8C1);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              letterSpacing: -0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


