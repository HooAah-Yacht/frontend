import 'dart:io';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

/// 초대 링크 공유 서비스
class ShareService {
  /// 초대 링크를 카카오톡으로 공유합니다.
  /// 
  /// [deepLinkUrl] 딥링크 URL
  /// 
  /// 성공 시 true, 실패 시 false 반환
  static Future<bool> shareInviteLink({
    required String deepLinkUrl,
  }) async {
    try {
      print('🟡 ShareService.shareInviteLink 시작: $deepLinkUrl');
      
      // 카카오톡 설치 여부 확인 (Android만)
      if (Platform.isAndroid) {
        try {
          final isInstalled = await isKakaoTalkInstalled();
          print('🟡 카카오톡 설치 여부: $isInstalled');
          if (!isInstalled) {
            print('🔴 카카오톡이 설치되어 있지 않습니다.');
            return false;
          }
        } catch (e) {
          print('🔴 카카오톡 설치 여부 확인 실패: $e');
          // 설치 여부 확인 실패해도 공유 시도
        }
      }
      
      // 딥링크 URL을 Link 객체로 생성
      // Android에서 딥링크 스킴(hooaah://)을 webUrl로 사용하면
      // 카카오톡에서 링크 클릭 시 앱이 실행됩니다
      final link = Link(
        webUrl: Uri.parse(deepLinkUrl),
        mobileWebUrl: Uri.parse(deepLinkUrl),
      );
      print('🟡 Link 객체 생성 완료');

      // Feed 템플릿 생성
      final template = FeedTemplate(
        content: Content(
          title: 'Hooaah - 요트 관리 앱 초대',
          description: 'Hooaah - 요트 관리 앱에 초대되었습니다!\n링크를 클릭하여 초대를 수락하세요.',
          link: link,
        ),
        buttons: [ 
          Button(
            title: '초대 수락하기',
            link: link,
          ),
        ],
      );
      print('🟡 FeedTemplate 생성 완료');

      // 카카오톡 공유
      print('🟡 ShareClient.instance.shareDefault 호출 시작');
      await ShareClient.instance.shareDefault(template: template);
      print('🟢 카카오톡 공유 성공');
      return true;
    } catch (e, stackTrace) {
      print('🔴 카카오톡 공유 실패: $e');
      print('🔴 스택 트레이스: $stackTrace');
      return false;
    }
  }
}
