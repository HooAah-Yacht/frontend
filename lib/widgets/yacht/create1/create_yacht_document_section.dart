import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/custom_document_picker.dart';
import '../../common/document_file_list_item.dart';

class CreateYachtDocumentSection extends StatelessWidget {
  const CreateYachtDocumentSection({
    super.key,
    required this.selectedFiles,
    required this.onFilesPicked,
  });

  final List<PlatformFile> selectedFiles;
  final ValueChanged<List<PlatformFile>> onFilesPicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '요트 문서 등록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        CustomDocumentPicker(
          hintText: '문서를 등록해주세요',
          selectedFiles: selectedFiles,
          showSelectedFileNames: false,
          onFilesPicked: onFilesPicked,
          suffixIcon: SvgPicture.asset(
            'assets/image/search_icon.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Color(0xFF47546F),
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '요트 매뉴얼, 부품 정보 등 관련 자료를 첨부할 수 있어요',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: -0.5,
            color: Color(0xFF47546F),
          ),
        ),
      ],
    );
  }
}

class CreateYachtUploadedFilesSection extends StatelessWidget {
  const CreateYachtUploadedFilesSection({
    super.key,
    required this.files,
    required this.onRemoveFile,
  });

  final List<PlatformFile> files;
  final ValueChanged<PlatformFile> onRemoveFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '등록된 파일',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        if (files.isEmpty)
          const Center(
            child: Text(
              '등록된 파일이 없어요',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: -0.5,
                color: Color(0xFF47546F),
              ),
            ),
          )
        else
          ...[
            for (var i = 0; i < files.length; i++) ...[
              DocumentFileListItem(
                fileName: files[i].name,
                onRemove: () => onRemoveFile(files[i]),
              ),
              if (i != files.length - 1) const SizedBox(height: 16),
            ],
          ],
      ],
    );
  }
}

