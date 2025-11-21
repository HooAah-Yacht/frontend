import 'package:flutter/material.dart';

class InviteAcceptDialog extends StatelessWidget {
  final int inviteCode;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const InviteAcceptDialog({
    super.key,
    required this.inviteCode,
    this.onAccept,
    this.onReject,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int inviteCode,
    VoidCallback? onAccept,
    VoidCallback? onReject,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InviteAcceptDialog(
        inviteCode: inviteCode,
        onAccept: onAccept,
        onReject: onReject,
      ),
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
              '요트 초대',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '요트 초대를 수락하시겠습니까?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '초대 코드: $inviteCode',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB0B8C1),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    onReject?.call();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    '거절',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB0B8C1),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onAccept?.call();
                  },
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
                    '수락',
                    style: TextStyle(
                      fontSize: 16,
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

