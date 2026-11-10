import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/entities/time_entry.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../../domain/repositories/statistics_preferences.dart';
import '../../domain/services/statistics_calculator.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(
    this._exchangeRates,
    this._preferences, {
    required List<Project> projects,
    required List<TimeEntry> entries,
  }) : _projects = List.unmodifiable(projects),
       _entries = List.unmodifiable(entries),
       super(StatisticsState(anchor: DateTime.now()));

  static const supportedCurrencies = ['UZS', 'USD', 'EUR', 'RUB', 'KZT'];

  final List<Project> _projects;
  final List<TimeEntry> _entries;
  final ExchangeRateRepository _exchangeRates;
  final StatisticsPreferences _preferences;
  int _requestSerial = 0;
  Map<String, double> _activeRatesToDisplayCurrency = const {};

  Future<void> initialize() async {
    final savedCurrency = await _preferences.readDisplayCurrency();
    final projectCurrency = _projects.firstOrNull?.currency.toUpperCase();
    final initialCurrency = supportedCurrencies.contains(savedCurrency)
        ? savedCurrency!
        : supportedCurrencies.contains(projectCurrency)
        ? projectCurrency!
        : supportedCurrencies.first;
    emit(state.copyWith(displayCurrency: initialCurrency));
    await _reload();
  }

  void selectProject(int? projectId) {
    if (projectId == state.selectedProjectId) return;
    emit(state.copyWith(selectedProjectId: projectId, clearProject: true));
    unawaited(_reload());
  }

  void selectMetric(StatisticsMetric metric) {
    if (metric == state.metric) return;
    emit(state.copyWith(metric: metric));
    unawaited(_reload());
  }

  void selectPeriod(StatisticsPeriod period) {
    if (period == state.period) return;
    emit(
      state.copyWith(
        period: period,
        anchor: DateTime.now(),
        clearBucketSelection: true,
        clearSelectedData: true,
      ),
    );
    unawaited(_reload());
  }

  void selectBucket(int index) {
    final data = state.data;
    if (data == null || index < 0 || index >= data.chartBuckets.length) return;
    if (state.selectedBucketIndex == index) {
      emit(state.copyWith(clearBucketSelection: true, clearSelectedData: true));
      return;
    }
    emit(
      state.copyWith(
        selectedBucketIndex: index,
        selectedData: _calculateSelectedData(
          state: state.copyWith(selectedBucketIndex: index),
          fullData: data,
          rates: _activeRatesToDisplayCurrency,
        ),
      ),
    );
  }

  void selectCurrency(String currency) {
    final normalized = currency.toUpperCase();
    if (normalized == state.displayCurrency ||
        !supportedCurrencies.contains(normalized)) {
      return;
    }
    emit(state.copyWith(displayCurrency: normalized));
    unawaited(_preferences.saveDisplayCurrency(normalized));
    unawaited(_reload());
  }

  void previousPeriod() {
    emit(
      state.copyWith(
        anchor: StatisticsCalculator.moveAnchor(state.period, state.anchor, -1),
        clearBucketSelection: true,
        clearSelectedData: true,
      ),
    );
    unawaited(_reload());
  }

  void nextPeriod() {
    if (!state.canGoNext) return;
    emit(
      state.copyWith(
        anchor: StatisticsCalculator.moveAnchor(state.period, state.anchor, 1),
        clearBucketSelection: true,
        clearSelectedData: true,
      ),
    );
    unawaited(_reload());
  }

  Future<void> refresh() => _reload();

  Future<void> _reload() async {
    final request = ++_requestSerial;
    final snapshot = state;
    final range = StatisticsCalculator.rangeFor(
      snapshot.period,
      snapshot.anchor,
    );
    final entries = StatisticsCalculator.filteredEntries(
      entries: _entries,
      range: range,
      projectId: snapshot.selectedProjectId,
    );
    final localRates = <String, double>{snapshot.displayCurrency: 1};
    _activeRatesToDisplayCurrency = localRates;
    final localData = StatisticsCalculator.calculate(
      projects: _projects,
      allEntries: _entries,
      period: snapshot.period,
      anchor: snapshot.anchor,
      projectId: snapshot.selectedProjectId,
      displayCurrency: snapshot.displayCurrency,
      ratesToDisplayCurrency: localRates,
    );
    final localSelectedData = _calculateSelectedData(
      state: snapshot,
      fullData: localData,
      rates: localRates,
    );
    emit(
      snapshot.copyWith(
        data: localData,
        selectedData: localSelectedData,
        clearSelectedData: localSelectedData == null,
        rateStatus: snapshot.metric == StatisticsMetric.earnings
            ? ExchangeRateStatus.loading
            : ExchangeRateStatus.idle,
        clearError: true,
      ),
    );

    if (snapshot.metric == StatisticsMetric.time || entries.isEmpty) {
      if (request == _requestSerial) {
        emit(
          state.copyWith(data: localData, rateStatus: ExchangeRateStatus.ready),
        );
      }
      return;
    }

    final sources = entries
        .map((entry) => entry.currencySnapshot.toUpperCase())
        .where((currency) => currency != snapshot.displayCurrency)
        .toSet();
    if (sources.isEmpty) {
      if (request == _requestSerial) {
        emit(
          state.copyWith(data: localData, rateStatus: ExchangeRateStatus.ready),
        );
      }
      return;
    }

    try {
      final rates = await _exchangeRates.fetchRatesTo(
        sources: sources,
        target: snapshot.displayCurrency,
      );
      if (request != _requestSerial) return;
      final resolvedRates = <String, double>{
        snapshot.displayCurrency: 1,
        ...rates,
      };
      _activeRatesToDisplayCurrency = resolvedRates;
      final data = StatisticsCalculator.calculate(
        projects: _projects,
        allEntries: _entries,
        period: snapshot.period,
        anchor: snapshot.anchor,
        projectId: snapshot.selectedProjectId,
        displayCurrency: snapshot.displayCurrency,
        ratesToDisplayCurrency: resolvedRates,
      );
      final selectedData = _calculateSelectedData(
        state: state,
        fullData: data,
        rates: resolvedRates,
      );
      emit(
        state.copyWith(
          data: data,
          selectedData: selectedData,
          clearSelectedData: selectedData == null,
          rateStatus: data.conversionComplete
              ? ExchangeRateStatus.ready
              : ExchangeRateStatus.unavailable,
          conversionError: data.conversionComplete ? null : 'missingRates',
          clearError: data.conversionComplete,
        ),
      );
    } on Object {
      if (request != _requestSerial) return;
      emit(
        state.copyWith(
          data: localData,
          rateStatus: ExchangeRateStatus.unavailable,
          conversionError: 'network',
        ),
      );
    }
  }

  StatisticsData? _calculateSelectedData({
    required StatisticsState state,
    required StatisticsData fullData,
    required Map<String, double> rates,
  }) {
    final index = state.selectedBucketIndex;
    if (index == null || index < 0 || index >= fullData.chartBuckets.length) {
      return null;
    }
    final bucket = fullData.chartBuckets[index];
    return StatisticsCalculator.calculate(
      projects: _projects,
      allEntries: _entries,
      period: state.period,
      anchor: state.anchor,
      projectId: state.selectedProjectId,
      displayCurrency: state.displayCurrency,
      ratesToDisplayCurrency: rates,
      rangeOverride: StatisticsRange(
        start: bucket.start,
        endExclusive: bucket.endExclusive,
      ),
      includeChart: false,
    );
  }
}
