import 'package:flutter/material.dart';
import 'package:frontend/widgets/notification/notification_app_bar.dart';
import 'package:frontend/widgets/notification/notification_item.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미데이터
    final dummyNotification = {
      'name': '임펠러',
      'manufacturer': '야마하',
      'model': '6CE-44352-00 IMPELELLER',
      'scheduledDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'bgColor': 0xFFF8F3D6, // 이미지에서 보이는 light yellow-green 색상
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const NotificationAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              NotificationItem(
                name: dummyNotification['name'] as String,
                manufacturer: dummyNotification['manufacturer'] as String,
                model: dummyNotification['model'] as String,
                scheduledDate: dummyNotification['scheduledDate'] as String,
                createdAt: dummyNotification['createdAt'] as String?,
                bgColor: dummyNotification['bgColor'] as int?,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


