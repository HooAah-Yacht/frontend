import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime? selectedDay;
  final ValueChanged<DateTime>? onDaySelected;
  final Map<DateTime, List<dynamic>>? eventLoader;

  const CustomCalendar({
    super.key,
    this.selectedDay,
    this.onDaySelected,
    this.eventLoader,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay ?? DateTime.now();
    _selectedDay = widget.selectedDay ?? DateTime.now();
    _calendarFormat = CalendarFormat.month;
  }

  @override
  void didUpdateWidget(CustomCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay != oldWidget.selectedDay) {
      _selectedDay = widget.selectedDay ?? DateTime.now();
      _focusedDay = widget.selectedDay ?? DateTime.now();
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    if (widget.eventLoader == null) return [];
    
    // 날짜 비교를 위해 시간 부분 제거
    final normalizedDay = DateTime(day.year, day.month, day.day);
    
    // 정확한 날짜 매칭
    final events = widget.eventLoader![normalizedDay] ?? [];
    
    // 다른 날짜도 확인 (시간 부분이 다른 경우)
    for (final entry in widget.eventLoader!.entries) {
      final entryDate = DateTime(
        entry.key.year,
        entry.key.month,
        entry.key.day,
      );
      if (entryDate == normalizedDay) {
        return entry.value;
      }
    }
    
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      calendarFormat: _calendarFormat,
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        // 선택된 날짜 스타일
        selectedDecoration: BoxDecoration(
          color: const Color(0xFF2B4184),
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        // 오늘 날짜 스타일
        todayDecoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        // 기본 날짜 스타일
        defaultTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        // 주말 스타일
        weekendTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        // 외부 날짜 스타일 (이전/다음 달)
        outsideTextStyle: const TextStyle(
          color: Color(0xFFB0B8C1),
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        outsideDaysVisible: false,
        cellPadding: EdgeInsets.zero,
        cellMargin: EdgeInsets.zero,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (date, locale) {
          return '${date.year}년 ${date.month}월';
        },
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: Colors.black,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: Colors.black,
        ),
        formatButtonShowsNext: false,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        weekendStyle: TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      daysOfWeekHeight: 20,
      rowHeight: 60,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onDaySelected: (selectedDay, focusedDay) {
        // 날짜 포맷 콘솔 출력
        print('선택된 날짜: ${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}');
        print('선택된 날짜 (전체): $selectedDay');
        print('선택된 날짜 (ISO): ${selectedDay.toIso8601String()}');
        
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        widget.onDaySelected?.call(selectedDay);
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, focusedDay) {
          final isSelected = isSameDay(_selectedDay, date);
          return Container(
            margin: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (isSelected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2B4184),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        selectedBuilder: (context, date, focusedDay) {
          return Container(
            margin: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2B4184),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        todayBuilder: (context, date, focusedDay) {
          final isSelected = isSameDay(_selectedDay, date);
          return Container(
            margin: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (isSelected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2B4184),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        outsideBuilder: (context, date, focusedDay) {
          return Container(
            margin: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '${date.day}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFFB0B8C1),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          );
        },
        markerBuilder: (context, date, events) {
          // 이벤트 마커 제거
          return const SizedBox.shrink();
        },
      ),
    ),
        // 요일 헤더 밑에 선 추가
        Container(
          height: 1,
          color: const Color(0xFFB0B8C1),
        ),
      ],
    );
  }
}

