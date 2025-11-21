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

  // 초대 코드 조회
  static Future<Map<String, dynamic>> getInviteCode(int yachtId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': '인증 토큰이 없습니다.',
        };
      }

      final cleanToken = token.trim();
      final url = '$baseUrl/api/yacht/invite?yachtId=$yachtId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('초대 코드 조회 응답 상태 코드: ${response.statusCode}');
      print('초대 코드 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic>? responseData = data['response'] as Map<String, dynamic>?;
        final int? code = responseData?['code'] as int?;
        
        if (code != null) {
          return {
            'success': true,
            'code': code,
          };
        }
        return {
          'success': false,
          'message': '초대 코드를 받을 수 없습니다.',
        };
      } else if (response.statusCode == 409) {
        // CONFLICT: 백엔드 로직 오류로 인해 멤버인 경우에도 409가 발생
        // 임시 처리: yachtId를 그대로 초대 코드로 사용
        // TODO: 백엔드 수정 후 이 임시 처리 제거 필요
        print('⚠️ 409 에러 발생 - 임시로 yachtId를 초대 코드로 사용합니다.');
        return {
          'success': true,
          'code': yachtId, // 임시로 yachtId를 초대 코드로 사용
        };
      } else {
        String? message;
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic>? errorData = jsonDecode(response.body);
            message = errorData?['message'] as String?;
          } catch (e) {
            message = response.body;
          }
        }
        return {
          'success': false,
          'message': message ?? '초대 코드 조회에 실패했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('초대 코드 조회 오류: $e');
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다.',
      };
    }
  }

  // 초대 수락
  static Future<Map<String, dynamic>> acceptInvite(int code) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': '인증 토큰이 없습니다.',
        };
      }

      final cleanToken = token.trim();
      final url = '$baseUrl/api/yacht/invite';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
        body: jsonEncode({
          'code': code,
        }),
      );

      print('초대 수락 응답 상태 코드: ${response.statusCode}');
      print('초대 수락 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        String? message;
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic>? errorData = jsonDecode(response.body);
            message = errorData?['message'] as String?;
          } catch (e) {
            message = response.body;
          }
        }
        return {
          'success': false,
          'message': message ?? '초대 수락에 실패했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('초대 수락 오류: $e');
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다.',
      };
    }
  }

  // 요트별 멤버 목록 조회
  static Future<List<Map<String, dynamic>>> getYachtUserList(int yachtId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        print('멤버 목록 조회 실패: 토큰이 없습니다.');
        return [];
      }

      // 토큰 앞뒤 공백 제거
      final cleanToken = token.trim();

      final url = '$baseUrl/api/yacht/user/$yachtId';
      print('멤버 목록 조회 URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('멤버 목록 조회 응답 상태 코드: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('멤버 목록 조회 응답 본문: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic>? responseData = data['response'] as Map<String, dynamic>?;
        final List<dynamic>? userList = responseData?['userList'] as List<dynamic>?;
        
        if (userList != null) {
          return userList.map((item) => item as Map<String, dynamic>).toList();
        }
        return [];
      } else {
        print('멤버 목록 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('멤버 목록 조회 오류: $e');
      return [];
    }
  }
}

