import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDatePicker extends StatelessWidget {
  const CustomDatePicker({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.selectedDate,
  });

  final String hintText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onChanged;

  int _daysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0).day;
    }
    return DateTime(year, month + 1, 0).day;
  }

  Future<void> _showPicker(BuildContext context) async {
    final now = DateTime.now();
    final years = List<int>.generate(51, (index) => now.year - index);
    const months = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    final initialDate = selectedDate ?? now;
    var tempYear = initialDate.year;
    var tempMonth = initialDate.month;
    var tempDay = initialDate.day;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final days = List<int>.generate(
              _daysInMonth(tempYear, tempMonth),
              (index) => index + 1,
            );

            if (tempDay > days.last) {
              tempDay = days.last;
            }

            return SizedBox(
              height: 320,
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onChanged(DateTime(tempYear, tempMonth, tempDay));
                          },
                          child: const Text('완료'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: years.indexOf(tempYear),
                            ),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                tempYear = years[index];
                              });
                            },
                            children: years
                                .map(
                                  (year) => Center(
                                    child: Text(
                                      '$year년',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        letterSpacing: -0.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: tempMonth - 1,
                            ),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                tempMonth = months[index];
                              });
                            },
                            children: months
                                .map(
                                  (month) => Center(
                                    child: Text(
                                      '$month월',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        letterSpacing: -0.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: tempDay - 1,
                            ),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                tempDay = days[index];
                              });
                            },
                            children: days
                                .map(
                                  (day) => Center(
                                    child: Text(
                                      '$day일',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        letterSpacing: -0.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = selectedDate;
    final displayText = displayDate != null
        ? '${displayDate.year}년 ${displayDate.month}월 ${displayDate.day}일'
        : hintText;
    final isHint = displayDate == null;

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      color: isHint ? const Color(0xFF47546F) : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.expand_more,
                  size: 20,
                  color: Color(0xFF47546F),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

