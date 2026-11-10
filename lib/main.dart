import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/isar_tracker_repository.dart';
import 'data/services/platform_timer_service.dart';
import 'generated/locale_keys.g.dart';
import 'presentation/cubit/tracker_cubit.dart';
import 'presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final repository = await IsarTrackerRepository.open();
  final cubit = TrackerCubit(repository, PlatformTimerService())..initialize();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('uz'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      useOnlyLangCode: true,
      child: TimeTrackerApp(cubit: cubit),
    ),
  );
}

class TimeTrackerApp extends StatefulWidget {
  const TimeTrackerApp({super.key, required this.cubit});

  final TrackerCubit cubit;

  @override
  State<TimeTrackerApp> createState() => _TimeTrackerAppState();
}

class _TimeTrackerAppState extends State<TimeTrackerApp> {
  String? _syncedLanguageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = context.locale.languageCode;
    if (_syncedLanguageCode == languageCode) return;
    _syncedLanguageCode = languageCode;
    unawaited(widget.cubit.syncNotificationLocale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = context.locale.toLanguageTag();
    return BlocProvider.value(
      value: widget.cubit,
      child: MaterialApp(
        title: LocaleKeys.app_title.tr(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const HomePage(),
      ),
    );
  }
}
