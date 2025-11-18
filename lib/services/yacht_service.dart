import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class YachtService {
  static String get baseUrl => AuthService.baseUrl;

  // 요트 리스트 조회
  static Future<List<Map<String, dynamic>>> getYachtList() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return [];
      }

      // 토큰 앞뒤 공백 제거
      final cleanToken = token.trim();

      final url = '$baseUrl/api/yacht';
      print('요트 리스트 조회 URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('요트 리스트 조회 응답 상태 코드: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('요트 리스트 조회 응답 본문: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic>? responseData = data['response'] as Map<String, dynamic>?;
        final List<dynamic>? list = responseData?['list'] as List<dynamic>?;
        
        if (list != null) {
          return list.map((item) => item as Map<String, dynamic>).toList();
        }
        return [];
      } else {
        print('요트 리스트 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('요트 리스트 조회 오류: $e');
      return [];
    }
  }

  // 요트 등록
  static Future<Map<String, dynamic>> createYacht({
    required String yachtName,
    required String? yachtAlias,
    required List<Map<String, dynamic>> parts,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': '인증 토큰이 없습니다.',
        };
      }

      final url = '$baseUrl/api/yacht';
      
      // CreateYachtDto 구조에 맞게 데이터 구성
      final payload = {
        'yacht': {
          'name': yachtName,
          'nickName': yachtAlias,
        },
        'partList': parts.map((part) => {
              'name': part['name'],
              'manufacturer': part['manufacturer'],
              'model': part['model'],
              'interval': part['interval'],
              'lastRepair': part['lastRepair'],
            }).toList(),
      };
      
      // 토큰 앞뒤 공백 제거
      final cleanToken = token.trim();
      
      // 요청 헤더 확인
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $cleanToken',
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('요트 등록 응답 상태 코드: ${response.statusCode}');
      print('요트 등록 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        // 응답이 JSON이 아닐 수 있으므로 안전하게 파싱
        String? message;
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic>? errorData = jsonDecode(response.body);
            message = errorData?['message'] as String?;
          } catch (e) {
            // JSON이 아니면 응답 본문을 그대로 사용
            message = response.body;
          }
        }
        return {
          'success': false,
          'message': message ?? '요트 등록에 실패했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('요트 등록 오류: $e');
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다.',
      };
    }
  }
}

