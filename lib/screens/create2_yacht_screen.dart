import 'package:flutter/material.dart';

import '../widgets/yacht/create1/create_yacht_app_bar.dart';
import '../widgets/yacht/create2/create_yacht_parts_page_title.dart';
import '../widgets/yacht/create2/create_yacht_parts_registration_section.dart';

class Create2YachtScreen extends StatelessWidget {
  const Create2YachtScreen({
    super.key,
    required this.yachtName,
    required this.yachtAlias,
  });

  final String yachtName;
  final String yachtAlias;

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
              parts: const [],
              onAddParts: () {},
            ),
          ],
        ),
      ),
    );
  }
}


