import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class CalendarService {
  static String get baseUrl => AuthService.baseUrl;

  // 일정 등록
  static Future<Map<String, dynamic>> createCalendar({
    required String type,
    required int yachtId,
    required String startDate,
    required String endDate,
    required bool completed,
    required bool byUser,
    required String content,
    int? partId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': '인증 토큰이 없습니다.',
        };
      }

      final url = '$baseUrl/api/calendars';
      final cleanToken = token.trim();

      final payload = {
        'type': type,
        'yachtId': yachtId,
        'startDate': startDate,
        'endDate': endDate,
        'completed': completed,
        'byUser': byUser,
        'content': content,
        'partId': partId,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
        body: jsonEncode(payload),
      );

      print('일정 등록 응답 상태 코드: ${response.statusCode}');
      print('일정 등록 응답 본문: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // 응답에서 생성된 일정 정보 추출
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final Map<String, dynamic>? responseData = data['response'] as Map<String, dynamic>?;
          
          if (responseData != null) {
            return {
              'success': true,
              'calendar': responseData,
            };
          }
        } catch (e) {
          print('일정 등록 응답 파싱 오류: $e');
        }
        
        return {'success': true};
      } else {
        String errorMessage = '일정 등록에 실패했습니다.';
        try {
          final Map<String, dynamic>? errorData = jsonDecode(response.body);
          errorMessage = errorData?['message'] as String? ?? errorMessage;
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('일정 등록 오류: $e');
      return {
        'success': false,
        'message': '일정 등록 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 일정 목록 조회
  static Future<List<Map<String, dynamic>>> getCalendars({int? partId}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        print('일정 목록 조회 실패: 토큰이 없습니다.');
        return [];
      }

      final cleanToken = token.trim();
      final url = partId != null 
          ? '$baseUrl/api/calendars?partId=$partId'
          : '$baseUrl/api/calendars';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('일정 목록 조회 응답 상태 코드: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('일정 목록 조회 응답 본문: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final dynamic responseData = data['response'];
        
        // response가 List인지 확인 (CalendarController에서 List를 직접 반환)
        if (responseData is List) {
          return responseData.map((item) => item as Map<String, dynamic>).toList();
        }
        
        // response가 Map이고 그 안에 List가 있는 경우 (다른 API 패턴)
        if (responseData is Map<String, dynamic>) {
          final List<dynamic>? calendarList = responseData['list'] as List<dynamic>?;
          if (calendarList != null) {
            return calendarList.map((item) => item as Map<String, dynamic>).toList();
          }
        }
        
        print('일정 목록 조회: 응답 데이터 형식이 예상과 다릅니다. responseData 타입: ${responseData.runtimeType}');
        print('응답 본문: ${response.body}');
        return [];
      } else {
        print('일정 목록 조회 실패: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        return [];
      }
    } catch (e) {
      print('일정 목록 조회 오류: $e');
      return [];
    }
  }

  // 일정 상세 조회
  static Future<Map<String, dynamic>?> getCalendar(int calendarId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        print('일정 상세 조회 실패: 토큰이 없습니다.');
        return null;
      }

      final cleanToken = token.trim();
      final url = '$baseUrl/api/calendars/$calendarId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('일정 상세 조회 응답 상태 코드: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('일정 상세 조회 응답 본문: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final dynamic responseData = data['response'];
        
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }
        
        return null;
      } else {
        print('일정 상세 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('일정 상세 조회 오류: $e');
      return null;
    }
  }

  // 일정 수정
  static Future<Map<String, dynamic>> updateCalendar({
    required int calendarId,
    required String type,
    required int yachtId,
    required String startDate,
    required String endDate,
    required bool completed,
    required bool byUser,
    required String content,
    int? partId,
    String? review,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': '인증 토큰이 없습니다.',
        };
      }

      final url = '$baseUrl/api/calendars/$calendarId';
      final cleanToken = token.trim();

      final payload = {
        'type': type,
        'yachtId': yachtId,
        'startDate': startDate,
        'endDate': endDate,
        'completed': completed,
        'byUser': byUser,
        'content': content,
        'partId': partId,
        'review': review,
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
        body: jsonEncode(payload),
      );

      print('일정 수정 응답 상태 코드: ${response.statusCode}');
      print('일정 수정 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        String errorMessage = '일정 수정에 실패했습니다.';
        try {
          final Map<String, dynamic>? errorData = jsonDecode(response.body);
          errorMessage = errorData?['message'] as String? ?? errorMessage;
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('일정 수정 오류: $e');
      return {
        'success': false,
        'message': '일정 수정 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 일정 삭제
  static Future<Map<String, dynamic>> deleteCalendar(int calendarId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': '인증 토큰이 없습니다.',
        };
      }

      final url = '$baseUrl/api/calendars/$calendarId';
      final cleanToken = token.trim();

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('일정 삭제 응답 상태 코드: ${response.statusCode}');
      print('일정 삭제 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        String errorMessage = '일정 삭제에 실패했습니다.';
        try {
          final Map<String, dynamic>? errorData = jsonDecode(response.body);
          errorMessage = errorData?['message'] as String? ?? errorMessage;
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('일정 삭제 오류: $e');
      return {
        'success': false,
        'message': '일정 삭제 중 오류가 발생했습니다: $e',
      };
    }
  }
}

