/// 공유 서비스 인터페이스 (Dependency Inversion Principle)
abstract class ShareService {
  /// 초대 링크를 공유합니다.
  /// 
  /// [deepLinkUrl] 딥링크 URL
  /// 
  /// 성공 시 true, 실패 시 false 반환
  Future<bool> shareInviteLink({
    required String deepLinkUrl,
  });
}

