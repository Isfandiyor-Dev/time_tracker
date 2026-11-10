import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/services/file_statistics_preferences.dart';
import '../../data/services/frankfurter_exchange_rate_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/entities/time_entry.dart';
import '../../generated/locale_keys.g.dart';
import '../cubit/statistics_cubit.dart';
import '../widgets/anchored_dropdown_field.dart';
import 'entry_editor_page.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({
    super.key,
    required this.projects,
    required this.entries,
  });

  final List<Project> projects;
  final List<TimeEntry> entries;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatisticsCubit(
        FrankfurterExchangeRateRepository(),
        FileStatisticsPreferences(),
        projects: projects,
        entries: entries,
      )..initialize(),
      child: _StatisticsView(projects: projects),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              LocaleKeys.statistics_title.tr(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: RefreshIndicator(
            color: AppColors.background,
            backgroundColor: AppColors.lime,
            onRefresh: context.read<StatisticsCubit>().refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  sliver: SliverList.list(
                    children: [
                      _Filters(projects: projects, state: state),
                      const SizedBox(height: 18),
                      _Segmented<StatisticsMetric>(
                        value: state.metric,
                        items: {
                          StatisticsMetric.earnings: LocaleKeys
                              .statistics_earnings
                              .tr(),
                          StatisticsMetric.time: LocaleKeys.statistics_time
                              .tr(),
                        },
                        onChanged: context.read<StatisticsCubit>().selectMetric,
                      ),
                      const SizedBox(height: 12),
                      _Segmented<StatisticsPeriod>(
                        value: state.period,
                        items: {
                          StatisticsPeriod.week: LocaleKeys.statistics_week
                              .tr(),
                          StatisticsPeriod.month: LocaleKeys.statistics_month
                              .tr(),
                          StatisticsPeriod.year: LocaleKeys.statistics_year
                              .tr(),
                        },
                        onChanged: context.read<StatisticsCubit>().selectPeriod,
                      ),
                      const SizedBox(height: 16),
                      _PeriodNavigator(state: state),
                      const SizedBox(height: 14),
                      if (projects.isEmpty)
                        const _NoProjects()
                      else if (state.data == null)
                        const _LoadingCard()
                      else ...[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: _SummaryAndChart(
                            key: ValueKey(
                              '${state.period}-${state.anchor}-${state.metric}-${state.displayCurrency}-${state.selectedProjectId}',
                            ),
                            state: state,
                          ),
                        ),
                        if (state.rateStatus ==
                            ExchangeRateStatus.unavailable) ...[
                          const SizedBox(height: 12),
                          _ConversionWarning(
                            onRetry: context.read<StatisticsCubit>().refresh,
                          ),
                        ],
                        if (!state.visibleData!.isEmpty) ...[
                          if (state.metric == StatisticsMetric.earnings) ...[
                            const SizedBox(height: 14),
                            _PaidSummary(state: state),
                            const SizedBox(height: 14),
                            _CurrencyBreakdown(data: state.visibleData!),
                          ],
                          const SizedBox(height: 22),
                          _EntryGroups(state: state),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.projects, required this.state});

  final List<Project> projects;
  final StatisticsState state;

  @override
  Widget build(BuildContext context) {
    final projectItems = <int?, String>{
      null: LocaleKeys.statistics_allProjects.tr(),
      for (final project in projects) project.id: project.name,
    };
    final projectField = AnchoredDropdownField<int?>(
      value: state.selectedProjectId,
      items: projectItems,
      onChanged: context.read<StatisticsCubit>().selectProject,
      prefixIcon: Icons.folder_copy_outlined,
      prefixIconColor: AppColors.lime,
    );
    final currencyField = AnchoredDropdownField<String>(
      value: state.displayCurrency,
      items: {
        for (final currency in StatisticsCubit.supportedCurrencies)
          currency: currency,
      },
      onChanged: context.read<StatisticsCubit>().selectCurrency,
      prefixIcon: Icons.currency_exchange_rounded,
      prefixIconColor: AppColors.cyan,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: state.metric == StatisticsMetric.time
          ? SizedBox(key: const ValueKey('project-only'), child: projectField)
          : Row(
              key: const ValueKey('project-currency'),
              children: [
                Expanded(flex: 9, child: projectField),
                const SizedBox(width: 10),
                Expanded(flex: 6, child: currencyField),
              ],
            ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: items.entries
            .map((item) {
              final selected = item.key == value;
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(item.key),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.lime : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected
                            ? AppColors.background
                            : AppColors.textMuted,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _PeriodNavigator extends StatelessWidget {
  const _PeriodNavigator({required this.state});

  final StatisticsState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundArrow(
          tooltip: LocaleKeys.statistics_previousPeriod.tr(),
          icon: Icons.arrow_back_rounded,
          onTap: context.read<StatisticsCubit>().previousPeriod,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              _periodLabel(state),
              key: ValueKey('${state.period}-${state.anchor}'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        _RoundArrow(
          tooltip: LocaleKeys.statistics_nextPeriod.tr(),
          icon: Icons.arrow_forward_rounded,
          onTap: state.canGoNext
              ? context.read<StatisticsCubit>().nextPeriod
              : null,
        ),
      ],
    );
  }
}

class _RoundArrow extends StatelessWidget {
  const _RoundArrow({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: onTap == null ? AppColors.surface : AppColors.surfaceHigh,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              color: onTap == null
                  ? AppColors.textMuted.withValues(alpha: 0.35)
                  : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryAndChart extends StatelessWidget {
  const _SummaryAndChart({super.key, required this.state});

  final StatisticsState state;

  @override
  Widget build(BuildContext context) {
    final data = state.visibleData!;
    final isEarnings = state.metric == StatisticsMetric.earnings;
    final primary = isEarnings
        ? data.convertedEarnings == null
              ? '—'
              : formatMoney(data.convertedEarnings!, state.displayCurrency)
        : formatDuration(data.totalSeconds);
    final secondary = isEarnings
        ? LocaleKeys.statistics_durationAndEntries.tr(
            namedArgs: {
              'duration': formatDuration(data.totalSeconds),
              'count': '${data.entries.length}',
            },
          )
        : LocaleKeys.statistics_entryCount.tr(
            namedArgs: {'count': '${data.entries.length}'},
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lime.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Text(
            _summaryLabel(state),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              primary,
              style: const TextStyle(
                fontSize: 32,
                height: 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(secondary, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 22),
          if (state.data!.isEmpty)
            _NoEntries(specificProject: state.selectedProjectId != null)
          else
            _StatisticsChart(state: state),
        ],
      ),
    );
  }
}

class _StatisticsChart extends StatelessWidget {
  const _StatisticsChart({required this.state});

  final StatisticsState state;

  @override
  Widget build(BuildContext context) {
    final buckets = state.data!.chartBuckets;
    final values = buckets
        .map((bucket) {
          return state.metric == StatisticsMetric.earnings
              ? bucket.earnings ?? 0
              : bucket.seconds.toDouble();
        })
        .toList(growable: false);
    final maxValue = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    return SizedBox(
      height: 176,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(buckets.length, (index) {
          final bucket = buckets[index];
          final value = values[index];
          final ratio = maxValue == 0 ? 0.0 : value / maxValue;
          final hasSelection = state.selectedBucketIndex != null;
          final isSelected = state.selectedBucketIndex == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.read<StatisticsCubit>().selectBucket(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          _compactChartValue(value, state),
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.lime
                                : AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: ratio),
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedRatio, _) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: value == 0 ? 4 : 100 * animatedRatio + 8,
                        decoration: BoxDecoration(
                          color: value == 0
                              ? AppColors.lime.withValues(
                                  alpha: isSelected ? 0.75 : 0.16,
                                )
                              : AppColors.lime.withValues(
                                  alpha: hasSelection && !isSelected
                                      ? 0.20
                                      : 0.40 + animatedRatio * 0.60,
                                ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(7),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.lime.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.lime.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _bucketLabel(bucket, state.period),
                        maxLines: 1,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.lime
                              : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PaidSummary extends StatelessWidget {
  const _PaidSummary({required this.state});

  final StatisticsState state;

  @override
  Widget build(BuildContext context) {
    final data = state.visibleData!;
    return Row(
      children: [
        Expanded(
          child: _MoneySummaryTile(
            label: LocaleKeys.statistics_paid.tr(),
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.lime,
            value: data.paidEarnings == null
                ? '—'
                : formatMoney(data.paidEarnings!, state.displayCurrency),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MoneySummaryTile(
            label: LocaleKeys.statistics_unpaid.tr(),
            icon: Icons.schedule_rounded,
            color: AppColors.warning,
            value: data.unpaidEarnings == null
                ? '—'
                : formatMoney(data.unpaidEarnings!, state.displayCurrency),
          ),
        ),
      ],
    );
  }
}

class _MoneySummaryTile extends StatelessWidget {
  const _MoneySummaryTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 7),
              Text(label, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyBreakdown extends StatelessWidget {
  const _CurrencyBreakdown({required this.data});

  final StatisticsData data;

  @override
  Widget build(BuildContext context) {
    final currencies = data.originalCurrencyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.cyan,
              ),
              const SizedBox(width: 10),
              Text(
                LocaleKeys.statistics_currencyBreakdown.tr(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < currencies.length; index++) ...[
            if (index > 0) const Divider(height: 18),
            Row(
              children: [
                Text(
                  currencies[index].key,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  formatMoney(currencies[index].value, currencies[index].key),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EntryGroups extends StatelessWidget {
  const _EntryGroups({required this.state});

  final StatisticsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: state.visibleData!.groups
          .map((group) {
            final total = state.metric == StatisticsMetric.earnings
                ? group.convertedEarnings == null
                      ? '—'
                      : formatMoney(
                          group.convertedEarnings!,
                          state.displayCurrency,
                        )
                : formatDuration(group.totalSeconds);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 13),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('d MMMM').format(group.date),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                LocaleKeys.statistics_entryCount.tr(
                                  namedArgs: {'count': '${group.items.length}'},
                                ),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            total,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    for (final item in group.items)
                      _StatisticsEntryTile(
                        item: item,
                        displayCurrency: state.displayCurrency,
                        showProject: state.selectedProjectId == null,
                      ),
                  ],
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _StatisticsEntryTile extends StatelessWidget {
  const _StatisticsEntryTile({
    required this.item,
    required this.displayCurrency,
    required this.showProject,
  });

  final StatisticsEntryItem item;
  final String displayCurrency;
  final bool showProject;

  @override
  Widget build(BuildContext context) {
    final entry = item.entry;
    final showConverted =
        entry.currencySnapshot.toUpperCase() != displayCurrency &&
        item.convertedEarnings != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EntryEditorPage(entry: entry)),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 13, 12, 13),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  size: 21,
                  color: AppColors.lime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showProject
                          ? item.project.name
                          : '${formatTime(entry.start)} – ${formatTime(entry.end)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDuration(entry.totalSeconds),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(entry.exactEarnings, entry.currencySnapshot),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (showConverted) ...[
                    const SizedBox(height: 4),
                    Text(
                      '≈ ${formatMoney(item.convertedEarnings!, displayCurrency)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversionWarning extends StatelessWidget {
  const _ConversionWarning({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.warning),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              LocaleKeys.statistics_conversionUnavailable.tr(),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(LocaleKeys.statistics_retry.tr()),
          ),
        ],
      ),
    );
  }
}

class _NoProjects extends StatelessWidget {
  const _NoProjects();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.bar_chart_rounded, size: 52, color: AppColors.lime),
          const SizedBox(height: 18),
          Text(
            LocaleKeys.statistics_noProjectsTitle.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.statistics_noProjectsMessage.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _NoEntries extends StatelessWidget {
  const _NoEntries({required this.specificProject});

  final bool specificProject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(
            Icons.insights_rounded,
            size: 42,
            color: AppColors.textMuted.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 12),
          Text(
            (specificProject
                    ? LocaleKeys.statistics_noProjectEntries
                    : LocaleKeys.statistics_noEntries)
                .tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

String _periodLabel(StatisticsState state) {
  final range = state.data?.range;
  return switch (state.period) {
    StatisticsPeriod.week =>
      range == null
          ? ''
          : '${DateFormat('MMM d').format(range.start)} – ${DateFormat('MMM d').format(range.endExclusive.subtract(const Duration(days: 1)))}',
    StatisticsPeriod.month => DateFormat('MMMM y').format(state.anchor),
    StatisticsPeriod.year => DateFormat('y').format(state.anchor),
  };
}

String _periodSummaryLabel(StatisticsPeriod period) => switch (period) {
  StatisticsPeriod.week => LocaleKeys.statistics_thisWeek.tr(),
  StatisticsPeriod.month => LocaleKeys.statistics_thisMonth.tr(),
  StatisticsPeriod.year => LocaleKeys.statistics_thisYear.tr(),
};

String _summaryLabel(StatisticsState state) {
  final selectedRange = state.selectedData?.range;
  if (selectedRange == null) return _periodSummaryLabel(state.period);
  final lastDay = selectedRange.endExclusive.subtract(const Duration(days: 1));
  return switch (state.period) {
    StatisticsPeriod.week => DateFormat(
      'EEEE, d MMMM',
    ).format(selectedRange.start),
    StatisticsPeriod.month =>
      '${DateFormat('d MMM').format(selectedRange.start)} – ${DateFormat('d MMM').format(lastDay)}',
    StatisticsPeriod.year => DateFormat('MMMM y').format(selectedRange.start),
  };
}

String _bucketLabel(
  StatisticsChartBucket bucket,
  StatisticsPeriod period,
) => switch (period) {
  StatisticsPeriod.week => DateFormat.E().format(bucket.start),
  StatisticsPeriod.month =>
    '${bucket.start.day}–${bucket.endExclusive.subtract(const Duration(days: 1)).day}',
  StatisticsPeriod.year => DateFormat.MMM().format(bucket.start),
};

String _compactChartValue(double value, StatisticsState state) {
  if (value == 0) return '0';
  if (state.metric == StatisticsMetric.time) {
    final seconds = value.round();
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${(seconds / 3600).toStringAsFixed(1)}h';
  }
  return NumberFormat.compact(locale: Intl.defaultLocale).format(value);
}
