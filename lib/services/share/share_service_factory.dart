import 'package:frontend/services/share/share_service.dart';
import 'package:frontend/services/share/kakao_share_service.dart';
import 'package:frontend/services/share/share_method.dart';

/// 공유 서비스 팩토리 (Factory Pattern)
/// 
/// 카카오톡 공유 서비스를 반환합니다.
class ShareServiceFactory {
  /// 카카오톡 공유 서비스 인스턴스를 반환합니다.
  static ShareService create(ShareMethod method) {
    return KakaoShareService();
  }
}

