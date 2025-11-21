import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/bottom_navigation.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';
import 'package:frontend/screens/home_screen.dart' show HomeScreenContent;
import 'package:frontend/screens/yacht_manage_screen.dart' show YachtManageScreenContent;
import 'package:frontend/screens/calendar_screen.dart' show CalendarScreenContent;
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/services/yacht_service.dart';

// MainScreen에 접근하기 위한 GlobalKey
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  HooaahTab _currentTab = HooaahTab.home;
  List<Map<String, dynamic>> _yachtList = [];
  String? _selectedYachtNameForNavigation;
  VoidCallback? _calendarRefreshCallback;

  @override
  void initState() {
    super.initState();
    _loadYachtList();
  }

  Future<void> _loadYachtList() async {
    final yachtList = await YachtService.getYachtList();
    if (mounted) {
      setState(() {
        _yachtList = yachtList;
      });
    }
  }

  // 요트 리스트 갱신을 위한 공개 메서드
  void refreshYachtList() {
    _loadYachtList();
  }

  // 캘린더 새로고침을 위한 공개 메서드
  void refreshCalendar() {
    _calendarRefreshCallback?.call();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 다른 화면에서 돌아왔을 때 리스트 갱신
    _loadYachtList();
  }

  void _handleTabSelection(HooaahTab tab) {
    if (tab == _currentTab) {
      return;
    }

    // 요트 탭 클릭 시 리스트 확인
    if (tab == HooaahTab.yacht) {
      if (_yachtList.isEmpty) {
        CustomSnackBar.showError(
          context,
          message: '등록된 요트가 없습니다.',
        );
        return;
      }
    }

    // AI 탭은 아직 구현되지 않음
    if (tab == HooaahTab.ai) {
      CustomSnackBar.show(
        context,
        message: '해당 기능은 준비 중입니다.',
      );
      return;
    }

    setState(() {
      _currentTab = tab;
      // 탭 전환 시 선택된 요트 이름 초기화 (직접 탭 클릭 시)
      if (tab != HooaahTab.yacht) {
        _selectedYachtNameForNavigation = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _getTabIndex(_currentTab),
        children: [
          HomeScreenContent(
            yachtList: _yachtList,
            onNavigateToYachtDetail: (yachtName) {
              setState(() {
                _selectedYachtNameForNavigation = yachtName;
                _currentTab = HooaahTab.yacht;
              });
            },
            onYachtListRefresh: refreshYachtList,
          ),
          YachtManageScreenContent(
            yachtList: _yachtList,
            initialSelectedYachtName: _selectedYachtNameForNavigation,
            onYachtSelected: (yachtName) {
              setState(() {
                _selectedYachtNameForNavigation = yachtName;
              });
            },
            onYachtListRefresh: refreshYachtList,
            onCalendarRefresh: refreshCalendar,
          ),
          CalendarScreenContent(
            onRefreshCallbackRegistered: (callback) {
              _calendarRefreshCallback = callback;
            },
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: HooaahBottomNavigation(
        currentTab: _currentTab,
        onTabSelected: _handleTabSelection,
      ),
    );
  }

  int _getTabIndex(HooaahTab tab) {
    switch (tab) {
      case HooaahTab.home:
        return 0;
      case HooaahTab.yacht:
        return 1;
      case HooaahTab.calendar:
        return 2;
      case HooaahTab.settings:
        return 3;
      default:
        return 0;
    }
  }
}

