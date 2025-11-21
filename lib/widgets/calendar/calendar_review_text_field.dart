import 'package:flutter/material.dart';

class CalendarReviewTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CalendarReviewTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 24.0 * 2; // 좌우 패딩
    final fieldWidth = screenWidth - horizontalPadding;
    final fieldHeight = fieldWidth; // 1:1 비율

    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.newline,
        enableInteractiveSelection: true,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 16,
          letterSpacing: -0.5,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF47546F),
            fontSize: 16,
            letterSpacing: -0.5,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(24),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF47546F),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF2B4184),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

