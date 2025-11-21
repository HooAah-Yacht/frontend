import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class CustomSnackBar {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration? duration,
  }) {
    // 기존 오버레이 제거
    hide();

    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding + 24,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    hide();
                  },
                  child: SvgPicture.asset(
                    'assets/image/cancel_icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);

    // 자동으로 사라지게 하기
    _timer = Timer(duration ?? const Duration(seconds: 1), () {
      hide();
    });
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: Colors.red,
    );
  }
}

