import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String baseUrl = 'http://localhost:8080'; // TODO: 실제 서버 URL로 변경

  // 로그인
  static Future<Map<String, dynamic>> login(String email, String password) async {  
    try {
      final url = '$baseUrl/public/user/login';
      print('요청 URL: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 헤더: ${response.headers}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        print('로그인 성공');
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic>? payload =
            data['response'] as Map<String, dynamic>?;
        final String? token = payload?['token'] as String?;

        if (token == null || token.isEmpty) {
          print('응답에 토큰이 없습니다.');
          return {
            'success': false,
            'message': '로그인 토큰을 확인할 수 없습니다.',
          };
        }

        await saveToken(token);
        return {'success': true, 'token': token};
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        print('로그인 실패: 계정이 존재하지 않음');
        return {'success': false, 'message': '계정이 존재하지 않습니다.'};
      } else {
        print('로그인 실패: 알 수 없는 오류 (${response.statusCode})');
        return {'success': false, 'message': '로그인에 실패했습니다.'};
      }
    } catch (e) {
      print('네트워크 오류 발생: $e');
      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 토큰 저장
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // 토큰 불러오기
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // 토큰 삭제 (로그아웃)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // 이메일 중복 확인
  static Future<Map<String, dynamic>> checkEmailDuplicate(String email) async {
    try {
      final url = '$baseUrl/public/user/email-check?email=$email';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? message = data['message'] as String?;

        if (message == 'exist') {
          return {'success': true, 'isDuplicate': true};
        }
        if (message == 'not exist') {
          return {'success': true, 'isDuplicate': false};
        }

        return {'success': false, 'message': '알 수 없는 응답입니다.'};
      }

      return {
        'success': false,
        'message': '이메일 확인에 실패했습니다. (${response.statusCode})',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다. 다시 시도해주세요.',
      };
    }
  }

  // 회원가입
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/public/user/register';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      }

      final Map<String, dynamic>? data =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final String? message = data?['message'] as String?;

      return {
        'success': false,
        'message': message ?? '회원가입에 실패했습니다. (${response.statusCode})',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다. 다시 시도해주세요.',
      };
    }
  }
}

