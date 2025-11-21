import 'package:flutter/material.dart';
import 'package:frontend/services/share/share_method.dart';

/// 공유 방법 선택 다이얼로그 (Single Responsibility Principle)
class ShareMethodDialog extends StatelessWidget {
  const ShareMethodDialog({super.key});

  /// 다이얼로그를 표시하고 선택된 공유 방법을 반환합니다.
  static Future<ShareMethod?> show(BuildContext context) {
    return showDialog<ShareMethod>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ShareMethodDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카카오톡으로 친구 초대를 진행합니다.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB0B8C1),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(ShareMethod.kakao),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B4184),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    '초대',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

