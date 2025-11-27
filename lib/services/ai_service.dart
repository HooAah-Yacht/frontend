import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class AiService {
  static String get baseUrl => AuthService.baseUrl;

  // AI 채팅 메시지 전송
  static Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': '인증 토큰이 없습니다.',
        };
      }

      final url = '$baseUrl/api/chat';
      final cleanToken = token.trim();

      final payload = {
        'message': message,
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
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic>? responseData = data['response'] as Map<String, dynamic>?;
        
        if (responseData != null) {
          final String? aiResponse = responseData['response'] as String?;
          return {
            'success': true,
            'response': aiResponse ?? '',
            'conversationId': responseData['conversationId'] as String?,
          };
        }
        
        return {
          'success': false,
          'message': '응답을 받을 수 없습니다.',
        };
      } else {
        String errorMessage = '메시지 전송에 실패했습니다.';
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
      print('AI 메시지 전송 오류: $e');
      return {
        'success': false,
        'message': '메시지 전송 중 오류가 발생했습니다.',
      };
    }
  }

  // AI 채팅 내역 조회
  static Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return [];
      }

      final url = '$baseUrl/api/chat';
      final cleanToken = token.trim();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final dynamic responseData = data['response'];
        
        if (responseData is List) {
          return responseData.map((item) {
            final message = item as Map<String, dynamic>;
            return {
              'content': message['content'] as String? ?? '',
              'role': message['role'] as String? ?? '',
              'createdAt': message['createdAt'] as String?,
            };
          }).toList();
        }
        
        return [];
      } else {
        print('채팅 내역 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('채팅 내역 조회 오류: $e');
      return [];
    }
  }
}

