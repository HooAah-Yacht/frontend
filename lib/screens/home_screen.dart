import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/bottom_navigation.dart';
import 'package:frontend/widgets/common/top_bar.dart';
import 'package:frontend/widgets/home/home_empty_message.dart';
import 'package:frontend/widgets/home/home_register_yacht_button.dart';
import 'package:frontend/widgets/home/home_yacht_title.dart';
import 'package:frontend/widgets/home/home_yacht_slider.dart';
import 'package:frontend/widgets/home/home_floating_button.dart';
import 'package:frontend/screens/create1_yacht_screen.dart';
import 'package:frontend/services/yacht_service.dart';
import 'package:frontend/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, RouteAware {
  List<Map<String, dynamic>> _yachtList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadYachtList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadYachtList();
    }
  }

  @override
  void didPush() {
    // 화면이 처음 푸시될 때
    _loadYachtList();
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때
    _loadYachtList();
  }

  Future<void> _loadYachtList() async {
    setState(() {
      _isLoading = true;
    });

    final yachtList = await YachtService.getYachtList();

    if (mounted) {
      setState(() {
        _yachtList = yachtList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HooaahTopBar(),
      body: SizedBox.expand(
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _yachtList.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const Spacer(),
                            const HomeEmptyMessage(),
                            const SizedBox(height: 24),
                            HomeRegisterYachtButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const Create1YachtScreen(),
                                  ),
                                ).then((_) {
                                  // 요트 등록 후 리스트 새로고침
                                  _loadYachtList();
                                });
                              },
                            ),
                            const Spacer(),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const HomeYachtTitle(),
                            const SizedBox(height: 30),
                            HomeYachtSlider(yachtList: _yachtList),
                          ],
                        ),
                      ),
            // 플로팅 버튼을 전체 스크린 기준으로 배치
            Positioned(
              right: 24,
              bottom: 24,
              child: HomeFloatingButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Create1YachtScreen(),
                    ),
                  ).then((_) {
                    // 요트 등록 후 리스트 새로고침
                    _loadYachtList();
                  });
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HooaahBottomNavigation(
        currentTab: HooaahTab.home,
        onTabSelected: (tab) {
          if (tab == HooaahTab.home) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('해당 기능은 준비 중입니다.'),
            ),
          );
        },
      ),
    );
  }
}
