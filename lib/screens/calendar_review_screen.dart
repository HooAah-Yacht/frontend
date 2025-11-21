import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:frontend/widgets/calendar/calendar_review_top_bar.dart';
import 'package:frontend/widgets/calendar/calendar_review_page_title.dart';
import 'package:frontend/widgets/calendar/calendar_review_text_field.dart';
import 'package:frontend/widgets/calendar/calendar_review_action_buttons.dart';
import 'package:frontend/services/calendar_service.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';

class CalendarReviewScreen extends StatefulWidget {
  const CalendarReviewScreen({
    super.key,
    this.calendarData,
  });

  final Map<String, dynamic>? calendarData;

  @override
  State<CalendarReviewScreen> createState() => _CalendarReviewScreenState();
}

class _CalendarReviewScreenState extends State<CalendarReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // 콘솔에 데이터 출력
  void _printData(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    print('========== 작성된 데이터 ==========');
    print(encoder.convert(data));
    print('================================');
  }

  // 나중에 하기: 후기는 null로 설정하고 calendar 업데이트
  Future<void> _handleLater() async {
    if (widget.calendarData == null) {
      Navigator.of(context).pop();
      return;
    }

    final calendarId = widget.calendarData!['id'] as int?;
    if (calendarId == null) {
      // 등록 모드인 경우: 후기 작성 없이 일정 등록 진행
      Navigator.of(context).pop(true);
      return;
    }

    // 수정 모드: 후기를 null로 설정하고 업데이트
    final payload = Map<String, dynamic>.from(widget.calendarData!);
    payload['review'] = null;

    _printData(payload);

    // 현재는 review 필드가 없으므로 기존 데이터로 업데이트
    final result = await CalendarService.updateCalendar(
      calendarId: calendarId,
      type: payload['type'] as String,
      yachtId: payload['yachtId'] as int,
      startDate: payload['startDate'] as String,
      endDate: payload['endDate'] as String,
      completed: payload['completed'] as bool,
      byUser: payload['byUser'] as bool,
      content: payload['content'] as String,
      partId: payload['partId'] as int?,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.of(context).pop(true); // 업데이트 성공 시 true 반환
      CustomSnackBar.showSuccess(
        context,
        message: '일정이 업데이트되었습니다.',
      );
    } else {
      CustomSnackBar.showError(
        context,
        message: result['message'] ?? '일정 업데이트에 실패했습니다.',
      );
    }
  }

  // 등록하기: 후기와 함께 calendar 업데이트 (현재는 review 필드가 없으므로 보내지 않음)
  Future<void> _handleSubmit() async {
    if (widget.calendarData == null) {
      Navigator.of(context).pop();
      return;
    }

    final calendarId = widget.calendarData!['id'] as int?;
    if (calendarId == null) {
      // 등록 모드인 경우: 후기 작성 후 일정 등록 진행
      Navigator.of(context).pop(true);
      return;
    }

    // 수정 모드: 후기와 함께 업데이트
    final reviewText = _reviewController.text.trim();
    final payload = Map<String, dynamic>.from(widget.calendarData!);
    payload['review'] = reviewText.isEmpty ? null : reviewText;

    _printData(payload);

    // 현재는 review 필드가 없으므로 기존 데이터로 업데이트
    // 나중에 review 필드가 추가되면 payload에 포함시켜야 함
    final result = await CalendarService.updateCalendar(
      calendarId: calendarId,
      type: payload['type'] as String,
      yachtId: payload['yachtId'] as int,
      startDate: payload['startDate'] as String,
      endDate: payload['endDate'] as String,
      completed: payload['completed'] as bool,
      byUser: payload['byUser'] as bool,
      content: payload['content'] as String,
      partId: payload['partId'] as int?,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.of(context).pop(true); // 업데이트 성공 시 true 반환
      CustomSnackBar.showSuccess(
        context,
        message: '일정이 업데이트되었습니다.',
      );
    } else {
      CustomSnackBar.showError(
        context,
        message: result['message'] ?? '일정 업데이트에 실패했습니다.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CalendarReviewTopBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const CalendarReviewPageTitle(),
                    const SizedBox(height: 24),
                    CalendarReviewTextField(
                      controller: _reviewController,
                      hintText: '일정에 대한 후기를 남겨주세요 (선택)',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: CalendarReviewActionButtons(
                onLater: _handleLater,
                onSubmit: _handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

