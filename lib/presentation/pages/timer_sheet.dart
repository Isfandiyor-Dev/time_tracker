import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/time_math.dart';
import '../../generated/locale_keys.g.dart';
import '../cubit/tracker_cubit.dart';
import 'entry_editor_page.dart';

Future<void> showRunningTimerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    builder: (_) => const RunningTimerSheet(),
  );
}

class RunningTimerSheet extends StatelessWidget {
  const RunningTimerSheet({super.key});

  Future<void> _punchOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    final entry = await context.read<TrackerCubit>().punchOut(
      requestEditor: false,
    );
    if (entry == null || !context.mounted) return;
    await navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => EntryEditorPage(entry: entry)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackerCubit, TrackerState>(
      builder: (context, state) {
        final timer = state.runningTimer;
        if (timer == null) return const SizedBox.shrink();
        final now = state.now ?? DateTime.now();
        final workedSeconds = timer.elapsedSeconds(now);
        final stopwatchSeconds = timer.stopwatchSeconds(now);
        final earnings = calculateExactEarnings(
          workedSeconds,
          timer.hourlyRate,
        );
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: LocaleKeys.timer_minimizeTooltip.tr(),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
            title: Text(LocaleKeys.timer_title.tr()),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                children: [
                  const Spacer(),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: .94, end: 1),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(
                          color: timer.isOnBreak
                              ? AppColors.warning
                              : AppColors.lime,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (timer.isOnBreak
                                        ? AppColors.warning
                                        : AppColors.lime)
                                    .withValues(alpha: .16),
                            blurRadius: 45,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              timer.isOnBreak
                                  ? Icons.coffee_rounded
                                  : Icons.bolt_rounded,
                              key: ValueKey(timer.isOnBreak),
                              size: 32,
                              color: timer.isOnBreak
                                  ? AppColors.warning
                                  : AppColors.lime,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            formatDuration(
                              stopwatchSeconds,
                              includeSeconds: true,
                            ),
                            style: const TextStyle(
                              fontSize: 39,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (timer.isOnBreak
                                    ? LocaleKeys.timer_onBreak
                                    : LocaleKeys.timer_working)
                                .tr(),
                            style: TextStyle(
                              color: timer.isOnBreak
                                  ? AppColors.warning
                                  : AppColors.lime,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Text(
                    timer.projectName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocaleKeys.timer_fromAndEarnings.tr(
                      namedArgs: {
                        'time': formatTime(timer.startedAt),
                        'earnings': formatMoney(earnings, timer.currency),
                      },
                    ),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: context.read<TrackerCubit>().toggleBreak,
                          icon: Icon(
                            timer.isOnBreak
                                ? Icons.play_arrow_rounded
                                : Icons.coffee_outlined,
                          ),
                          label: Text(
                            (timer.isOnBreak
                                    ? LocaleKeys.timer_endBreak
                                    : LocaleKeys.timer_break)
                                .tr(),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: timer.isOnBreak
                                ? AppColors.warning
                                : AppColors.text,
                            minimumSize: const Size.fromHeight(58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _punchOut(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.stop_rounded),
                          label: Text(LocaleKeys.timer_punchOut.tr()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MiniTimerBar extends StatefulWidget {
  const MiniTimerBar({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<MiniTimerBar> createState() => _MiniTimerBarState();
}

class _MiniTimerBarState extends State<MiniTimerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackerCubit, TrackerState>(
      buildWhen: (previous, current) =>
          previous.runningTimer != current.runningTimer ||
          previous.now != current.now,
      builder: (context, state) {
        final timer = state.runningTimer;
        if (timer == null) return const SizedBox.shrink();
        final seconds = timer.stopwatchSeconds(state.now ?? DateTime.now());
        return SizedBox(
          width: double.infinity,
          height: 68,
          child: Material(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(20),
            elevation: 10,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    if (timer.isOnBreak)
                      const _TimerStatusDot(color: AppColors.warning)
                    else
                      FadeTransition(
                        opacity: Tween<double>(
                          begin: .35,
                          end: 1,
                        ).animate(_pulse),
                        child: const _TimerStatusDot(color: AppColors.danger),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        timer.projectName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      formatDuration(seconds, includeSeconds: true),
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.lime,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimerStatusDot extends StatelessWidget {
  const _TimerStatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
