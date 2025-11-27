import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  // FCM 토큰 가져오기 (권한 확인 포함)
  static Future<String?> getFCMToken({bool requestPermission = false}) async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // 권한 요청이 필요한 경우
      if (requestPermission) {
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        
        print('알림 권한 상태: ${settings.authorizationStatus}');
        
        // 권한이 승인되지 않은 경우 null 반환
        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          print('알림 권한이 승인되지 않아 FCM 토큰을 가져올 수 없습니다.');
          return null;
        }
      }
      
      // FCM 토큰 가져오기
      String? token = await messaging.getToken();
      print('FCM 토큰: $token');
      return token;
    } catch (e) {
      print('FCM 토큰 가져오기 실패: $e');
      return null;
    }
  }
  
  // 현재 권한 상태 확인
  static Future<NotificationSettings> getNotificationSettings() async {
    final messaging = FirebaseMessaging.instance;
    return await messaging.getNotificationSettings();
  }
}

