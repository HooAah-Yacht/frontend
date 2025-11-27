import 'package:flutter/material.dart';
import 'package:frontend/widgets/ai/ai_chat_input.dart';
import 'package:frontend/widgets/ai/ai_chat_list.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'type': 'user',
      'text': '안녕하세요! 요트 부품 관리에 대해 궁금한 게 있어요.',
    },
    {
      'type': 'ai',
      'text': '안녕하세요! 요트 부품 관리에 대해 무엇이 궁금하신가요?',
    },
    {
      'type': 'user',
      'text': '임펠러 교체 주기는 보통 얼마나 되나요?',
    },
    {
      'type': 'ai',
      'text': '임펠러 교체 주기는 사용 빈도와 환경에 따라 다르지만, 일반적으로 1-2년마다 점검하고 필요시 교체하는 것을 권장합니다.',
    },
    {
      'type': 'user',
      'text': '그럼 정기 점검은 어떻게 하면 되나요?',
    },
    {
      'type': 'ai',
      'text': '정기 점검은 앱의 캘린더 기능을 사용하시면 됩니다. 각 부품별로 점검 주기를 설정해두시면 알림을 받으실 수 있어요.',
    },
    {
      'type': 'user',
      'text': '알림 기능도 있나요?',
    },
    {
      'type': 'ai',
      'text': '네, 맞습니다! 점검 예정일이 다가오면 자동으로 알림을 받으실 수 있습니다. 설정에서 알림 주기를 조정하실 수도 있어요.',
    },
    {
      'type': 'user',
      'text': '부품 이력 관리도 가능한가요?',
    },
    {
      'type': 'ai',
      'text': '네, 각 부품별로 수리 이력과 교체 이력을 기록하고 관리할 수 있습니다. 부품 상세 페이지에서 이력을 확인하실 수 있어요.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              child: AiChatList(
                messages: _messages,
                scrollController: _scrollController,
              ),
            ),
            // 채팅 입력 영역
            Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: const AiChatInput(),
            ),
          ],
        ),
      ),
    );
  }
}

