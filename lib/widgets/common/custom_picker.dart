import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomPicker extends StatelessWidget {
  const CustomPicker({
    super.key,
    required this.items,
    required this.hintText,
    required this.onSelected,
    this.selectedValue,
  });

  final List<String> items;
  final String hintText;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  Future<void> _showPicker(BuildContext context) async {
    if (items.isEmpty) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final initialIndex = selectedValue != null
          ? (items.indexOf(selectedValue!) >= 0
              ? items.indexOf(selectedValue!)
              : 0)
          : 0;
      var tempValue = items[initialIndex];

      final result = await showCupertinoModalPopup<String>(
        context: context,
        builder: (modalContext) {
          return Container(
            height: 320,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onPressed: () => Navigator.of(modalContext).pop(),
                        child: const Text('취소'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onPressed: () =>
                            Navigator.of(modalContext).pop(tempValue),
                        child: const Text('완료'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    itemExtent: 44,
                    onSelectedItemChanged: (index) {
                      tempValue = items[index];
                    },
                    children: items
                        .map(
                          (item) => Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (result != null) {
        onSelected(result);
      }

      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final option = items[index];
              return ListTile(
                title: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 16,
                    letterSpacing: -0.5,
                  ),
                ),
                onTap: () => Navigator.of(modalContext).pop(option),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedValue ?? hintText;
    final isHint = selectedValue == null || selectedValue!.isEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPicker(context),
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
              horizontal: 28,
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
                const SizedBox(width: 16),
                SvgPicture.asset(
                  'assets/image/arrow_icon.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF47546F),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


