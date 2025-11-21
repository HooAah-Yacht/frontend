import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/services/yacht_service.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';
import 'package:frontend/services/share/share_service_factory.dart';
import 'package:frontend/widgets/yacht/share/share_method_dialog.dart';

class MemberListSection extends StatefulWidget {
  final int yachtId;

  const MemberListSection({
    super.key,
    required this.yachtId,
  });

  @override
  State<MemberListSection> createState() => _MemberListSectionState();
}

class _MemberListSectionState extends State<MemberListSection> {
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemberList();
  }

  Future<void> _loadMemberList() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final members = await YachtService.getYachtUserList(widget.yachtId);
      
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      print('멤버 목록 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _inviteMember(BuildContext context) async {
    // 공유 방법 선택 다이얼로그 먼저 표시
    if (!context.mounted) return;
    
    final shareMethod = await ShareMethodDialog.show(context);
    if (shareMethod == null) return;

    try {
      // 초대 코드 조회
      setState(() {
        _isLoading = true;
      });

      final result = await YachtService.getInviteCode(widget.yachtId);
      
      setState(() {
        _isLoading = false;
      });

      if (!result['success']) {
        if (context.mounted) {
          CustomSnackBar.showError(
            context,
            message: result['message'] as String? ?? '초대 코드를 가져올 수 없습니다.',
          );
        }
        return;
      }

      final code = result['code'] as int;
      final deepLinkUrl = 'hooaah://invite?code=$code';

      // 카카오톡 공유 실행
      print('🔵 카카오톡 공유 시작: $deepLinkUrl');
      final shareService = ShareServiceFactory.create(shareMethod);
      final success = await shareService.shareInviteLink(
        deepLinkUrl: deepLinkUrl,
      );
      print('🔵 카카오톡 공유 결과: $success');

      if (!context.mounted) {
        print('🔴 context가 mounted되지 않음');
        return;
      }

      print('🔵 success 체크: $success');
      if (!success) {
        print('🔴 공유 실패 - 에러 메시지 표시');
        CustomSnackBar.showError(
          context,
          message: '카카오톡이 설치되어 있지 않거나 공유를 사용할 수 없습니다.',
        );
      } else {
        print('🟢 공유 성공');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: '초대 코드를 가져오는 중 오류가 발생했습니다.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '멤버 목록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF47546F),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // 멤버 리스트 박스
              Padding(
                padding: const EdgeInsets.all(24),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _members.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              '등록된 멤버가 없습니다.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB0B8C1),
                                letterSpacing: -0.5,
                              ),
                            ),
                          )
                        : Column(
                            children: _members.asMap().entries.map((entry) {
                              final index = entry.key;
                              final member = entry.value;
                              final name = member['name'] as String? ?? '';
                              final email = member['email'] as String? ?? '';

                              return Column(
                                children: [
                                  if (index > 0) const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFB0B8C1),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
              ),
              // 멤버 초대 버튼 (전체 너비, overflow hidden)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () => _inviteMember(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B4184),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/image/person_icon.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '멤버 초대',
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

