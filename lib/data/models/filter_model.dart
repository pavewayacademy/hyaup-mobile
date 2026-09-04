class FilterModel {
  final num? minSalary;
  final bool? hasPaidPto;
  final bool? hasHealthCoverage;
  final String? remoteMode; // 'remote', 'hybrid', 'onsite', or null
  final String? sourceType; // 'native', 'external', or null

  const FilterModel({
    this.minSalary,
    this.hasPaidPto,
    this.hasHealthCoverage,
    this.remoteMode,
    this.sourceType,
  });

  bool get isEmpty =>
      (minSalary == null || minSalary! <= 0) &&
      (hasPaidPto != true) &&
      (hasHealthCoverage != true) &&
      (remoteMode == null || remoteMode!.isEmpty) &&
      (sourceType == null || sourceType!.isEmpty);

  int get activeFilterCount {
    int count = 0;
    if (minSalary != null && minSalary! > 0) count++;
    if (hasPaidPto == true) count++;
    if (hasHealthCoverage == true) count++;
    if (remoteMode != null && remoteMode!.isNotEmpty) count++;
    if (sourceType != null && sourceType!.isNotEmpty) count++;
    return count;
  }

  FilterModel copyWith({
    num? minSalary,
    bool? hasPaidPto,
    bool? hasHealthCoverage,
    String? remoteMode,
    String? sourceType,
    bool clearMinSalary = false,
    bool clearRemoteMode = false,
    bool clearSourceType = false,
  }) {
    return FilterModel(
      minSalary: clearMinSalary ? null : (minSalary ?? this.minSalary),
      hasPaidPto: hasPaidPto ?? this.hasPaidPto,
      hasHealthCoverage: hasHealthCoverage ?? this.hasHealthCoverage,
      remoteMode: clearRemoteMode ? null : (remoteMode ?? this.remoteMode),
      sourceType: clearSourceType ? null : (sourceType ?? this.sourceType),
    );
  }

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    if (minSalary != null && minSalary! > 0) {
      params['min_salary'] = minSalary;
    }
    if (hasPaidPto == true) {
      params['paid_pto'] = true;
    }
    if (hasHealthCoverage == true) {
      params['health_coverage'] = true;
    }
    if (remoteMode != null && remoteMode!.isNotEmpty) {
      params['remote_mode'] = remoteMode;
    }
    if (sourceType != null && sourceType!.isNotEmpty) {
      params['source_type'] = sourceType;
    }
    return params;
  }
}
