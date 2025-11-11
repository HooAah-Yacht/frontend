class YachtPart {
  const YachtPart({
    required this.equipmentName,
    required this.manufacturerName,
    required this.modelName,
    required this.latestMaintenanceDate,
    required this.maintenancePeriodInMonths,
  });

  final String equipmentName;
  final String manufacturerName;
  final String modelName;
  final DateTime latestMaintenanceDate;
  final int maintenancePeriodInMonths;
}


