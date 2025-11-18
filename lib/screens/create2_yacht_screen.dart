import 'package:flutter/material.dart';

import '../widgets/yacht/create1/create_yacht_app_bar.dart';
import '../models/yacht_part.dart';
import '../widgets/yacht/create2/create_yacht_parts_page_title.dart';
import '../widgets/yacht/create2/create_yacht_parts_registration_section.dart';
import '../widgets/yacht/create2/create_yacht_register_button_section.dart';
import '../widgets/yacht/create2/recommended_parts_list.dart';
import '../services/yacht_service.dart';

class Create2YachtScreen extends StatefulWidget {
  const Create2YachtScreen({
    super.key,
    required this.yachtName,
    required this.yachtAlias,
  });

  final String yachtName;
  final String yachtAlias;

  @override
  State<Create2YachtScreen> createState() => _Create2YachtScreenState();
}

class _Create2YachtScreenState extends State<Create2YachtScreen> {
  final List<YachtPart> _parts = [];
  bool _isRegistering = false;

  void _handlePartAdded(YachtPart part) {
    setState(() {
      _parts.insert(0, part);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CreateYachtAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const CreateYachtPartsPageTitle(),
            const SizedBox(height: 40),
            CreateYachtPartsRegistrationSection(
              onPartAdded: _handlePartAdded,
              onPartRemoved: _handlePartRemoved,
              parts: _parts,
            ),
            const SizedBox(height: 40),
            const Text(
              '추천 부품',
              style: TextStyle(
                fontSize: 20,
                letterSpacing: -0.5,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const RecommendedPartsList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: CreateYachtRegisterButtonSection(
        onPressed: _isRegistering
            ? null
            : () {
                _handleRegister();
              },
      ),
    );
  }

  void _handlePartRemoved(YachtPart part) {
    setState(() {
      _parts.remove(part);
    });
  }

  Future<void> _handleRegister() async {
    if (_isRegistering) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      // 백엔드 AddPartDto 구조에 맞게 데이터 변환
      final parts = _parts
          .map(
            (part) => {
              'name': part.equipmentName,
              'manufacturer': part.manufacturerName,
              'model': part.modelName,
              'interval': part.maintenancePeriodInMonths,
              // lastRepair: DateTime을 ISO 8601 형식으로 변환 (OffsetDateTime으로 파싱됨)
              // UTC로 변환하여 타임존 정보 포함
              'lastRepair': part.latestMaintenanceDate.toUtc().toIso8601String(),
            },
          )
          .toList();

      final result = await YachtService.createYacht(
        yachtName: widget.yachtName,
        yachtAlias: widget.yachtAlias,
        parts: parts,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // 등록 성공 시 결과를 반환하고 홈 스크린으로 이동
        Navigator.of(context).popUntil((route) => route.isFirst);
        // MainScreen의 리스트 갱신을 위해 약간의 지연 후 갱신
        // MainScreen이 이미 마운트되어 있으므로 직접 갱신할 수 없으므로
        // Navigator.popUntil 후 MainScreen의 생명주기에서 갱신되도록 함
      } else {
        // 등록 실패 시 에러 메시지 표시
        setState(() {
          _isRegistering = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '요트 등록에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRegistering = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('요트 등록 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}



