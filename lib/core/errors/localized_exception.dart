import 'package:easy_localization/easy_localization.dart';

import '../../generated/locale_keys.g.dart';

class LocalizedException implements Exception {
  const LocalizedException(this.key);

  final String key;
}

String localizedErrorMessage(Object error) {
  if (error case LocalizedException(:final key)) return key.tr();
  return LocaleKeys.errors_unknown.tr();
}
