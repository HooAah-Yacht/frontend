class PartRepairStatus {
  final String iconPath;
  final int bgColor;
  final String title;

  PartRepairStatus({
    required this.iconPath,
    required this.bgColor,
    required this.title,
  });
}

class PartRepairStatusCalculator {
  /// 예상 정비일을 계산하여 상태 정보를 반환합니다.
  /// 
  /// [lastRepairStr] 마지막 정비일 (ISO 8601 문자열)
  /// [interval] 정비 주기 (월)
  /// 
  /// 반환값:
  /// - 7일 초과: good 상태
  /// - 7일 이하: warning 상태
  /// - 음수: danger 상태
  static PartRepairStatus? calculateStatus(String? lastRepairStr, int? interval) {
    if (lastRepairStr == null || interval == null) {
      return null;
    }

    try {
      final now = DateTime.now();
      final lastRepair = DateTime.parse(lastRepairStr);

      // 마지막 정비일 + 주기(월) = 다음 정비일
      final nextRepairDate = DateTime(
        lastRepair.year,
        lastRepair.month + interval,
        lastRepair.day,
        lastRepair.hour,
        lastRepair.minute,
        lastRepair.second,
      );

      // 남은 일수 계산 (다음 정비일 - 오늘)
      final daysRemaining = nextRepairDate.difference(now).inDays;

      if (daysRemaining < 0) {
        // 정비일이 지남
        return PartRepairStatus(
          iconPath: 'assets/image/danger_icon.png',
          bgColor: 0xFFECC8C4, // #ECC8C4
          title: '예상 정비일이 지났어요',
        );
      } else if (daysRemaining <= 7) {
        // 7일 이하로 남음
        return PartRepairStatus(
          iconPath: 'assets/image/warning_icon.png',
          bgColor: 0xFFF8F3D6, // #F8F3D6
          title: '예상 정비일이 $daysRemaining일 남았어요',
        );
      } else {
        // 7일 초과로 남음
        return PartRepairStatus(
          iconPath: 'assets/image/good_icon.png',
          bgColor: 0xFFDEF3D6, // #DEF3D6
          title: '예상 정비일까지 여유있어요',
        );
      }
    } catch (e) {
      print('날짜 파싱 오류: $e');
      return null;
    }
  }
}

