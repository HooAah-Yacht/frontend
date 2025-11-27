import 'package:flutter/material.dart';
import 'package:frontend/widgets/notification/notification_app_bar.dart';
import 'package:frontend/widgets/notification/notification_item.dart';
import 'package:frontend/services/alarm_service.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  List<Map<String, dynamic>> _alarmList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final alarms = await AlarmService.getAlarmList();
      print('알람 리스트: $alarms');
      
      setState(() {
        _alarmList = alarms.map((alarm) => alarm as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('알람 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const NotificationAppBar(),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _alarmList.isEmpty
                ? const Center(
                    child: Text(
                      '등록된 알림이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: -0.5,
                        color: Color(0xFF47546F),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        ..._alarmList.map((alarm) {
                          final part = alarm['part'] as Map<String, dynamic>?;
                          final date = alarm['date'] as String?;
                          
                          if (part == null || date == null) {
                            return const SizedBox.shrink();
                          }
                          
                          final name = part['name'] as String? ?? '';
                          final manufacturer = part['manufacturer'] as String? ?? '';
                          final model = part['model'] as String? ?? '';
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NotificationItem(
                              name: name,
                              manufacturer: manufacturer,
                              model: model,
                              scheduledDate: date,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
      ),
    );
  }
}


