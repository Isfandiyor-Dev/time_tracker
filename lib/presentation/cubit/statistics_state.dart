part of 'statistics_cubit.dart';

class StatisticsState extends Equatable {
  const StatisticsState({
    required this.anchor,
    this.selectedProjectId,
    this.displayCurrency = 'UZS',
    this.metric = StatisticsMetric.earnings,
    this.period = StatisticsPeriod.month,
    this.data,
    this.selectedBucketIndex,
    this.selectedData,
    this.rateStatus = ExchangeRateStatus.idle,
    this.conversionError,
  });

  final int? selectedProjectId;
  final String displayCurrency;
  final StatisticsMetric metric;
  final StatisticsPeriod period;
  final DateTime anchor;
  final StatisticsData? data;
  final int? selectedBucketIndex;
  final StatisticsData? selectedData;
  final ExchangeRateStatus rateStatus;
  final String? conversionError;

  StatisticsData? get visibleData => selectedData ?? data;

  bool get canGoNext {
    final nextAnchor = StatisticsCalculator.moveAnchor(period, anchor, 1);
    final nextRange = StatisticsCalculator.rangeFor(period, nextAnchor);
    final today = DateTime.now();
    return !nextRange.start.isAfter(today);
  }

  StatisticsState copyWith({
    int? selectedProjectId,
    bool clearProject = false,
    String? displayCurrency,
    StatisticsMetric? metric,
    StatisticsPeriod? period,
    DateTime? anchor,
    StatisticsData? data,
    int? selectedBucketIndex,
    bool clearBucketSelection = false,
    StatisticsData? selectedData,
    bool clearSelectedData = false,
    ExchangeRateStatus? rateStatus,
    String? conversionError,
    bool clearError = false,
  }) {
    return StatisticsState(
      anchor: anchor ?? this.anchor,
      selectedProjectId: clearProject
          ? selectedProjectId
          : selectedProjectId ?? this.selectedProjectId,
      displayCurrency: displayCurrency ?? this.displayCurrency,
      metric: metric ?? this.metric,
      period: period ?? this.period,
      data: data ?? this.data,
      selectedBucketIndex: clearBucketSelection
          ? null
          : selectedBucketIndex ?? this.selectedBucketIndex,
      selectedData: clearSelectedData
          ? null
          : selectedData ?? this.selectedData,
      rateStatus: rateStatus ?? this.rateStatus,
      conversionError: clearError
          ? null
          : conversionError ?? this.conversionError,
    );
  }

  @override
  List<Object?> get props => [
    selectedProjectId,
    displayCurrency,
    metric,
    period,
    anchor,
    data,
    selectedBucketIndex,
    selectedData,
    rateStatus,
    conversionError,
  ];
}
