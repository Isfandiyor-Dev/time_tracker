import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/time_entry.dart';
import '../../generated/locale_keys.g.dart';
import '../cubit/tracker_cubit.dart';
import 'entry_editor_page.dart';
import 'manage_projects_page.dart';
import 'project_editor_page.dart';
import 'statistics_page.dart';
import 'timer_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _fabOpen = false;
  bool _checkingNotificationAction = false;
  bool _timerSheetVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNativeActions();
      final state = context.read<TrackerCubit>().state;
      if (state.editorEntryId != null) {
        _openRequestedEditor(state.editorEntryId!);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNativeActions();
    }
  }

  Future<void> _checkNativeActions() async {
    if (_checkingNotificationAction) return;
    _checkingNotificationAction = true;
    try {
      final shouldOpenTimer = await context
          .read<TrackerCubit>()
          .checkNativeActions();
      if (shouldOpenTimer && mounted) {
        await _openRunningTimerSheet();
      }
    } finally {
      _checkingNotificationAction = false;
    }
  }

  Future<void> _openRunningTimerSheet() async {
    if (_timerSheetVisible || !mounted) return;
    _timerSheetVisible = true;
    try {
      await showRunningTimerSheet(context);
    } finally {
      _timerSheetVisible = false;
    }
  }

  Future<void> _openRequestedEditor(int id) async {
    final cubit = context.read<TrackerCubit>();
    final entry = cubit.state.entries
        .where((item) => item.id == id)
        .firstOrNull;
    cubit.clearEditorRequest();
    if (entry == null || !mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EntryEditorPage(entry: entry)),
    );
  }

  Future<void> _addProject() async {
    setState(() => _fabOpen = false);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProjectEditorPage()),
    );
  }

  Future<void> _openManageProjects() async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageProjectsPage()),
    );
  }

  Future<void> _openStatistics() async {
    final state = context.read<TrackerCubit>().state;
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StatisticsPage(projects: state.projects, entries: state.entries),
      ),
    );
  }

  void _openLanguagePicker() {
    Navigator.pop(context);
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => const _LanguageSheet(),
      );
    });
  }

  Future<void> _addEntry() async {
    setState(() => _fabOpen = false);
    final state = context.read<TrackerCubit>().state;
    if (state.projects.isEmpty) return _addProject();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EntryEditorPage(initialProjectId: state.selectedProjectId),
      ),
    );
  }

  Future<void> _punchIn() async {
    setState(() => _fabOpen = false);
    final cubit = context.read<TrackerCubit>();
    if (cubit.state.runningTimer != null) {
      await _openRunningTimerSheet();
      return;
    }
    final project = cubit.state.selectedProject;
    if (project == null) return _addProject();
    final notificationAllowed = await cubit.punchIn(project);
    if (!notificationAllowed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.home_notificationPermissionDenied.tr()),
        ),
      );
    }
    if (mounted) await _openRunningTimerSheet();
  }

  Future<void> _confirmDeleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.home_deleteSelectedTitle.tr()),
        content: Text(LocaleKeys.home_deleteSelectedMessage.tr()),
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
    if (confirmed == true && mounted) {
      await context.read<TrackerCubit>().deleteSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrackerCubit, TrackerState>(
      listenWhen: (previous, current) =>
          previous.editorRequestSerial != current.editorRequestSerial,
      listener: (context, state) {
        if (state.editorEntryId != null) {
          _openRequestedEditor(state.editorEntryId!);
        }
      },
      child: BlocBuilder<TrackerCubit, TrackerState>(
        builder: (context, state) {
          if (state.status == TrackerStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.status == TrackerStatus.failure) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    (state.errorMessage ?? LocaleKeys.common_error).tr(),
                  ),
                ),
              ),
            );
          }
          return PopScope(
            canPop: !state.isSelecting,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop && state.isSelecting) {
                context.read<TrackerCubit>().clearSelection();
              }
            },
            child: Scaffold(
              appBar: state.isSelecting
                  ? _selectionAppBar(state)
                  : _mainAppBar(),
              drawer: state.isSelecting
                  ? null
                  : _TrackerDrawer(
                      onStatistics: _openStatistics,
                      onManageProjects: _openManageProjects,
                      onLanguage: _openLanguagePicker,
                    ),
              body: state.projects.isEmpty
                  ? _EmptyProjects(onAdd: _addProject)
                  : _ProjectContent(state: state),
              floatingActionButton:
                  state.isSelecting || state.runningTimer != null
                  ? null
                  : _ActionFab(
                      isOpen: _fabOpen,
                      onToggle: () => setState(() => _fabOpen = !_fabOpen),
                      onAddEntry: _addEntry,
                      onPunchIn: _punchIn,
                    ),
              bottomNavigationBar: state.isSelecting
                  ? _SelectionSummary(entries: state.selectedEntries)
                  : state.runningTimer == null
                  ? null
                  : SafeArea(
                      minimum: const EdgeInsets.fromLTRB(16, 6, 16, 40),
                      child: MiniTimerBar(onTap: _openRunningTimerSheet),
                    ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _mainAppBar() {
    return AppBar(
      title: Text(
        LocaleKeys.app_title.tr(),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  PreferredSizeWidget _selectionAppBar(TrackerState state) {
    return AppBar(
      leading: IconButton(
        onPressed: context.read<TrackerCubit>().clearSelection,
        icon: const Icon(Icons.close_rounded),
      ),
      title: Text(
        LocaleKeys.home_selectedCount.tr(
          namedArgs: {'count': '${state.selectedEntryIds.length}'},
        ),
      ),
      actions: [
        IconButton(
          tooltip: LocaleKeys.home_markAsPaid.tr(),
          onPressed: context.read<TrackerCubit>().markSelectedPaid,
          icon: const Icon(Icons.paid_outlined, color: AppColors.lime),
        ),
        IconButton(
          tooltip: LocaleKeys.common_delete.tr(),
          onPressed: _confirmDeleteSelected,
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }
}

class _TrackerDrawer extends StatelessWidget {
  const _TrackerDrawer({
    required this.onStatistics,
    required this.onManageProjects,
    required this.onLanguage,
  });

  final VoidCallback onStatistics;
  final VoidCallback onManageProjects;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.84,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const _DrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
              children: [
                _DrawerTile(
                  icon: Icons.query_stats_rounded,
                  label: LocaleKeys.drawer_statistics.tr(),
                  onTap: onStatistics,
                ),
                const SizedBox(height: 8),
                _DrawerTile(
                  icon: Icons.folder_copy_outlined,
                  label: LocaleKeys.drawer_manageProjects.tr(),
                  onTap: onManageProjects,
                ),
                const SizedBox(height: 8),
                _DrawerTile(
                  icon: Icons.language_rounded,
                  label: LocaleKeys.drawer_language.tr(),
                  subtitle: _languageName(context.locale.languageCode),
                  onTap: onLanguage,
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
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

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF263323), Color(0xFF151B1B)],
        ),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -42,
            top: 28,
            child: _HeaderRing(size: 156, opacity: 0.10),
          ),
          const Positioned(
            right: 34,
            bottom: -38,
            child: _HeaderRing(size: 104, opacity: 0.07),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3DC9F56A),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.background,
                      size: 31,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    LocaleKeys.app_title.tr(),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocaleKeys.drawer_subtitle.tr(),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRing extends StatelessWidget {
  const _HeaderRing({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.lime.withValues(alpha: opacity),
          width: 18,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.lime, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final currentCode = context.locale.languageCode;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.lime,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                LocaleKeys.drawer_chooseLanguage.tr(),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _LanguageOption(
            locale: const Locale('en'),
            title: LocaleKeys.drawer_english.tr(),
            nativeName: 'English',
            flag: 'EN',
            isSelected: currentCode == 'en',
          ),
          const SizedBox(height: 8),
          _LanguageOption(
            locale: const Locale('uz'),
            title: LocaleKeys.drawer_uzbek.tr(),
            nativeName: 'O‘zbekcha',
            flag: 'UZ',
            isSelected: currentCode == 'uz',
          ),
          const SizedBox(height: 8),
          _LanguageOption(
            locale: const Locale('ru'),
            title: LocaleKeys.drawer_russian.tr(),
            nativeName: 'Русский',
            flag: 'RU',
            isSelected: currentCode == 'ru',
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.title,
    required this.nativeName,
    required this.flag,
    required this.isSelected,
  });

  final Locale locale;
  final String title;
  final String nativeName;
  final String flag;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.lime.withValues(alpha: 0.10)
          : AppColors.card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await context.setLocale(locale);
          if (context.mounted) Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.limeMuted : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  flag,
                  style: const TextStyle(
                    color: AppColors.lime,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (title != nativeName) ...[
                      const SizedBox(height: 2),
                      Text(
                        nativeName,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lime : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.lime : Colors.white24,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.background,
                        size: 18,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _languageName(String code) {
  return switch (code) {
    'uz' => 'O‘zbekcha',
    'ru' => 'Русский',
    _ => 'English',
  };
}

class _ProjectContent extends StatelessWidget {
  const _ProjectContent({required this.state});
  final TrackerState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 58,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            scrollDirection: Axis.horizontal,
            itemCount: state.projects.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == state.projects.length) {
                final colors = Theme.of(context).colorScheme;
                final radius = BorderRadius.circular(14);
                return Align(
                  child: Tooltip(
                    message: LocaleKeys.home_addProject.tr(),
                    child: Material(
                      color: Colors.transparent,
                      child: Ink(
                        width: 40,
                        height: 36,
                        decoration: BoxDecoration(
                          color: state.isSelecting
                              ? colors.onSurface.withValues(alpha: .12)
                              : colors.secondaryContainer,
                          borderRadius: radius,
                        ),
                        child: InkWell(
                          onTap: state.isSelecting
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProjectEditorPage(),
                                  ),
                                ),
                          borderRadius: radius,
                          child: Icon(
                            Icons.add_rounded,
                            color: state.isSelecting
                                ? colors.onSurface.withValues(alpha: .38)
                                : colors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              final project = state.projects[index];
              final selected = project.id == state.selectedProjectId;
              return ChoiceChip(
                selected: selected,
                onSelected: state.isSelecting
                    ? null
                    : (_) => context.read<TrackerCubit>().selectProject(
                        project.id,
                      ),
                showCheckmark: false,
                avatar: Icon(
                  Icons.folder_rounded,
                  size: 18,
                  color: selected ? AppColors.background : AppColors.lime,
                ),
                label: Text(project.name),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.background : AppColors.text,
                ),
                selectedColor: AppColors.lime,
                backgroundColor: AppColors.surfaceHigh,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: state.visibleEntries.isEmpty
                ? _EmptyEntries(
                    key: ValueKey(state.selectedProjectId),
                    project: state.selectedProject!,
                  )
                : _GroupedEntryList(
                    key: ValueKey(state.selectedProjectId),
                    entries: state.visibleEntries,
                    selected: state.selectedEntryIds,
                  ),
          ),
        ),
      ],
    );
  }
}

class _GroupedEntryList extends StatelessWidget {
  const _GroupedEntryList({
    super.key,
    required this.entries,
    required this.selected,
  });
  final List<TimeEntry> entries;
  final Set<int> selected;

  @override
  Widget build(BuildContext context) {
    final groups = <DateTime, List<TimeEntry>>{};
    for (final entry in entries) {
      final day = DateTime(
        entry.start.year,
        entry.start.month,
        entry.start.day,
      );
      groups.putIfAbsent(day, () => []).add(entry);
    }
    final items = <Widget>[];
    for (final group in groups.entries) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 10),
          child: Text(
            dateGroupLabel(group.key, DateTime.now()),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
      );
      for (final entry in group.value) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _EntryTile(
              entry: entry,
              isSelected: selected.contains(entry.id),
            ),
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: items,
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.isSelected});
  final TimeEntry entry;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TrackerCubit>();
    void tap() {
      if (cubit.state.isSelecting) {
        cubit.toggleEntrySelection(entry.id);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EntryEditorPage(entry: entry)),
        );
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.lime.withValues(alpha: .13)
            : AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: isSelected ? AppColors.lime : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tap,
          onLongPress: () => cubit.toggleEntrySelection(entry.id),
          borderRadius: BorderRadius.circular(21),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            key: ValueKey(true),
                            color: AppColors.lime,
                            size: 32,
                          ),
                        )
                      : Container(
                          key: const ValueKey(false),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            color: AppColors.purple,
                          ),
                        ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDuration(entry.totalSeconds),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${formatTime(entry.start)} – ${formatTime(entry.end)}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          if (entry.notes.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.sticky_note_2_outlined,
                              size: 16,
                              color: AppColors.lime,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMoney(entry.exactEarnings, entry.currencySnapshot),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _PaidBadge(paid: entry.isPaid),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaidBadge extends StatelessWidget {
  const _PaidBadge({required this.paid});
  final bool paid;

  @override
  Widget build(BuildContext context) {
    final color = paid ? AppColors.cyan : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        (paid ? LocaleKeys.home_paid : LocaleKeys.home_unpaid).tr(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({required this.entries});
  final List<TimeEntry> entries;

  @override
  Widget build(BuildContext context) {
    final unpaid = entries.where((entry) => !entry.isPaid).toList();
    final seconds = unpaid.fold<int>(
      0,
      (sum, entry) => sum + entry.totalSeconds,
    );
    final byCurrency = <String, double>{};
    for (final entry in unpaid) {
      byCurrency.update(
        entry.currencySnapshot,
        (value) => value + entry.exactEarnings,
        ifAbsent: () => entry.exactEarnings,
      );
    }
    final amounts = byCurrency.entries
        .map((item) => formatMoney(item.value, item.key))
        .join(' + ');
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 6, 16, 30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lime.withValues(alpha: .5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.home_unpaidTotal.tr(),
              style: const TextStyle(
                color: AppColors.lime,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${formatDuration(seconds)}${amounts.isEmpty ? '' : '  |  $amounts'}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionFab extends StatelessWidget {
  const _ActionFab({
    required this.isOpen,
    required this.onToggle,
    required this.onAddEntry,
    required this.onPunchIn,
  });
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onAddEntry;
  final VoidCallback onPunchIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedScale(
          scale: isOpen ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: FloatingActionButton.extended(
            heroTag: 'manual-entry',
            onPressed: onAddEntry,
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.text,
            icon: const Icon(Icons.note_add_rounded),
            label: Text(LocaleKeys.home_addEntry.tr()),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedScale(
          scale: isOpen ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: FloatingActionButton.extended(
            heroTag: 'punch-in',
            onPressed: onPunchIn,
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.lime,
            icon: const Icon(Icons.punch_clock_rounded),
            label: Text(LocaleKeys.home_punchIn.tr()),
          ),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'main-action',
          onPressed: onToggle,
          child: AnimatedRotation(
            turns: isOpen ? .125 : 0,
            duration: const Duration(milliseconds: 220),
            child: Icon(isOpen ? Icons.close_rounded : Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lime.withValues(alpha: .08),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.folder_open_rounded,
                    size: 78,
                    color: AppColors.lime,
                  ),
                  Positioned(
                    right: 28,
                    bottom: 31,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_circle_rounded,
                        color: AppColors.cyan,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text(
              LocaleKeys.home_emptyProjectsTitle.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              LocaleKeys.home_emptyProjectsMessage.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text(LocaleKeys.home_addProject.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEntries extends StatelessWidget {
  const _EmptyEntries({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_empty_rounded,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 18),
            Text(
              LocaleKeys.home_emptyEntriesTitle.tr(
                namedArgs: {'project': project.name},
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.home_emptyEntriesMessage.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
