import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../widgets/yacht/create1/create_yacht_app_bar.dart';
import '../widgets/yacht/create1/create_yacht_basic_info_section.dart';
import '../widgets/yacht/create1/create_yacht_document_section.dart';
import '../widgets/yacht/create1/create_yacht_next_button_section.dart';
import '../widgets/yacht/create1/create_yacht_page_title.dart';
import 'create2_yacht_screen.dart';

class Create1YachtScreen extends StatefulWidget {
  const Create1YachtScreen({super.key});

  @override
  State<Create1YachtScreen> createState() => _Create1YachtScreenState();
}

class _Create1YachtScreenState extends State<Create1YachtScreen> {
  final TextEditingController _aliasController = TextEditingController();
  List<PlatformFile> _documents = [];
  String? _selectedYacht;

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  void _handleDocumentsPicked(List<PlatformFile> files) {
    setState(() {
      _documents = [
        ..._documents,
        ...files,
      ];
    });

    for (final file in files) {
      debugPrint('선택한 문서: ${file.name}');
    }
  }

  void _handleRemoveDocument(PlatformFile file) {
    setState(() {
      _documents = List<PlatformFile>.from(_documents)..remove(file);
    });
  }

  void _handleYachtSelected(String value) {
    setState(() {
      _selectedYacht = value;
    });
  }

  void _handleNext(BuildContext context) {
    final selected = _selectedYacht;
    if (selected == null || selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('요트를 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final alias = _aliasController.text.trim().isEmpty
        ? selected
        : _aliasController.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Create2YachtScreen(
          yachtName: selected,
          yachtAlias: alias,
        ),
      ),
    );
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
            const CreateYachtPageTitle(),
            const SizedBox(height: 40),
            CreateYachtBasicInfoSection(
              selectedYacht: _selectedYacht,
              onYachtSelected: _handleYachtSelected,
              aliasController: _aliasController,
            ),
            const SizedBox(height: 40),
            CreateYachtDocumentSection(
              selectedFiles: _documents,
              onFilesPicked: _handleDocumentsPicked,
            ),
            const SizedBox(height: 40),
            CreateYachtUploadedFilesSection(
              files: _documents,
              onRemoveFile: _handleRemoveDocument,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CreateYachtNextButtonSection(
        onPressed: () => _handleNext(context),
      ),
    );
  }
}
