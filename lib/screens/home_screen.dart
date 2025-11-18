import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/top_bar.dart';
import 'package:frontend/widgets/home/home_empty_message.dart';
import 'package:frontend/widgets/home/home_register_yacht_button.dart';
import 'package:frontend/widgets/home/home_yacht_title.dart';
import 'package:frontend/widgets/home/home_yacht_slider.dart';
import 'package:frontend/widgets/home/home_floating_button.dart';
import 'package:frontend/screens/create1_yacht_screen.dart';
import 'package:frontend/main.dart';

// MainScreen에서 사용할 content 위젯
class HomeScreenContent extends StatefulWidget {
  final List<Map<String, dynamic>> yachtList;
  final ValueChanged<String>? onNavigateToYachtDetail;
  final VoidCallback? onYachtListRefresh;

  const HomeScreenContent({
    super.key,
    required this.yachtList,
    this.onNavigateToYachtDetail,
    this.onYachtListRefresh,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> with WidgetsBindingObserver, RouteAware {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 초기 로딩은 MainScreen에서 처리하므로 여기서는 필요 없음
    if (widget.yachtList.isEmpty) {
      _isLoading = true;
      _loadYachtList();
    }
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
  void didUpdateWidget(HomeScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // MainScreen에서 리스트가 갱신되면 자동으로 반영됨
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
      widget.onYachtListRefresh?.call();
    }
  }

  @override
  void didPush() {
    // 화면이 처음 푸시될 때
    widget.onYachtListRefresh?.call();
  }

  @override
  void didPopNext() {
    // 다른 화면에서 돌아왔을 때
    widget.onYachtListRefresh?.call();
  }

  Future<void> _loadYachtList() async {
    setState(() {
      _isLoading = true;
    });

    widget.onYachtListRefresh?.call();

    if (mounted) {
      setState(() {
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
                : widget.yachtList.isEmpty
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
                                  widget.onYachtListRefresh?.call();
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
                            HomeYachtSlider(
                              yachtList: widget.yachtList,
                              onYachtDetailPressed: widget.yachtList.isNotEmpty
                                  ? (index) {
                                      final currentYacht = widget.yachtList[index];
                                      final yachtName = currentYacht['name'] as String? ?? '';
                                      widget.onNavigateToYachtDetail?.call(yachtName);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
            // 플로팅 버튼을 전체 스크린 기준으로 배치 (리스트가 있을 때만 표시)
            if (!_isLoading && widget.yachtList.isNotEmpty)
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
                      widget.onYachtListRefresh?.call();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 기존 HomeScreen은 MainScreen으로 리다이렉트 (하위 호환성)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenContent(
      yachtList: [],
    );
  }
}
