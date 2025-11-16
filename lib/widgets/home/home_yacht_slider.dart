import 'package:flutter/material.dart';
import 'package:frontend/widgets/common/custom_button.dart';

class HomeYachtSlider extends StatefulWidget {
  final List<Map<String, dynamic>> yachtList;

  const HomeYachtSlider({
    super.key,
    required this.yachtList,
  });

  @override
  State<HomeYachtSlider> createState() => _HomeYachtSliderState();
}

class _HomeYachtSliderState extends State<HomeYachtSlider> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getImagePath(String name) {
    // 대문자를 소문자로 변환하고 특수문자 제거 (공백은 유지)
    String normalized = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    // 앞뒤 공백 제거 및 연속 공백을 단일 공백으로 변환
    normalized = normalized.trim().replaceAll(RegExp(r'\s+'), ' ');
    final imagePath = 'assets/image/yacht/$normalized.png';
    print('이미지 경로: $imagePath');
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.yachtList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 345 + 24 + 34, // 이미지 + 간격 + 텍스트 높이만
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.yachtList.length,
            itemBuilder: (context, index) {
              final yacht = widget.yachtList[index];
              final yachtName = yacht['name'] as String? ?? '';
              final imagePath = _getImagePath(yachtName);

              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imagePath,
                      width: 345,
                      height: 345,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 이미지가 없을 경우 기본 이미지 또는 플레이스홀더
                        print('이미지 로드 실패: $imagePath');
                        print('에러: $error');
                        return Container(
                          width: 345,
                          height: 345,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 100),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    yachtName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: '요트 상세보기',
          onPressed: () {
            // TODO: 요트 상세보기 스크린으로 이동
            // Navigator.of(context).push(...);
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.yachtList.length,
            (index) => Container(
              margin: EdgeInsets.only(
                right: index < widget.yachtList.length - 1 ? 4 : 0,
              ),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? Colors.black
                    : const Color(0xFFB0B8C1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

