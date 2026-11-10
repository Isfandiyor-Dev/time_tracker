import 'dart:convert';
import 'dart:io';

import '../../domain/repositories/exchange_rate_repository.dart';

class FrankfurterExchangeRateRepository implements ExchangeRateRepository {
  FrankfurterExchangeRateRepository({HttpClient? client})
    : _client = client ?? HttpClient();

  final HttpClient _client;

  @override
  Future<Map<String, double>> fetchRatesTo({
    required Set<String> sources,
    required String target,
  }) async {
    final normalizedTarget = target.toUpperCase();
    final normalizedSources = sources
        .map((currency) => currency.toUpperCase())
        .where((currency) => currency != normalizedTarget)
        .toSet();
    final result = <String, double>{normalizedTarget: 1};
    if (normalizedSources.isEmpty) return result;

    final uri = Uri.https('api.frankfurter.dev', '/v2/rates', {
      'base': normalizedTarget,
      'quotes': normalizedSources.join(','),
    });
    final request = await _client
        .getUrl(uri)
        .timeout(const Duration(seconds: 8));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close().timeout(const Duration(seconds: 8));
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Frankfurter returned ${response.statusCode}',
        uri: uri,
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is List) {
      for (final row in decoded.whereType<Map<String, dynamic>>()) {
        final quote = row['quote']?.toString().toUpperCase();
        final rate = (row['rate'] as num?)?.toDouble();
        if (quote != null && rate != null && rate.isFinite && rate > 0) {
          // The request uses target as base, so invert target -> source.
          result[quote] = 1 / rate;
        }
      }
    } else if (decoded is Map<String, dynamic>) {
      final rates = decoded['rates'];
      if (rates is Map<String, dynamic>) {
        for (final item in rates.entries) {
          final rate = (item.value as num?)?.toDouble();
          if (rate != null && rate.isFinite && rate > 0) {
            result[item.key.toUpperCase()] = 1 / rate;
          }
        }
      }
    }

    return result;
  }
}
