import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/repositories/statistics_preferences.dart';

class FileStatisticsPreferences implements StatisticsPreferences {
  static const _fileName = 'statistics_preferences.json';
  static const _currencyKey = 'displayCurrency';

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  @override
  Future<String?> readDisplayCurrency() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      return decoded[_currencyKey]?.toString().toUpperCase();
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveDisplayCurrency(String currency) async {
    try {
      final file = await _file();
      await file.writeAsString(
        jsonEncode({_currencyKey: currency.toUpperCase()}),
        flush: true,
      );
    } on Object {
      // Preference persistence must never block the statistics experience.
    }
  }
}
