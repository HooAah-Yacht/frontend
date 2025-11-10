import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CustomDocumentPicker extends StatefulWidget {
  const CustomDocumentPicker({
    super.key,
    required this.hintText,
    this.allowMultiple = true,
    this.onFilesPicked,
    this.suffixIcon,
    this.selectedFiles,
    this.showSelectedFileNames = true,
  });

  final String hintText;
  final bool allowMultiple;
  final ValueChanged<List<PlatformFile>>? onFilesPicked;
  final Widget? suffixIcon;
  final List<PlatformFile>? selectedFiles;
  final bool showSelectedFileNames;

  @override
  State<CustomDocumentPicker> createState() => _CustomDocumentPickerState();
}

class _CustomDocumentPickerState extends State<CustomDocumentPicker> {
  bool _isPicking = false;

  Future<void> _pickDocuments() async {
    if (_isPicking) {
      return;
    }

    setState(() {
      _isPicking = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: widget.allowMultiple,
        type: FileType.any,
      );

      if (!mounted) {
        return;
      }

      if (result != null && result.files.isNotEmpty) {
        widget.onFilesPicked?.call(result.files);
      }
    } catch (error) {
      debugPrint('문서 선택 중 오류가 발생했습니다: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFiles = widget.selectedFiles ?? const <PlatformFile>[];
    final hasSelectedFiles =
        widget.showSelectedFileNames && selectedFiles.isNotEmpty;
    final displayText = hasSelectedFiles
        ? selectedFiles.map((file) => file.name).join(', ')
        : widget.hintText;
    final isHint = !hasSelectedFiles;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _pickDocuments,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF47546F),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: -0.5,
                      color:
                          isHint ? const Color(0xFF47546F) : Colors.black,
                    ),
                  ),
                ),
                if (widget.suffixIcon != null) ...[
                  const SizedBox(width: 16),
                  widget.suffixIcon!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


