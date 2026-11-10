import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../core/errors/localized_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/time_entry.dart';
import '../../generated/locale_keys.g.dart';
import '../cubit/tracker_cubit.dart';
import '../widgets/anchored_dropdown_field.dart';
import '../widgets/app_surface.dart';
import 'notes_page.dart';

class EntryEditorPage extends StatefulWidget {
  const EntryEditorPage({super.key, this.entry, this.initialProjectId});

  final TimeEntry? entry;
  final int? initialProjectId;

  @override
  State<EntryEditorPage> createState() => _EntryEditorPageState();
}

class _EntryEditorPageState extends State<EntryEditorPage> {
  late int _projectId;
  late DateTime _start;
  late DateTime _end;
  late List<BreakPeriod> _breaks;
  late String _notes;
  late bool _isPaid;
  late final TextEditingController _rate;
  late String _currency;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final projects = context.read<TrackerCubit>().state.projects;
    final first = projects.first;
    final entry = widget.entry;
    _projectId = entry?.projectId ?? widget.initialProjectId ?? first.id;
    final project = projects.firstWhere(
      (item) => item.id == _projectId,
      orElse: () => first,
    );
    final now = DateTime.now();
    final currentMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    _start = entry?.start ?? currentMinute.subtract(const Duration(hours: 1));
    _end = entry?.end ?? currentMinute;
    _breaks = [...?entry?.breaks];
    _notes = entry?.notes ?? '';
    _isPaid = entry?.isPaid ?? false;
    _currency = entry?.currencySnapshot ?? project.currency;
    _rate = TextEditingController(
      text: (entry?.hourlyRateSnapshot ?? project.hourlyRate).toString(),
    );
  }

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  int get _seconds {
    final gross = _end.difference(_start).inSeconds;
    return (gross - _totalBreakSeconds).clamp(0, 1 << 31);
  }

  int get _totalBreakSeconds =>
      _breaks.fold<int>(0, (sum, item) => sum + item.seconds);

  double get _earnings =>
      _seconds /
      3600.0 *
      (double.tryParse(_rate.text.replaceAll(',', '.')) ?? 0);

  Future<DateTime?> _pickDate(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      initial.hour,
      initial.minute,
      initial.second,
      initial.millisecond,
      initial.microsecond,
    );
  }

  Future<DateTime?> _pickTime(DateTime initial) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(
      initial.year,
      initial.month,
      initial.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _editBreak({int? index}) async {
    final defaultEnd = _start.add(const Duration(minutes: 15));
    final initialStart = index == null ? _start : _breaks[index].start;
    final initialEnd = index == null
        ? (defaultEnd.isAfter(_end) ? _end : defaultEnd)
        : _breaks[index].end;
    final result = await showModalBottomSheet<_BreakEditorResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .78),
      builder: (_) => _BreakEditorSheet(
        initialStart: initialStart,
        initialEnd: initialEnd,
        entryStart: _start,
        entryEnd: _end,
        isEditing: index != null,
      ),
    );
    if (result == null) return;
    setState(() {
      if (result.delete && index != null) {
        _breaks.removeAt(index);
      } else if (result.period != null) {
        if (index == null) {
          _breaks.add(result.period!);
        } else {
          _breaks[index] = result.period!;
        }
        _breaks.sort((a, b) => a.start.compareTo(b.start));
      }
    });
  }

  Future<void> _openNotes() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => NotesPage(initialValue: _notes)),
    );
    if (result != null) setState(() => _notes = result);
  }

  Future<void> _save() async {
    final rate = double.tryParse(_rate.text.replaceAll(',', '.'));
    if (rate == null || rate < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.entry_invalidHourlyRate.tr())),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final entry = TimeEntry(
        id: widget.entry?.id ?? 0,
        projectId: _projectId,
        hourlyRateSnapshot: rate,
        currencySnapshot: _currency,
        start: _start,
        end: _end,
        breaks: _breaks,
        notes: _notes.trim(),
        isPaid: _isPaid,
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
      );
      await context.read<TrackerCubit>().saveEntry(entry);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizedErrorMessage(error))));
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final entry = widget.entry;
    if (entry == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.entry_deleteTitle.tr()),
        content: Text(LocaleKeys.entry_deleteMessage.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(LocaleKeys.common_delete.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<TrackerCubit>().deleteEntry(entry.id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<TrackerCubit>().state.projects;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.entry == null
                  ? LocaleKeys.entry_addTitle
                  : LocaleKeys.entry_editTitle)
              .tr(),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (widget.entry != null)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.schedule_rounded,
                    color: AppColors.purple,
                    value: formatDuration(_seconds),
                    label: LocaleKeys.entry_timeSummary.tr(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.toll_rounded,
                    color: AppColors.cyan,
                    value: formatMoney(_earnings, _currency),
                    label: LocaleKeys.entry_netSummary.tr(),
                  ),
                ),
              ],
            ),
            SectionTitle(LocaleKeys.entry_project.tr()),
            AnchoredDropdownField<int>(
              value: _projectId,
              items: {for (final project in projects) project.id: project.name},
              prefixIcon: Icons.folder_outlined,
              prefixIconColor: AppColors.lime,
              onChanged: (value) {
                final project = projects.firstWhere((item) => item.id == value);
                setState(() {
                  _projectId = project.id;
                  _currency = project.currency;
                  _rate.text = project.hourlyRate.toString();
                });
              },
            ),
            SectionTitle(LocaleKeys.entry_hourlyRate.tr()),
            TextField(
              controller: _rate,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.attach_money_rounded,
                  color: AppColors.lime,
                ),
                suffixText: _currency,
              ),
            ),
            SectionTitle(LocaleKeys.entry_start.tr()),
            _DateTimeRow(
              value: _start,
              dateKey: const ValueKey('start-date-button'),
              timeKey: const ValueKey('start-time-button'),
              onDateTap: () async {
                final value = await _pickDate(_start);
                if (value != null) setState(() => _start = value);
              },
              onTimeTap: () async {
                final value = await _pickTime(_start);
                if (value != null) setState(() => _start = value);
              },
            ),
            SectionTitle(LocaleKeys.entry_end.tr()),
            _DateTimeRow(
              value: _end,
              dateKey: const ValueKey('end-date-button'),
              timeKey: const ValueKey('end-time-button'),
              onDateTap: () async {
                final value = await _pickDate(_end);
                if (value != null) setState(() => _end = value);
              },
              onTimeTap: () async {
                final value = await _pickTime(_end);
                if (value != null) setState(() => _end = value);
              },
            ),
            SectionTitle(LocaleKeys.entry_breaks.tr()),
            AppSurface(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
              child: Column(
                children: [
                  for (var i = 0; i < _breaks.length; i++)
                    _BreakListRow(
                      period: _breaks[i],
                      onEdit: () => _editBreak(index: i),
                    ),
                  ListTile(
                    key: const ValueKey('add-break-button'),
                    contentPadding: EdgeInsets.zero,
                    onTap: _editBreak,
                    leading: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.lime,
                    ),
                    title: Text(
                      LocaleKeys.entry_addBreak.tr(),
                      style: const TextStyle(color: AppColors.lime),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      children: [
                        Text(
                          '${LocaleKeys.common_total.tr()}:',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatBreakDuration(_totalBreakSeconds),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SectionTitle(LocaleKeys.entry_notes.tr()),
            AppSurface(
              onTap: _openNotes,
              child: Row(
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    color: AppColors.lime,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _notes.isEmpty ? LocaleKeys.entry_notesHint.tr() : _notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _notes.isEmpty
                            ? AppColors.textMuted
                            : AppColors.text,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SwitchListTile.adaptive(
              value: _isPaid,
              onChanged: (value) => setState(() => _isPaid = value),
              title: Text(LocaleKeys.entry_paid.tr()),
              subtitle: Text(
                LocaleKeys.entry_paidMessage.tr(),
                style: const TextStyle(color: AppColors.textMuted),
              ),
              activeThumbColor: AppColors.lime,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(LocaleKeys.common_save.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.value,
    required this.dateKey,
    required this.timeKey,
    required this.onDateTap,
    required this.onTimeTap,
  });
  final DateTime value;
  final Key dateKey;
  final Key timeKey;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: AppSurface(
            key: dateKey,
            onTap: onDateTap,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.lime,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatDate(value),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: AppSurface(
            key: timeKey,
            onTap: onTimeTap,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: AppColors.lime),
                const SizedBox(width: 9),
                Text(
                  formatTime(value),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BreakListRow extends StatelessWidget {
  const _BreakListRow({required this.period, required this.onEdit});

  final BreakPeriod period;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              '${formatTime(period.start)} – ${formatTime(period.end)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatBreakDuration(period.seconds),
              style: const TextStyle(color: AppColors.text, fontSize: 16),
            ),
          ),
          IconButton(
            tooltip: LocaleKeys.breakEditor_editTooltip.tr(),
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.lime),
          ),
        ],
      ),
    );
  }
}

String _formatBreakDuration(int totalSeconds) {
  final safe = totalSeconds.clamp(0, 1 << 31);
  final hours = safe ~/ 3600;
  final minutes = (safe % 3600) ~/ 60;
  return LocaleKeys.duration_hoursMinutesShort.tr(
    namedArgs: {
      'hours': '$hours',
      'minutes': minutes.toString().padLeft(2, '0'),
    },
  );
}

class _BreakEditorResult {
  const _BreakEditorResult.save(this.period) : delete = false;
  const _BreakEditorResult.delete() : period = null, delete = true;

  final BreakPeriod? period;
  final bool delete;
}

class _BreakEditorSheet extends StatefulWidget {
  const _BreakEditorSheet({
    required this.initialStart,
    required this.initialEnd,
    required this.entryStart,
    required this.entryEnd,
    required this.isEditing,
  });

  final DateTime initialStart;
  final DateTime initialEnd;
  final DateTime entryStart;
  final DateTime entryEnd;
  final bool isEditing;

  @override
  State<_BreakEditorSheet> createState() => _BreakEditorSheetState();
}

class _BreakEditorSheetState extends State<_BreakEditorSheet> {
  static const _sheetColor = Color(0xFF38373E);
  static const _fieldColor = Color(0xFF47464D);

  late DateTime _start;
  late DateTime _end;
  late final TextEditingController _minutesController;

  int get _durationMinutes =>
      _end.difference(_start).inSeconds.clamp(0, 1 << 31) ~/ 60;

  bool get _isValid =>
      _end.isAfter(_start) &&
      !_start.isBefore(widget.entryStart) &&
      !_end.isAfter(widget.entryEnd);

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    _minutesController = TextEditingController(
      text: _durationMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  DateTime _withTime(DateTime value, TimeOfDay time) {
    return DateTime(value.year, value.month, value.day, time.hour, time.minute);
  }

  Future<void> _pickStart() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (value == null || !mounted) return;
    final previousDuration = _end.difference(_start);
    setState(() {
      _start = _withTime(_start, value);
      _end = _start.add(previousDuration);
      _syncLength();
    });
  }

  Future<void> _pickEnd() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
    );
    if (value == null || !mounted) return;
    setState(() {
      _end = _withTime(_end, value);
      if (!_end.isAfter(_start) && widget.entryEnd.day != _start.day) {
        _end = _end.add(const Duration(days: 1));
      }
      _syncLength();
    });
  }

  void _syncLength() {
    _minutesController.text = _durationMinutes.toString();
  }

  void _changeLength(String rawValue) {
    final minutes = int.tryParse(rawValue);
    setState(() {
      _end = _start.add(Duration(minutes: minutes ?? 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = (media.size.height * .66).clamp(500.0, 590.0);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            color: _sheetColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 56,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _BreakFieldHeader(LocaleKeys.breakEditor_start.tr()),
                _BreakTimeField(
                  value: _start,
                  icon: Icons.schedule_rounded,
                  onTap: _pickStart,
                ),
                const SizedBox(height: 21),
                _BreakFieldHeader(LocaleKeys.breakEditor_end.tr()),
                _BreakTimeField(
                  value: _end,
                  icon: Icons.schedule_rounded,
                  onTap: _pickEnd,
                ),
                const SizedBox(height: 21),
                _BreakFieldHeader(
                  LocaleKeys.breakEditor_length.tr(),
                  suffix: ' (${LocaleKeys.breakEditor_minutes.tr()})',
                ),
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: _fieldColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: _changeLength,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.hourglass_empty_rounded,
                        color: AppColors.lime,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _minutesController.clear();
                          _changeLength('');
                        },
                        icon: const Icon(
                          Icons.cancel_rounded,
                          color: AppColors.textMuted,
                        ),
                      ),
                      suffixText: LocaleKeys.breakEditor_minutes.tr(),
                      suffixStyle: const TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 58,
                  child: FilledButton(
                    onPressed: _isValid
                        ? () => Navigator.pop(
                            context,
                            _BreakEditorResult.save(
                              BreakPeriod(start: _start, end: _end),
                            ),
                          )
                        : null,
                    child: Text(LocaleKeys.common_save.tr()),
                  ),
                ),
                const SizedBox(height: 14),
                if (widget.isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: _BreakSheetOutlineButton(
                          icon: Icons.delete_outline_rounded,
                          label: LocaleKeys.common_delete.tr(),
                          onPressed: () => Navigator.pop(
                            context,
                            const _BreakEditorResult.delete(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BreakSheetOutlineButton(
                          icon: Icons.close_rounded,
                          label: LocaleKeys.common_cancel.tr(),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  )
                else
                  _BreakSheetOutlineButton(
                    icon: Icons.close_rounded,
                    label: LocaleKeys.common_cancel.tr(),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BreakFieldHeader extends StatelessWidget {
  const _BreakFieldHeader(this.label, {this.suffix = ''});

  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(
        TextSpan(
          text: label,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(
              text: suffix,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakTimeField extends StatelessWidget {
  const _BreakTimeField({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _BreakEditorSheetState._fieldColor,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(icon, color: AppColors.lime, size: 29),
              const SizedBox(width: 16),
              Text(formatTime(value), style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakSheetOutlineButton extends StatelessWidget {
  const _BreakSheetOutlineButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.text, width: 1.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
