import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/top_bar.dart';
import 'package:frontend/widgets/calendar/custom_calendar.dart';

// MainScreen에서 사용할 content 위젯
class CalendarScreenContent extends StatefulWidget {
  const CalendarScreenContent({super.key});

  @override
  State<CalendarScreenContent> createState() => _CalendarScreenContentState();
}

class _CalendarScreenContentState extends State<CalendarScreenContent> {
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    // 임시 이벤트 데이터 (추후 API로 대체)
    _loadEvents();
  }

  void _loadEvents() {
    // 임시 데이터 - 추후 API 연동
    final now = DateTime.now();
    _events = {
      DateTime(now.year, now.month, 1): [
        {'title': '임펠러', 'type': 'maintenance'},
        {'title': '세일링', 'type': 'sailing'},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HooaahTopBar(),
      body: Column(
        children: [
          // 캘린더 (고정)
          CustomCalendar(
            selectedDay: _selectedDay,
            onDaySelected: (day) {
              setState(() {
                _selectedDay = day;
              });
            },
            eventLoader: _events,
          ),
          // 일정 섹션 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '일정',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2B4184),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            // TODO: 일정 추가 기능
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 일정 리스트 (추후 구현)
                  const Text(
                    '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB0B8C1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 기존 CalendarScreen은 하위 호환성을 위해 유지
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalendarScreenContent();
  }
}

