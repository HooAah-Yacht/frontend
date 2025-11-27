import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class AlarmService {
  static String get baseUrl => AuthService.baseUrl;

  // 알람 리스트 조회
  static Future<List<dynamic>> getAlarmList() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final url = '$baseUrl/api/alarm';
      final cleanToken = token.trim();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final dynamic responseField = responseData['response'];
        
        // response가 List인지 확인
        if (responseField is List) {
          return responseField.map((item) => item as Map<String, dynamic>).toList();
        }
        
        return [];
      } else {
        throw Exception('알람 리스트 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('알람 리스트 조회 오류: $e');
      rethrow;
    }
  }

  // FCM 테스트
  static Future<Map<String, dynamic>> testFCM(String fcmToken) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final url = '$baseUrl/api/alarm/fcm-test?token=$fcmToken';
      final cleanToken = token.trim();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      if (response.statusCode == 200) {
        print('FCM 테스트 성공: 테스트 메시지가 전송되었습니다.');
        return {'success': true};
      } else {
        throw Exception('FCM 테스트 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('FCM 테스트 오류: $e');
      return {
        'success': false,
        'message': 'FCM 테스트 중 오류가 발생했습니다: $e',
      };
    }
  }
}

