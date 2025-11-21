import 'package:flutter/material.dart';
import 'package:frontend/widgets/settings/settings_top_bar.dart';
import 'package:frontend/widgets/settings/logout_button.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/common/custom_snackbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    // 확인 다이얼로그 표시
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      // 토큰 삭제
      await AuthService.deleteToken();

      if (context.mounted) {
        // 로그인 화면으로 이동 (모든 이전 화면 제거)
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );

        CustomSnackBar.showSuccess(
          context,
          message: '로그아웃되었습니다.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: '로그아웃 중 오류가 발생했습니다.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SettingsTopBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              LogoutButton(
                onPressed: () => _handleLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

