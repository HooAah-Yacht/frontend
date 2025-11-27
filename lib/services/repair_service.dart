import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class RepairService {
  static String get baseUrl => AuthService.baseUrl;

  // 부품별 정비 이력 조회
  static Future<List<Map<String, dynamic>>> getRepairListByPart(int partId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        print('정비 이력 조회 실패: 토큰이 없습니다.');
        return [];
      }

      // 토큰 앞뒤 공백 제거
      final cleanToken = token.trim();

      final url = '$baseUrl/api/repair/$partId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic>? responseData = data['response'] as Map<String, dynamic>?;
        final List<dynamic>? repairList = responseData?['repairList'] as List<dynamic>?;
        
        if (repairList != null) {
          return repairList.map((item) => item as Map<String, dynamic>).toList();
        }
        return [];
      } else {
        print('정비 이력 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('정비 이력 조회 오류: $e');
      return [];
    }
  }

  // 부품별 정비 이력 추가
  static Future<Map<String, dynamic>> addRepair({
    required int partId,
    required DateTime repairDate,
    required String content,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': '토큰이 없습니다.'};
      }

      final cleanToken = token.trim();
      final url = '$baseUrl/api/repair';

      final payload = {
        'id': partId,
        'date': repairDate.toUtc().toIso8601String(),
        'content': content,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '정비 이력이 추가되었습니다.'};
      } else {
        // 401 등 에러 응답이 JSON이 아닐 수 있으므로 안전하게 처리
        String errorMessage = '정비 이력 추가에 실패했습니다.';
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          errorMessage = data['message'] as String? ?? errorMessage;
        } catch (e) {
          // JSON이 아닌 경우 응답 본문을 그대로 사용
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        
        // 401 에러인 경우 특별 처리
        if (response.statusCode == 401) {
          errorMessage = '로그인이 만료되었습니다. 다시 로그인해주세요.';
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('정비 이력 추가 오류: $e');
      return {'success': false, 'message': '정비 이력 추가 중 오류가 발생했습니다.'};
    }
  }
}

