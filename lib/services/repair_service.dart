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

      print('정비 이력 조회 응답 상태 코드: ${response.statusCode}');
      print('정비 이력 조회 응답 본문: ${response.body}');

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
}

