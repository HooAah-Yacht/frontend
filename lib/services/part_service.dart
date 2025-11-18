import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class PartService {
  static String get baseUrl => AuthService.baseUrl;

  // 요트별 부품 리스트 조회
  static Future<List<Map<String, dynamic>>> getPartListByYacht(int yachtId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        print('부품 리스트 조회 실패: 토큰이 없습니다.');
        return [];
      }

      // 토큰 앞뒤 공백 제거
      final cleanToken = token.trim();

      final url = '$baseUrl/api/part/$yachtId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('부품 리스트 조회 응답 상태 코드: ${response.statusCode}');
      print('부품 리스트 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic>? responseData = data['response'] as Map<String, dynamic>?;
        final List<dynamic>? partList = responseData?['partList'] as List<dynamic>?;
        
        if (partList != null) {
          return partList.map((item) => item as Map<String, dynamic>).toList();
        }
        return [];
      } else {
        print('부품 리스트 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('부품 리스트 조회 오류: $e');
      return [];
    }
  }

  // 부품 삭제
  static Future<Map<String, dynamic>> deletePart(int partId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ 부품 삭제 실패: 토큰이 없습니다.');
        return {'success': false, 'message': '토큰이 없습니다.'};
      }

      final cleanToken = token.trim();
      final url = '$baseUrl/api/part/$partId';
      
      // 디버깅: 토큰과 URL 출력
      print('🔍 부품 삭제 요청 정보:');
      print('  - URL: $url');
      print('  - PartId: $partId');
      print('  - 토큰 존재: ${token.isNotEmpty}');
      print('  - 토큰 길이: ${token.length}');
      print('  - 토큰 앞 20자: ${token.length > 20 ? token.substring(0, 20) : token}...');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('부품 삭제 응답 상태 코드: ${response.statusCode}');
      print('부품 삭제 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': '부품이 삭제되었습니다.'};
      } else {
        // 401 등 에러 응답이 JSON이 아닐 수 있으므로 안전하게 처리
        String errorMessage = '부품 삭제에 실패했습니다.';
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
          // 토큰 만료 확인
          final tokenCheck = await AuthService.getToken();
          if (tokenCheck != null) {
            print('⚠️ 401 에러 발생: 토큰은 존재하지만 인증 실패');
            print('   토큰이 만료되었거나 유효하지 않을 수 있습니다.');
          }
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('부품 삭제 오류: $e');
      return {'success': false, 'message': '부품 삭제 중 오류가 발생했습니다.'};
    }
  }

  // 부품 정보 수정
  static Future<Map<String, dynamic>> updatePart({
    required int partId,
    required String name,
    required String manufacturer,
    required String model,
    required int interval,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': '토큰이 없습니다.'};
      }

      final cleanToken = token.trim();
      final url = '$baseUrl/api/part';

      final payload = {
        'id': partId,
        'name': name,
        'manufacturer': manufacturer,
        'model': model,
        'interval': interval,
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
        body: jsonEncode(payload),
      );

      print('부품 수정 응답 상태 코드: ${response.statusCode}');
      print('부품 수정 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': '부품 정보가 수정되었습니다.'};
      } else {
        // 401 등 에러 응답이 JSON이 아닐 수 있으므로 안전하게 처리
        String errorMessage = '부품 수정에 실패했습니다.';
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
          errorMessage = '로그인이 필요합니다.';
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('부품 수정 오류: $e');
      return {'success': false, 'message': '부품 수정 중 오류가 발생했습니다.'};
    }
  }

  // 부품 추가
  static Future<Map<String, dynamic>> addPart({
    required int yachtId,
    required String name,
    required String manufacturer,
    required String model,
    required int interval,
    DateTime? lastRepair,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': '토큰이 없습니다.'};
      }

      final cleanToken = token.trim();
      final url = '$baseUrl/api/part';

      final payload = {
        'yachtId': yachtId,
        'name': name,
        'manufacturer': manufacturer,
        'model': model,
        'interval': interval,
        if (lastRepair != null) 'lastRepair': lastRepair.toUtc().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
        body: jsonEncode(payload),
      );

      print('부품 추가 응답 상태 코드: ${response.statusCode}');
      print('부품 추가 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': '부품이 추가되었습니다.'};
      } else {
        // 401 등 에러 응답이 JSON이 아닐 수 있으므로 안전하게 처리
        String errorMessage = '부품 추가에 실패했습니다.';
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
          errorMessage = '로그인이 필요합니다.';
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('부품 추가 오류: $e');
      return {'success': false, 'message': '부품 추가 중 오류가 발생했습니다.'};
    }
  }
}

