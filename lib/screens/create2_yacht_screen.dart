import 'package:flutter/material.dart';

import '../widgets/yacht/create1/create_yacht_app_bar.dart';
import '../models/yacht_part.dart';
import '../widgets/yacht/create2/create_yacht_parts_page_title.dart';
import '../widgets/yacht/create2/create_yacht_parts_registration_section.dart';
import '../widgets/yacht/create2/create_yacht_register_button_section.dart';
import '../widgets/yacht/create2/recommended_parts_list.dart';

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
        onPressed: _handleRegister,
      ),
    );
  }

  void _handlePartRemoved(YachtPart part) {
    setState(() {
      _parts.remove(part);
    });
  }

  void _handleRegister() {
    final payload = {
      'yachtName': widget.yachtName,
      'yachtAlias': widget.yachtAlias,
      'parts': _parts
          .map(
            (part) => {
              'name': part.equipmentName,
              'manufacturer': part.manufacturerName,
              'model': part.modelName,
              'latestMaintenanceDate': part.latestMaintenanceDate.toIso8601String(),
              'interval': part.maintenancePeriodInMonths,
            },
          )
          .toList(),
    };

    debugPrint('등록 데이터: $payload');
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}



