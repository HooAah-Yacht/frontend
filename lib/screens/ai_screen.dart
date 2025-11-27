import 'package:flutter/material.dart';
import 'package:frontend/widgets/ai/ai_chat_input.dart';
import 'package:frontend/widgets/ai/ai_chat_list.dart';
import 'package:frontend/services/ai_service.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 채팅 내역 로드
  Future<void> _loadChatHistory() async {
    try {
      final chatHistory = await AiService.getChatHistory();
      
      setState(() {
        _messages.clear();
        for (final message in chatHistory) {
          final role = message['role'] as String? ?? '';
          final content = message['content'] as String? ?? '';
          
          // role이 USER면 'user', ASSISTANT면 'ai'로 변환
          final type = role.toUpperCase() == 'USER' ? 'user' : 'ai';
          
          _messages.add({
            'type': type,
            'text': content,
          });
        }
        _isLoadingHistory = false;
      });
      
      // 스크롤을 맨 아래로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      print('채팅 내역 로드 오류: $e');
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  // 메시지 전송
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      // 사용자 메시지 추가
      _messages.add({
        'type': 'user',
        'text': message,
      });
    });

    // 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    try {
      final result = await AiService.sendMessage(message);

      if (!mounted) return;

      if (result['success'] == true) {
        final aiResponse = result['response'] as String? ?? '';
        
        setState(() {
          // AI 응답 추가
          _messages.add({
            'type': 'ai',
            'text': aiResponse,
          });
          _isLoading = false;
        });

        // 스크롤을 맨 아래로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        
        CustomSnackBar.showError(
          context,
          message: result['message'] as String? ?? '메시지 전송에 실패했습니다.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      CustomSnackBar.showError(
        context,
        message: '메시지 전송 중 오류가 발생했습니다.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 키보드 높이 가져오기
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 아이콘 제거
        title: const Text(
          'AI Chat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 채팅 내용 영역
            Expanded(
              child: _isLoadingHistory
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : AiChatList(
                      messages: _messages,
                      scrollController: _scrollController,
                    ),
            ),
            // 채팅 입력 영역
            Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: AiChatInput(
                onSendMessage: _sendMessage,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

