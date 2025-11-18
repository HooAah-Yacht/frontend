import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberListSection extends StatelessWidget {
  final List<Map<String, dynamic>> members;

  const MemberListSection({
    super.key,
    required this.members,
  });

  Future<void> _inviteMember(BuildContext context) async {
    // 카카오톡 공유 기능
    // TODO: 실제 초대 코드나 링크를 생성해야 함
    final inviteMessage = '요트 관리 앱에 초대되었습니다!';

    try {
      // 카카오톡 스킴으로 공유 시도
      final kakaoUrl = Uri.parse('kakaotalk://');
      if (await canLaunchUrl(kakaoUrl)) {
        // 카카오톡이 설치되어 있으면 공유
        // 실제로는 카카오톡 SDK를 사용하거나 다른 방법 필요
        await launchUrl(
          Uri.parse('sms:?body=$inviteMessage'),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // 카카오톡이 없으면 SMS로 대체
        await launchUrl(
          Uri.parse('sms:?body=$inviteMessage'),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공유 기능을 사용할 수 없습니다.'),
          ),
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
                child: members.isEmpty
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
                        children: members.asMap().entries.map((entry) {
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

