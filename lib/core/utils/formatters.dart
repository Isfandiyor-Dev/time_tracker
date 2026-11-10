import 'package:easy_localization/easy_localization.dart';

import '../../generated/locale_keys.g.dart';
import 'time_math.dart';

String formatDuration(int totalSeconds, {bool includeSeconds = false}) {
  final safe = totalSeconds.clamp(0, 1 << 31);
  final hours = safe ~/ 3600;
  final minutes = (safe % 3600) ~/ 60;
  final seconds = safe % 60;
  if (includeSeconds) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  if (hours == 0) {
    return LocaleKeys.duration_minutesShort.tr(
      namedArgs: {'minutes': '$minutes'},
    );
  }
  return LocaleKeys.duration_hoursMinutesShort.tr(
    namedArgs: {
      'hours': '$hours',
      'minutes': minutes.toString().padLeft(2, '0'),
    },
  );
}

String formatMoney(double exact, String currency) {
  final rounded = roundCurrency(exact);
  final digits = rounded == rounded.roundToDouble() ? 0 : 2;
  final number = NumberFormat.currency(
    locale: Intl.defaultLocale ?? 'en',
    symbol: '',
    decimalDigits: digits,
  ).format(rounded).trim();
  return switch (currency) {
    'USD' => '\$$number',
    'EUR' => '€$number',
    'RUB' => '₽$number',
    _ => '$number $currency',
  };
}

String formatDate(DateTime value) => DateFormat('dd.MM.yyyy').format(value);
String formatTime(DateTime value) => DateFormat('H:mm').format(value);

String dateGroupLabel(DateTime value, DateTime now) {
  final date = DateTime(value.year, value.month, value.day);
  final today = DateTime(now.year, now.month, now.day);
  if (date == today) return LocaleKeys.dates_today.tr();
  if (date == today.subtract(const Duration(days: 1))) {
    return LocaleKeys.dates_yesterday.tr();
  }
  const monthKeys = [
    LocaleKeys.dates_january,
    LocaleKeys.dates_february,
    LocaleKeys.dates_march,
    LocaleKeys.dates_april,
    LocaleKeys.dates_may,
    LocaleKeys.dates_june,
    LocaleKeys.dates_july,
    LocaleKeys.dates_august,
    LocaleKeys.dates_september,
    LocaleKeys.dates_october,
    LocaleKeys.dates_november,
    LocaleKeys.dates_december,
  ];
  return '${value.day} ${monthKeys[value.month - 1].tr()}';
}
