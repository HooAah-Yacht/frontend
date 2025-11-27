import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_app_bar.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';
import 'package:frontend/services/calendar_service.dart';
import 'package:frontend/widgets/calendar/add_calendar_event_bottom_sheet.dart';
import 'package:frontend/widgets/calendar/calendar_content_header.dart';
import 'package:frontend/widgets/calendar/calendar_date_section.dart';
import 'package:frontend/widgets/calendar/calendar_info_list.dart';
import 'package:frontend/widgets/calendar/calendar_action_buttons.dart';

class CalendarDetailScreen extends StatefulWidget {
  final Map<String, dynamic> calendarData;

  const CalendarDetailScreen({
    super.key,
    required this.calendarData,
  });

  @override
  State<CalendarDetailScreen> createState() => _CalendarDetailScreenState();
}

class _CalendarDetailScreenState extends State<CalendarDetailScreen> {
  Map<String, dynamic>? _calendarInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCalendarDetail();
  }

  Future<void> _loadCalendarDetail() async {
    final calendarId = widget.calendarData['id'] as int?;
    if (calendarId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final calendarInfo = await CalendarService.getCalendar(calendarId);
      setState(() {
        _calendarInfo = calendarInfo;
        _isLoading = false;
      });
    } catch (e) {
      print('일정 상세 정보 로드 실패: $e');
      setState(() {
        _isLoading = false;
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteCalendar();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCalendar() async {
    final calendarId = _calendarInfo?['id'] as int?;
    if (calendarId == null) return;

    final result = await CalendarService.deleteCalendar(calendarId);

    if (!mounted) return;

    if (result['success'] == true) {
      CustomSnackBar.showSuccess(
        context,
        message: '일정이 삭제되었습니다.',
      );
      Navigator.of(context).pop(true); // 삭제 성공 시 true 반환
    } else {
      CustomSnackBar.showError(
        context,
        message: result['message'] ?? '일정 삭제에 실패했습니다.',
      );
    }
  }

  void _showEditBottomSheet() {
    if (_calendarInfo == null) return;

    showModalBottomSheet<String>(
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
          initialData: _calendarInfo,
          onSubmit: (data) async {
            // _handleSubmit에서 이미 API 호출을 처리하므로 여기서는 데이터 새로고침만 수행
            // 일정 정보 새로고침
            await _loadCalendarDetail();
            // 상위 화면(캘린더 화면)에도 알림을 위해 'updated' 반환은
            // _handleSubmit에서 Navigator.pop('updated')를 호출할 때 처리됨
          },
        );
      },
    ).then((result) {
      // 수정이 완료되면 상위 화면(캘린더 화면)에 알림
      if (result == 'updated' && mounted) {
        // 일정 정보 새로고침 (onSubmit에서 이미 호출했지만 확실하게)
        _loadCalendarDetail();
        // 상위 화면(캘린더 화면)에 알림
        Navigator.of(context).pop('updated');
      }
      // result가 null이거나 다른 값일 때는 아무것도 하지 않음
      // (후기 화면으로 이동한 경우는 _navigateToReviewScreen에서 처리)
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: '일정 세부사항'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_calendarInfo == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: '일정 세부사항'),
        body: const Center(
          child: Text('일정 정보를 불러올 수 없습니다.'),
        ),
      );
    }

    final content = _calendarInfo!['content'] as String? ?? '';
    final completed = _calendarInfo!['completed'] as bool? ?? false;
    final startDateStr = _calendarInfo!['startDate'] as String?;
    final endDateStr = _calendarInfo!['endDate'] as String?;
    final type = _convertTypeToKorean(_calendarInfo!['type'] as String?);
    final yachtName = _calendarInfo!['yachtName'] as String? ?? '';
    final yachtNickName = _calendarInfo!['yachtNickName'] as String?;
    final partId = _calendarInfo!['partId'] as int?;
    final partList = _calendarInfo!['partList'] as List<dynamic>?;
    final review = _calendarInfo!['review'] as String?;
    
    // partId에 해당하는 부품 찾기
    Map<String, dynamic>? selectedPart;
    if (partId != null && partList != null) {
      try {
        selectedPart = partList.firstWhere(
          (part) => (part as Map<String, dynamic>)['id'] == partId,
          orElse: () => null,
        ) as Map<String, dynamic>?;
      } catch (e) {
        selectedPart = null;
      }
    }
    
    DateTime? startDate;
    DateTime? endDate;
    
    if (startDateStr != null) {
      startDate = DateTime.parse(startDateStr).toLocal();
    }
    if (endDateStr != null) {
      endDate = DateTime.parse(endDateStr).toLocal();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: '일정 세부사항'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // 일정 내용
              CalendarContentHeader(
                content: content,
                completed: completed,
              ),
              const SizedBox(height: 20),
              // 날짜와 시간
              if (startDate != null && endDate != null)
                CalendarDateSection(
                  startDate: startDate,
                  endDate: endDate,
                ),
              const SizedBox(height: 40),
              // 제목-내용 리스트
              CalendarInfoList(
                yachtName: yachtName,
                yachtNickName: yachtNickName,
                type: type,
                selectedPart: selectedPart,
                completed: completed,
                review: review,
              ),
              const SizedBox(height: 100), // 버튼 공간 확보
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: CalendarActionButtons(
            onEdit: _showEditBottomSheet,
            onDelete: _showDeleteDialog,
          ),
        ),
      ),
    );
  }
}

