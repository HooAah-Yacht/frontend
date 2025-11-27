import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/top_bar.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';
import 'package:frontend/widgets/yacht/manage/yacht_manage_title.dart';
import 'package:frontend/widgets/yacht/manage/yacht_picker_section.dart';
import 'package:frontend/widgets/yacht/manage/parts_manage_button.dart';
import 'package:frontend/widgets/yacht/manage/member_list_section.dart';
import 'package:frontend/screens/create1_yacht_screen.dart';
import 'package:frontend/screens/yacht_part_screen.dart';

// MainScreen에서 사용할 content 위젯
class YachtManageScreenContent extends StatefulWidget {
  final List<Map<String, dynamic>> yachtList;
  final String? initialSelectedYachtName;
  final ValueChanged<String>? onYachtSelected;
  final VoidCallback? onYachtListRefresh;
  final VoidCallback? onCalendarRefresh;

  const YachtManageScreenContent({
    super.key,
    required this.yachtList,
    this.initialSelectedYachtName,
    this.onYachtSelected,
    this.onYachtListRefresh,
    this.onCalendarRefresh,
  });

  @override
  State<YachtManageScreenContent> createState() => _YachtManageScreenContentState();
}

class _YachtManageScreenContentState extends State<YachtManageScreenContent> {
  String? _selectedYachtName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기 선택된 요트 이름이 있으면 설정
    if (widget.initialSelectedYachtName != null) {
      _selectedYachtName = widget.initialSelectedYachtName;
    }
    // 초기 로딩은 MainScreen에서 처리하므로 여기서는 필요 없음
    if (widget.yachtList.isEmpty) {
      _isLoading = true;
      widget.onYachtListRefresh?.call();
    } else {
      _updateSelectedYacht();
    }
  }

  @override
  void didUpdateWidget(YachtManageScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // initialSelectedYachtName이 변경되면 업데이트
    if (widget.initialSelectedYachtName != null &&
        widget.initialSelectedYachtName != oldWidget.initialSelectedYachtName) {
      setState(() {
        _selectedYachtName = widget.initialSelectedYachtName;
      });
    }
    // yachtList가 갱신되면 선택된 요트 업데이트
    if (widget.yachtList != oldWidget.yachtList) {
      _updateSelectedYacht();
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateSelectedYacht() {
    if (widget.yachtList.isNotEmpty) {
      // initialSelectedYachtName이 있고 리스트에 존재하면 그대로 사용
      if (widget.initialSelectedYachtName != null) {
        final exists = widget.yachtList.any(
          (yacht) => (yacht['name'] as String?) == widget.initialSelectedYachtName,
        );
        if (exists) {
          _selectedYachtName = widget.initialSelectedYachtName;
        } else {
          // 존재하지 않으면 첫 번째 요트 선택
          _selectedYachtName = widget.yachtList.first['name'] as String?;
        }
      } else if (_selectedYachtName == null) {
        // 초기 선택값이 없으면 첫 번째 요트 선택
        _selectedYachtName = widget.yachtList.first['name'] as String?;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final yachtNames = widget.yachtList
        .map((yacht) => yacht['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HooaahTopBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const YachtManageTitle(),
                  const SizedBox(height: 24),
                  YachtPickerSection(
                    yachtNames: yachtNames,
                    selectedYachtName: _selectedYachtName,
                    onYachtSelected: (name) {
                      setState(() {
                        _selectedYachtName = name;
                      });
                      widget.onYachtSelected?.call(name);
                    },
                    onAddYacht: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const Create1YachtScreen(),
                        ),
                      ).then((_) {
                        widget.onYachtListRefresh?.call();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  PartsManageButton(
                    onPressed: () {
                      // 선택된 요트의 ID 찾기
                      final selectedYacht = widget.yachtList.firstWhere(
                        (yacht) => (yacht['name'] as String?) == _selectedYachtName,
                        orElse: () => widget.yachtList.first,
                      );
                      // id는 Long 타입이므로 int로 변환
                      final yachtId = (selectedYacht['id'] as num?)?.toInt();
                      
                      if (yachtId != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => YachtPartScreen(
                              yachtId: yachtId,
                              onPartAdded: () {
                                // 부품 등록 성공 시 캘린더 새로고침
                                widget.onCalendarRefresh?.call();
                              },
                            ),
                          ),
                        ).then((_) {
                          // 부품 관리 화면에서 돌아왔을 때 요트 리스트 새로고침
                          // (정비 이력이 추가되었을 수 있으므로)
                          widget.onYachtListRefresh?.call();
                        });
                      } else {
                        CustomSnackBar.showError(
                          context,
                          message: '요트 정보를 찾을 수 없습니다.',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                  Builder(
                    builder: (context) {
                      // 선택된 요트의 ID 찾기
                      final selectedYacht = widget.yachtList.firstWhere(
                        (yacht) => (yacht['name'] as String?) == _selectedYachtName,
                        orElse: () => widget.yachtList.isNotEmpty ? widget.yachtList.first : <String, dynamic>{},
                      );
                      final yachtId = (selectedYacht['id'] as num?)?.toInt();
                      
                      // 요트 ID가 있으면 MemberListSection 표시
                      if (yachtId != null && widget.yachtList.isNotEmpty) {
                        return MemberListSection(yachtId: yachtId);
                      } else {
                        // 요트가 선택되지 않았거나 리스트가 비어있으면 빈 위젯
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// 기존 YachtManageScreen은 하위 호환성을 위해 유지
class YachtManageScreen extends StatelessWidget {
  const YachtManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const YachtManageScreenContent(
      yachtList: [],
    );
  }
}

