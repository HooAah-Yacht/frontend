import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class YachtService {
  static const String baseUrl = AuthService.baseUrl;

  // 요트 리스트 조회
  static Future<List<Map<String, dynamic>>> getYachtList() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return [];
      }

      final url = '$baseUrl/api/yacht';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

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
          if (yachtAlias != null && yachtAlias.isNotEmpty) 'nickName': yachtAlias,
        },
        'partList': parts.map((part) => {
              'name': part['name'],
              'manufacturer': part['manufacturer'],
              'model': part['model'],
              'interval': part['interval'],
            }).toList(),
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : null;
        final String? message = errorData?['message'] as String?;
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

