import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/top_bar.dart';
import 'package:frontend/widgets/calendar/custom_calendar.dart';
import 'package:frontend/widgets/calendar/add_calendar_event_bottom_sheet.dart';
import 'package:frontend/widgets/calendar/calendar_event_item.dart';
import 'package:frontend/services/calendar_service.dart';

// MainScreen에서 사용할 content 위젯
class CalendarScreenContent extends StatefulWidget {
  const CalendarScreenContent({super.key});

  @override
  State<CalendarScreenContent> createState() => _CalendarScreenContentState();
}

class _CalendarScreenContentState extends State<CalendarScreenContent> {
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<dynamic>> _events = {};
  bool _isLoadingCalendars = false;

  @override
  void initState() {
    super.initState();
    _loadCalendars();
  }

  Future<void> _loadCalendars() async {
    setState(() {
      _isLoadingCalendars = true;
    });

    try {
      final calendars = await CalendarService.getCalendars();
      
      // 전체 캘린더 데이터 프린트
      print('=== 캘린더 전체 데이터 로드 ===');
      print('캘린더 개수: ${calendars.length}');
      for (final calendar in calendars) {
        print('일정: ${calendar['content']}, startDate: ${calendar['startDate']}');
      }
      print('==========================');
      
      // 날짜별로 그룹화 (시작일 기준)
      final Map<DateTime, List<dynamic>> eventsMap = {};
      
      for (final calendar in calendars) {
        final startDateStr = calendar['startDate'] as String?;
        if (startDateStr != null) {
          try {
            final startDate = DateTime.parse(startDateStr).toLocal();
            final dateKey = DateTime(startDate.year, startDate.month, startDate.day);
            
            if (!eventsMap.containsKey(dateKey)) {
              eventsMap[dateKey] = [];
            }
            eventsMap[dateKey]!.add(calendar);
          } catch (e) {
            // 날짜 파싱 실패 시 무시
          }
        }
      }
      
      setState(() {
        _events = eventsMap;
        _isLoadingCalendars = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCalendars = false;
      });
    }
  }
  
  // 타입을 한글로 변환
  String _convertTypeToKorean(String? type) {
    if (type == null) return '';
    switch (type.toUpperCase()) {
      case 'SAILING':
        return '세일링';
      case 'INSPECTION':
        return '점검';
      case 'PART':
        return '정비';
      default:
        return type;
    }
  }
  
  // 선택된 날짜의 일정 목록 가져오기 (시작일 기준)
  List<Map<String, dynamic>> _getCalendarsForSelectedDay() {
    // 선택된 날짜를 같은 포맷으로 정규화 (년/월/일만)
    final selectedDayLocal = _selectedDay.isUtc 
        ? _selectedDay.toLocal() 
        : _selectedDay;
    final selectedDateNormalized = DateTime(selectedDayLocal.year, selectedDayLocal.month, selectedDayLocal.day);
    final selectedDateStr = '${selectedDateNormalized.year}-${selectedDateNormalized.month.toString().padLeft(2, '0')}-${selectedDateNormalized.day.toString().padLeft(2, '0')}';
    
    print('=== 날짜 비교 ===');
    print('선택된 날짜: $selectedDateStr (${selectedDateNormalized.year}-${selectedDateNormalized.month}-${selectedDateNormalized.day})');
    
    final List<Map<String, dynamic>> result = [];
    
    // 모든 일정을 순회하면서 시작일과 비교
    for (final entry in _events.entries) {
      for (final calendar in entry.value) {
        final calendarMap = calendar as Map<String, dynamic>;
        final startDateStr = calendarMap['startDate'] as String?;
        
        if (startDateStr != null) {
          try {
            // API의 startDate를 파싱하고 년/월/일만 추출
            final startDate = DateTime.parse(startDateStr).toLocal();
            final startDateNormalized = DateTime(startDate.year, startDate.month, startDate.day);
            final apiDateStr = '${startDateNormalized.year}-${startDateNormalized.month.toString().padLeft(2, '0')}-${startDateNormalized.day.toString().padLeft(2, '0')}';
            
            // 년도/월/일만 비교
            final isMatch = startDateNormalized.year == selectedDateNormalized.year &&
                           startDateNormalized.month == selectedDateNormalized.month &&
                           startDateNormalized.day == selectedDateNormalized.day;
            
            print('API startDate: $apiDateStr (${startDateNormalized.year}-${startDateNormalized.month}-${startDateNormalized.day}) vs 선택: $selectedDateStr -> ${isMatch ? "매칭" : "불일치"}');
            
            if (isMatch) {
              result.add(calendarMap);
            }
          } catch (e) {
            // 날짜 파싱 실패 시 무시
          }
        }
      }
    }
    
    print('매칭된 일정 개수: ${result.length}');
    print('================');
    
    return result;
  }

  void _showAddEventBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return AddCalendarEventBottomSheet(
          onSubmit: (data) {
            // 일정 추가 후 목록 새로고침
            _loadCalendars();
          },
        );
      },
    );
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
                        child: Center(
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _showAddEventBottomSheet(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 일정 리스트
                  if (_isLoadingCalendars)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    ..._getCalendarsForSelectedDay().map((calendar) {
                      final type = _convertTypeToKorean(calendar['type'] as String?);
                      final content = calendar['content'] as String? ?? '';
                      final startDateStr = calendar['startDate'] as String?;
                      final endDateStr = calendar['endDate'] as String?;
                      final completed = calendar['completed'] as bool? ?? false;
                      
                      DateTime? startDate;
                      DateTime? endDate;
                      
                      if (startDateStr != null) {
                        startDate = DateTime.parse(startDateStr).toLocal();
                      }
                      if (endDateStr != null) {
                        endDate = DateTime.parse(endDateStr).toLocal();
                      }
                      
                      if (startDate == null || endDate == null) {
                        return const SizedBox.shrink();
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CalendarEventItem(
                          type: type,
                          content: content,
                          startDate: startDate,
                          endDate: endDate,
                          completed: completed,
                          calendarData: calendar,
                          onDeleted: () {
                            _loadCalendars();
                          },
                        ),
                      );
                    }).toList(),
                    if (_getCalendarsForSelectedDay().isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            '일정이 없습니다.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFB0B8C1),
                            ),
                          ),
                        ),
                      ),
                  ],
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

